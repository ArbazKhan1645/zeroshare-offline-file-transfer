// lib/services/room_service.dart
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zero_share/models/files_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:media_scanner/media_scanner.dart';
import 'package:zero_share/services/history_service.dart';
import 'package:zero_share/services/network_service.dart';

class RoomService {
  static HttpServer? _server;
  static RoomSession? _currentSession;
  static final List<TransferMessage> _messages = [];
  static Function(String messageId, double progress)? onProgressUpdate;
  static Function(TransferMessage)? onMessageReceived;
  static Function(String)? onUserJoined;
  static Function(String)? onUserLeft;

  static Future<RoomSession?> startRoom() async {
    try {
      final box = GetStorage();
      final String hostName = box.read('username') ?? 'User';

      await _cleanupRoom();

      // ✅ Start server on 4040
      _server = await HttpServer.bind(InternetAddress.anyIPv4, 4040);

      final String roomId = _generateRoomId();
      final String hostIP = await _getLocalIP();

      _currentSession = RoomSession(
        roomId: roomId,
        hostName: hostName,
        hostIP: hostIP,
        port: 4040,
        createdAt: DateTime.now(),
        isHost: true,
      );

      _handleRequests();

      return _currentSession;
    } catch (e) {
      debugPrint('❌ Failed to start room: $e');
      return null;
    }
  }

  static Future<List<RoomSession>> scanForRooms() async {
    final List<RoomSession> rooms = [];

    try {
      final List<String> hosts = await NetworkService.scanNetwork();

      for (String host in hosts) {
        final RoomSession? room = await _checkIfRoom(host, 4040);
        if (room != null) {
          rooms.add(room);
        }
      }
    } catch (e) {
      rethrow;
    }

    return rooms;
  }

