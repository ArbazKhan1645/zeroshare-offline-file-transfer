// lib/services/sender_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zero_share/controllers/manager.dart';
import 'package:zero_share/models/files_model.dart';
import 'package:zero_share/services/history_service.dart';
import 'package:zero_share/services/network_service.dart';

class SenderService {
  static HttpServer? _server;
  static List<FileModel> _files = [];
  static int _secretCode = 0;
  static String? _localIP;
  static final int _port = 4040;

  // Connected receivers
  static Map<String, Map<String, dynamic>> connectedReceivers = {};

  static Future<Map<String, dynamic>> startServer(List<File> files) async {
    _files = files.map((file) => FileModel.fromFile(file)).toList();
    _secretCode = Random().nextInt(900000) + 100000;

    _localIP = await NetworkService.getPreferredIP();
    if (_localIP == null) {
      return {'success': false, 'error': 'No network connection found'};
    }

    try {
      _server = await HttpServer.bind(_localIP, _port);

      _server!.listen(_handleRequest);

      return {
        'success': true,
        'ip': _localIP,
        'port': _port,
        'code': _secretCode,
      };
    } catch (e) {
      return {'success': false, 'error': 'Failed to start server: $e'};
    }
  }

  static void _handleRequest(HttpRequest request) async {
    final uri = request.uri.toString();

    try {
      if (uri.contains('/photon-server')) {
        _handleDeviceInfo(request);
      } else if (uri.contains('/get-code')) {
        _handleCodeRequest(request);
      } else if (uri.contains('/getpaths')) {
        _handleFileListRequest(request);
      } else if (uri.contains('/receiver-data')) {
        _handleReceiverData(request);
      } else if (uri.contains('/$_secretCode/')) {
        _handleFileDownload(request);
      } else if (uri.contains('/start-transfer')) {
        _handleStartTransfer(request);
      } else {
        request.response.statusCode = HttpStatus.notFound;
        request.response.write('Not found');
        await request.response.close();
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
      request.response.statusCode = HttpStatus.internalServerError;
      await request.response.close();
    }
  }

  static void _handleDeviceInfo(HttpRequest request) {
    final box = GetStorage();
    final String username = box.read('username') ?? 'User';
    final String avatar =
        box.read('avatar') ?? 'assets/images/img_avatar_female_blue.png';

    final Map<String, dynamic> info = {
      'ip': _localIP,
      'port': _port,
      'host': username,
      'os': Platform.operatingSystem,
      'files-count': _files.length,
      'avatar': avatar,
    };

    request.response.write(jsonEncode(info));
    request.response.close();
  }

  static void _handleCodeRequest(HttpRequest request) {
    final String receiverName =
        request.headers.value('receiver-name') ?? 'Unknown';
    final String receiverID = request.headers.value('receiver-id') ??
        DateTime.now().millisecondsSinceEpoch.toString();

    // Store connected receiver
    connectedReceivers[receiverID] = {
      'name': receiverName,
      'connected_at': DateTime.now(),
      'status': 'connected',
    };

    // Notify ConnectionManager
    try {
      final connManager = ConnectionManager.instance;
      connManager.isConnected.value = true;
      connManager.connectedDevice.value = SenderModel(
        hostName: receiverName,
        ip: '',
        port: 6,
        os: 'os',
        avatar: '',
      );
    } catch (e) {
      debugPrint('ConnectionManager not initialized yet');
    }

    request.response.write(
      jsonEncode({
        'code': _secretCode,
        'accepted': true,
        'receiver-id': receiverID,
      }),
    );
    request.response.close();
  }

  static void _handleFileListRequest(HttpRequest request) {
    final List<String> filePaths = _files.map((f) => f.path).toList();

    request.response.write(
      jsonEncode({
        'paths': filePaths,
        'isApk': false,
      }),
    );
    request.response.close();
  }

  static void _handleReceiverData(HttpRequest request) async {
    final String receiverID = request.headers.value('receiverID') ?? '';

    final String currentFile = request.headers.value('currentFile') ?? '0';
    final String isCompleted = request.headers.value('isCompleted') ?? 'false';

    if (connectedReceivers.containsKey(receiverID)) {
      connectedReceivers[receiverID]!['current_file'] = int.parse(currentFile);
      connectedReceivers[receiverID]!['is_completed'] = isCompleted == 'true';
    }

    // Update ConnectionManager
    try {
      final connManager = ConnectionManager.instance;
      connManager.updateTransferProgress(
        fileIndex: int.parse(currentFile),
        total: _files.length,
        progress: isCompleted == 'true' ? 100.0 : 50.0,
      );

      if (isCompleted == 'true') {
        // Add to history
        for (var file in _files) {
          await HistoryService.addHistory(
            TransferHistory(
              id: DateTime.now().millisecondsSinceEpoch.toString() + file.path,
              fileName: file.path.split('/').last,
              filePath: file.path,
              fileSize: file.size,
              senderName: 'Me',
              senderIP: serverIP.toString(),
              timestamp: DateTime.now(),
              isReceived: false,
              isSuccess: true,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('ConnectionManager update failed: $e');
    }

    request.response.statusCode = HttpStatus.ok;
    await request.response.close();
  }

  static void _handleStartTransfer(HttpRequest request) {
    // Receiver notifies sender that transfer is starting
    final String receiverID = request.headers.value('receiver-id') ?? '';

    if (connectedReceivers.containsKey(receiverID)) {
      connectedReceivers[receiverID]!['status'] = 'transferring';
    }

    try {
      final connManager = ConnectionManager.instance;
      connManager.isTransferring.value = true;
    } catch (e) {
      debugPrint('ConnectionManager not available');
    }

    request.response.statusCode = HttpStatus.ok;
    request.response.write(jsonEncode({'status': 'transfer_started'}));
    request.response.close();
  }

  static void _handleFileDownload(HttpRequest request) async {
    try {
      final String path = request.uri.path;
      final int fileIndex = int.parse(path.split('/').last);

      if (fileIndex < 0 || fileIndex >= _files.length) {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
        return;
      }

      final FileModel fileModel = _files[fileIndex];

      request.response.headers.contentType =
          ContentType('application', 'octet-stream');
      request.response.headers.add(
        'Content-Disposition',
        'attachment; filename="${fileModel.name}"',
      );
      request.response.headers.add('Content-Length', fileModel.size.toString());

      await fileModel.file.openRead().pipe(request.response);
      debugPrint('✅ Sent: ${fileModel.name}');
    } catch (e) {
      debugPrint('❌ Error sending file: $e');
      request.response.statusCode = HttpStatus.internalServerError;
      await request.response.close();
    }
  }

  static Future<void> stopServer() async {
    // Notify all connected receivers
    connectedReceivers.clear();

    await _server?.close(force: true);
    _server = null;
    _files.clear();

    // Disconnect ConnectionManager
    try {
      ConnectionManager.instance.disconnect();
    } catch (e) {
      debugPrint('ConnectionManager cleanup failed');
    }
  }

  static String? get serverIP => _localIP;
  static int get serverPort => _port;
  static int get secretCode => _secretCode;
  static bool get isRunning => _server != null;
  static int get connectedReceiverCount => connectedReceivers.length;
}