  static Future<RoomSession?> _checkIfRoom(String ip, int port) async {
    try {
      final Dio dio = Dio();
      final Response response = await dio.get(
        'http://$ip:$port/room-info',
        options: Options(
          receiveTimeout: const Duration(seconds: 3),
          sendTimeout: const Duration(seconds: 3),
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;

        if (data['hasGuest'] == false) {
          return RoomSession(
            roomId: data['roomId'].toString(),
            hostName: data['hostName'].toString(),
            hostIP: ip,
            port: port,
            createdAt: DateTime.now(),
            isHost: false,
          );
        }
      }
    } catch (e) {
      // Not a room
    }
    return null;
  }

  static void _handleRequests() {
    _server!.listen((HttpRequest request) async {
      try {
        final String clientIP = request.connectionInfo!.remoteAddress.address;
        debugPrint('📨 ${request.method} ${request.uri.path} from $clientIP');

        if (request.uri.path == '/room-info') {
          final Map<String, dynamic> responseData = {
            'roomId': _currentSession!.roomId,
            'hostName': _currentSession!.hostName,
            'hostIP': _currentSession!.hostIP,
            'port': _currentSession!.port,
            'hasGuest': _currentSession!.guestName != null,
          };

          request.response
            ..headers.contentType = ContentType.json
            ..write(jsonEncode(responseData));
          await request.response.close();
        } else if (request.uri.path == '/join-room') {
          if (_currentSession!.guestName != null) {
            request.response
              ..statusCode = 403
              ..headers.contentType = ContentType.json
              ..write(jsonEncode({'error': 'Room is full'}));
            await request.response.close();
            return;
          }

          final String guestName =
              request.headers.value('guest-name') ?? 'Guest';
          final String guestIP = clientIP; // ✅ Use actual client IP

          debugPrint('✅ Guest joining:');
          debugPrint('   Name: $guestName');
          debugPrint('   IP: $guestIP');

          _currentSession = RoomSession(
            roomId: _currentSession!.roomId,
            hostName: _currentSession!.hostName,
            hostIP: _currentSession!.hostIP,
            port: _currentSession!.port,
            guestName: guestName,
            guestIP: guestIP, // ✅ Actual guest IP
            createdAt: _currentSession!.createdAt,
            isHost: true,
          );

          onUserJoined?.call(guestName);

          request.response
            ..headers.contentType = ContentType.json
            ..write(
              jsonEncode({
                'success': true,
                'roomId': _currentSession!.roomId,
                'hostName': _currentSession!.hostName,
              }),
            );
          await request.response.close();

          debugPrint('✅ Guest joined successfully');
          debugSession();
        } else if (request.uri.path == '/send-file') {
          await _handleFileReceive(request);
        } else if (request.uri.path == '/user-left') {
          final String userName = request.headers.value('user-name') ?? 'User';
          debugPrint('👋 User left notification: $userName');

          if (_currentSession!.isHost) {
            _currentSession = RoomSession(
              roomId: _currentSession!.roomId,
              hostName: _currentSession!.hostName,
              hostIP: _currentSession!.hostIP,
              port: _currentSession!.port,
              createdAt: _currentSession!.createdAt,
              isHost: true,
            );
          }

          onUserLeft?.call(userName);

          request.response
            ..statusCode = 200
            ..write('OK');
          await request.response.close();
        } else {
          request.response
            ..statusCode = 404
            ..write('Not found');
          await request.response.close();
        }
      } catch (e, stack) {
        debugPrint('❌ Request error: $e');
        debugPrint('Stack: $stack');
        try {
          request.response.statusCode = 500;
          request.response.write('Error');
          await request.response.close();
        } catch (_) {}
      }
    });
  }

  static Future<void> _handleFileReceive(HttpRequest request) async {
    IOSink? fileStream;
    File? tempFile;
    String messageId = '';

    try {
      final String fileName = request.headers.value('file-name') ?? 'unknown';
      final int fileSize = int.parse(request.headers.value('file-size') ?? '0');
      final String senderName =
          request.headers.value('sender-name') ?? 'Unknown';
      final String senderIP = request.connectionInfo!.remoteAddress.address;
      messageId =
          request.headers.value('message-id') ??
          DateTime.now().millisecondsSinceEpoch.toString();

      debugPrint('📥 Receiving: $fileName ($fileSize bytes) [ID: $messageId]');

      // ✅ Create initial message with 0% progress
      final TransferMessage initialMessage = TransferMessage(
        id: messageId,
        fileName: fileName,
        filePath: '', // Will update after save
        fileSize: fileSize,
        senderName: senderName,
        senderIP: senderIP,
        isSentByMe: false,
        timestamp: DateTime.now(),
        status: TransferStatus.receiving,
      );

      _messages.add(initialMessage);
      onMessageReceived?.call(initialMessage);

      final String fileType = _getFileType(fileName);
      final Directory saveDir = await _getSaveDirectoryByType(fileType);
      String savePath = path.join(saveDir.path, fileName);
      savePath = await _getUniquePath(savePath);

      tempFile = File(savePath);
      fileStream = tempFile.openWrite();

      int bytesReceived = 0;
      int lastProgressUpdate = 0;

      await for (var data in request) {
        fileStream.add(data);
        bytesReceived += data.length;

        // ✅ Update progress
        if (fileSize > 0) {
          final double progress = bytesReceived / fileSize;
          final int progressPercent = (progress * 100).toInt();

          // Update every 5% or on completion
          if (progressPercent % 5 == 0 &&
              progressPercent != lastProgressUpdate) {
            lastProgressUpdate = progressPercent;
            debugPrint('📥 Download: $progressPercent%');
            onProgressUpdate?.call(messageId, progress);
          }
        }
      }

      // ✅ CRITICAL: Ensure 100% progress before completing
      debugPrint('📥 Download: 100% - Finalizing...');
      onProgressUpdate?.call(messageId, 1.0);

      await fileStream.flush();
      await fileStream.close();
      fileStream = null;

      debugPrint('✅ File saved: $bytesReceived bytes at $savePath');

      if (bytesReceived > 0) {
        // Scan for gallery
        await _scanMediaFile(savePath, fileName, fileType);

        // Save to history
        await HistoryService.addHistory(
          TransferHistory(
            id: messageId,
            fileName: fileName,
            filePath: savePath,
            fileSize: bytesReceived,
            senderName: senderName,
            senderIP: senderIP,
            timestamp: DateTime.now(),
            isReceived: true,
            isSuccess: true,
          ),
        );

        // ✅ CRITICAL: Update message to COMPLETED
        final int index = _messages.indexWhere((m) => m.id == messageId);
        if (index != -1) {
          _messages[index] = _messages[index].copyWith(
            filePath: savePath,
            fileSize: bytesReceived, // Update with actual size
            status: TransferStatus.completed, // ✅ Set to completed
            progress: 1.0, // ✅ Ensure 100%
          );

          debugPrint('✅ Message updated: Status=completed, Progress=100%');

          // ✅ Force notify with completed message
          onMessageReceived?.call(_messages[index]);
          onProgressUpdate?.call(messageId, 1.0);
        } else {
          debugPrint('⚠️ Message not found in list for ID: $messageId');
        }

        request.response
          ..statusCode = 200
          ..write('OK');
        await request.response.close();

        debugPrint('✅ File receive complete - Status updated');
      } else {
        throw Exception('No data received');
      }
    } catch (e, stack) {
      debugPrint('❌ Receive error: $e');
      debugPrint('Stack: $stack');

      // ✅ Mark as failed
      if (messageId.isNotEmpty) {
        final int index = _messages.indexWhere((m) => m.id == messageId);
        if (index != -1) {
          _messages[index] = _messages[index].copyWith(
            status: TransferStatus.failed,
          );
          onMessageReceived?.call(_messages[index]);
        }
      }

      await fileStream?.close();
      if (tempFile != null && await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }

      try {
        request.response
          ..statusCode = 500
          ..write('Error');
        await request.response.close();
      } catch (_) {}
    }
  }

  static Future<RoomSession?> joinRoom(String ip, int port) async {
    try {
      final box = GetStorage();
      final String guestName = box.read('username') ?? 'User';

      _messages.clear();

      // ✅ IMPORTANT: Start guest's own server FIRST
      await _startGuestServer();

      // debugPrint('🔗 Joining room:');
      // debugPrint('   Host IP: $ip:$port');
      // debugPrint('   Guest Name: $guestName');

      final Dio dio = Dio();
      final Response response = await dio.post(
        'http://$ip:$port/join-room',
        options: Options(
          headers: {'guest-name': guestName},
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;

        final String guestIP = await _getLocalIP();

        _currentSession = RoomSession(
          roomId: data['roomId'].toString(),
          hostName: data['hostName'].toString(),
          hostIP: ip,
          port: port,
          guestName: guestName,
          guestIP: guestIP,
          createdAt: DateTime.now(),
          isHost: false,
        );

        // debugPrint('✅ Joined room:');
        // debugPrint('   Room ID: ${data['roomId']}');
        // debugPrint('   Host: ${data['hostName']} at $ip');
        // debugPrint('   Guest IP: $guestIP');
        // debugPrint('   Guest Server: 0.0.0.0:4040');

        debugSession();

        return _currentSession;
      }
    } catch (e, stack) {
      debugPrint('❌ Join failed: $e');
      debugPrint('Stack: $stack');
    }
    return null;
  }

  // ✅ NEW: Start guest's server to receive files
  static Future<void> _startGuestServer() async {
    if (_server != null) {
      debugPrint('⚠️ Server already running');
      return;
    }

    try {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, 4040);
      debugPrint('✅ Guest server started on 0.0.0.0:4040');

      _handleRequests(); // Use same handler
    } catch (e) {
      debugPrint('❌ Failed to start guest server: $e');
    }
  }

  static Future<bool> sendFile(File file, String recipientIP, int port) async {
    final String messageId = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      if (_currentSession == null) {
        debugPrint('❌ No active session');
        return false;
      }

      String targetIP;
      int targetPort = 4040;

      if (_currentSession!.isHost) {
        if (_currentSession!.guestIP == null ||
            _currentSession!.guestIP!.isEmpty ||
            _currentSession!.guestIP == 'Unknown') {
          debugPrint('❌ Guest IP invalid');
          return false;
        }
        targetIP = _currentSession!.guestIP!;
      } else {
        if (_currentSession!.hostIP.isEmpty ||
            _currentSession!.hostIP == 'Unknown') {
          debugPrint('❌ Host IP invalid');
          return false;
        }
        targetIP = _currentSession!.hostIP;
        targetPort = _currentSession!.port;
      }

      final box = GetStorage();
      final String senderName = box.read('username') ?? 'User';
      final String fileName = path.basename(file.path);
      final int fileSize = await file.length();

      // ✅ Create initial message with 0% progress
      final TransferMessage initialMessage = TransferMessage(
        id: messageId,
        fileName: fileName,
        filePath: file.path,
        fileSize: fileSize,
        senderName: senderName,
        senderIP: await _getLocalIP(),
        isSentByMe: true,
        timestamp: DateTime.now(),
        status: TransferStatus.sending,
      );

      _messages.add(initialMessage);
      onMessageReceived?.call(initialMessage); // ✅ Show immediately

      final Uint8List fileBytes = await file.readAsBytes();

      final Dio dio = Dio();

      // ✅ Send with progress callbacks
      final Response response = await dio.post(
        'http://$targetIP:$targetPort/send-file',
        data: Stream.fromIterable([fileBytes]),
        options: Options(
          headers: {
            'file-name': fileName,
            'file-size': fileSize.toString(),
            'sender-name': senderName,
            'message-id': messageId, // ✅ Send message ID
            'Content-Type': 'application/octet-stream',
          },
          receiveTimeout: const Duration(minutes: 5),
          sendTimeout: const Duration(minutes: 5),
        ),
        onSendProgress: (sent, total) {
          if (total > 0) {
            final double progress = sent / total;
            debugPrint(
              '📤 Upload progress: ${(progress * 100).toStringAsFixed(1)}%',
            );

            // ✅ Update progress
            onProgressUpdate?.call(messageId, progress);
          }
        },
      );

      if (response.statusCode == 200) {
        debugPrint('✅ File sent successfully');

        // ✅ Update to completed
        final int index = _messages.indexWhere((m) => m.id == messageId);
        if (index != -1) {
          _messages[index] = _messages[index].copyWith(
            status: TransferStatus.completed,
            progress: 1.0,
          );
          onProgressUpdate?.call(messageId, 1.0);
        }

        await HistoryService.addHistory(
          TransferHistory(
            id: messageId,
            fileName: fileName,
            filePath: file.path,
            fileSize: fileSize,
            senderName: senderName,
            senderIP: await _getLocalIP(),
            timestamp: DateTime.now(),
            isReceived: false,
            isSuccess: true,
          ),
        );

        return true;
      }

      return false;
    } catch (e) {
      debugPrint('❌ Send error: $e');

      // ✅ Mark as failed
      final int index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(
          status: TransferStatus.failed,
        );
        onProgressUpdate?.call(messageId, 0.0);
      }

      return false;
    }
  }

  static Future<void> leaveRoom() async {
    debugPrint('👋 Leaving room');

    try {
      if (_currentSession != null) {
        final box = GetStorage();
        final String userName = box.read('username') ?? 'User';

        // ✅ Send leave notification
        try {
          final Dio dio = Dio();
          String targetUrl;

          if (!_currentSession!.isHost) {
            // Guest leaving - notify host
            targetUrl =
                'http://${_currentSession!.hostIP}:${_currentSession!.port}/user-left';
            debugPrint('📤 Guest notifying host: $targetUrl');
          } else if (_currentSession!.guestIP != null &&
              _currentSession!.guestIP!.isNotEmpty &&
              _currentSession!.guestIP != 'Unknown') {
            // Host leaving - notify guest
            targetUrl = 'http://${_currentSession!.guestIP}:4040/user-left';
            debugPrint('📤 Host notifying guest: $targetUrl');
          } else {
            debugPrint('⚠️ No one to notify');
            await _cleanupRoom();
            return;
          }

          await dio
              .post(
                targetUrl,
                options: Options(
                  headers: {'user-name': userName},
                  receiveTimeout: const Duration(seconds: 3),
                  sendTimeout: const Duration(seconds: 3),
                ),
              )
              .timeout(const Duration(seconds: 3));

          debugPrint('✅ Leave notification sent');
        } catch (e) {
          debugPrint('⚠️ Could not notify: $e');
        }
      }

      await _cleanupRoom();
      debugPrint('✅ Room cleanup complete');
    } catch (e) {
      debugPrint('❌ Leave error: $e');
      await _cleanupRoom();
    }
  }

  static Future<void> _cleanupRoom() async {
    try {
      await _server?.close();
      debugPrint('✅ Server closed');
    } catch (e) {
      debugPrint('⚠️ Server close error: $e');
    }

    _server = null;
    _currentSession = null;
    _messages.clear();
  }

  static void debugSession() {
    debugPrint('═══════════════════════════════════');
    debugPrint('🔍 SESSION DEBUG');
    debugPrint('═══════════════════════════════════');
    debugPrint('Server Running: ${_server != null}');
    debugPrint('Session Active: ${_currentSession != null}');

    if (_currentSession != null) {
      debugPrint('Room ID: ${_currentSession!.roomId}');
      debugPrint('Is Host: ${_currentSession!.isHost}');
      debugPrint('---');
      debugPrint('Host Name: ${_currentSession!.hostName}');
      debugPrint('Host IP: ${_currentSession!.hostIP}');
      debugPrint('Host Port: ${_currentSession!.port}');
      debugPrint('---');
      debugPrint('Guest Name: ${_currentSession!.guestName ?? "None"}');
      debugPrint('Guest IP: ${_currentSession!.guestIP ?? "None"}');
      debugPrint('Guest Port: 4040');
      debugPrint('---');
    }

    debugPrint('Messages: ${_messages.length}');
    debugPrint('═══════════════════════════════════');
  }

  static Future<String> _getLocalIP() async {
    try {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      debugPrint('❌ IP error: $e');
    }
    return 'Unknown';
  }

  static String _generateRoomId() {
    return Random().nextInt(999999).toString().padLeft(6, '0');
  }

  static String _getFileType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'heic'].contains(ext)) {
      return 'Images';
    } else if (['mp4', 'avi', 'mkv', 'mov', 'wmv', '3gp'].contains(ext)) {
      return 'Videos';
    } else if (['mp3', 'wav', 'aac', 'm4a', 'flac'].contains(ext)) {
      return 'Audios';
    } else if (['pdf', 'doc', 'docx', 'txt'].contains(ext)) {
      return 'Documents';
    }
    return 'Others';
  }

  static Future<Directory> _getSaveDirectoryByType(String fileType) async {
    Directory baseDir;

    if (Platform.isAndroid) {
      if (['Images', 'Videos'].contains(fileType)) {
        baseDir = Directory('/storage/emulated/0/DCIM');
      } else if (fileType == 'Audios') {
        baseDir = Directory('/storage/emulated/0/Music');
      } else if (fileType == 'Documents') {
        baseDir = Directory('/storage/emulated/0/Documents');
      } else {
        baseDir = Directory('/storage/emulated/0/Download');
      }

      if (!await baseDir.exists()) {
        baseDir =
            await getExternalStorageDirectory() ??
            await getApplicationDocumentsDirectory();
      }
    } else {
      baseDir = await getApplicationDocumentsDirectory();
    }

    final Directory saveDir = Directory(
      path.join(baseDir.path, 'ZeroShare', fileType),
    );

    if (!await saveDir.exists()) {
      await saveDir.create(recursive: true);
    }

    return saveDir;
  }

  static Future<void> _scanMediaFile(
    String filePath,
    String fileName,
    String fileType,
  ) async {
    try {
      await MediaScanner.loadMedia(path: filePath);
      debugPrint('✅ Gallery scan complete');
    } catch (e) {
      debugPrint('⚠️ Scan failed: $e');
    }
  }

  static Future<String> _getUniquePath(String filePath) async {
    final File file = File(filePath);
    if (!await file.exists()) return filePath;

    final String dir = path.dirname(filePath);
    final String fileName = path.basenameWithoutExtension(filePath);
    final String extension = path.extension(filePath);

    int counter = 1;
    String newPath;

    do {
      newPath = path.join(dir, '$fileName($counter)$extension');
      counter++;
    } while (await File(newPath).exists());

    return newPath;
  }

  static RoomSession? get currentSession => _currentSession;
  static List<TransferMessage> get messages => List.from(_messages);
  static bool get isInRoom => _currentSession != null;

  static String getQRData() {
    if (_currentSession != null) {
      return '${_currentSession!.hostIP}:${_currentSession!.port}:${_currentSession!.roomId}';
    }
    return '';
  }
}
