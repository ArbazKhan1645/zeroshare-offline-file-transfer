// lib/services/receiver_service.dart
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:zero_share/controllers/file_controller.dart';
import 'package:zero_share/models/files_model.dart';
import 'package:zero_share/services/history_service.dart';
import 'package:zero_share/services/network_service.dart';
import 'package:media_scanner/media_scanner.dart';

class ReceiverService {
  static final int _receiverID = Random().nextInt(10000);

  // Request storage permissions
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.isGranted) {
        return true;
      }

      if (await Permission.photos.isGranted &&
          await Permission.videos.isGranted &&
          await Permission.audio.isGranted) {
        return true;
      }

      final Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        Permission.manageExternalStorage,
        Permission.photos,
        Permission.videos,
        Permission.audio,
      ].request();

      return statuses[Permission.storage]?.isGranted ?? false;
    }
    return true;
  }

  // Scan network for available senders
  static Future<List<SenderModel>> scanForSenders() async {
    final List<SenderModel> senders = [];

    debugPrint('🔍 Scanning network...');

    final List<String> hosts = await NetworkService.scanNetwork();
    debugPrint('Found ${hosts.length} active hosts');

    for (String host in hosts) {
      final SenderModel? sender = await checkIfPhotonServer(host, 4040);
      if (sender != null) {
        senders.add(sender);
        debugPrint('✅ Found: ${sender.hostName} at ${sender.ip}');
      }
    }

    return senders;
  }

  // Check if host is a ZeroShare server
  static Future<SenderModel?> checkIfPhotonServer(String ip, int port) async {
    try {
      final Dio dio = Dio();
      final Response response = await dio.get(
        'http://$ip:$port/photon-server',
        options: Options(
          receiveTimeout: const Duration(seconds: 3),
          sendTimeout: const Duration(seconds: 3),
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.data);
        return SenderModel.fromJson(data);
      }
    } catch (e) {
      // Not a ZeroShare server
    }

    return null;
  }

  // Request connection to sender
  static Future<Map<String, dynamic>> requestConnection(
    SenderModel sender,
  ) async {
    try {
      final box = GetStorage();
      final String username = box.read('username') ?? 'User';

      final Dio dio = Dio();
      final Response response = await dio.get(
        'http://${sender.ip}:${sender.port}/get-code',
        options: Options(
          headers: {'receiver-name': username, 'os': Platform.operatingSystem},
        ),
      );

      final Map<String, dynamic> data = jsonDecode(response.data);

      if (data['accepted'] == true) {
        return {'success': true, 'code': data['code']};
      } else {
        return {'success': false, 'error': 'Connection rejected'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Failed to connect: $e'};
    }
  }

  // Get list of files from sender
  static Future<List<String>> getFileList(SenderModel sender) async {
    try {
      final Dio dio = Dio();
      final Response response = await dio.get(
        'http://${sender.ip}:${sender.port}/getpaths',
      );

      if (response.statusCode != 200) {
        Get.snackbar('Alert Message', 'User has stopped sharing');

        return [];
      }

      final Map<String, dynamic> data = jsonDecode(response.data);
      final List<String> filePaths = List<String>.from(data['paths']);

      final List<String> fileNames = [];
      for (String filePath in filePaths) {
        final String separator = sender.os == 'windows' ? '\\' : '/';
        fileNames.add(filePath.split(separator).last);
      }

      return fileNames;
    } catch (e) {
      Get.until((r) => r.isFirst);
      Get.snackbar('Alert Message', 'User has stopped sharing');
      debugPrint('Error getting file list: $e');
      return [];
    }
  }

  // Notify sender that transfer is starting
  static Future<void> notifyTransferStart(
    SenderModel sender,
    int secretCode,
  ) async {
    try {
      final Dio dio = Dio();
      await dio.post(
        'http://${sender.ip}:${sender.port}/start-transfer',
        options: Options(
          headers: {
            'receiver-id': DateTime.now().millisecondsSinceEpoch.toString(),
          },
        ),
      );
      debugPrint('✅ Notified sender about transfer start');
    } catch (e) {
      debugPrint('⚠️ Failed to notify sender: $e');
    }
  }

  // Main receive files method
  static Future<void> receiveFiles(
    SenderModel sender,
    int secretCode,
    FileController controller,
  ) async {
    final bool hasPermission = await requestStoragePermission();
    if (!hasPermission) {
      debugPrint('❌ Storage permission denied');
      return;
    }

    try {
      final List<String> fileNames = await getFileList(sender);

      if (fileNames.isEmpty) {
        debugPrint('No files to receive');
        return;
      }

      controller.reset();
      controller.initializeForFiles(fileNames.length);

      // Notify sender that transfer is starting
      await notifyTransferStart(sender, secretCode);

      // Download each file
      for (int i = 0; i < fileNames.length; i++) {
        if (!controller.cancelledList[i]) {
          await _downloadFile(sender, secretCode, i, fileNames[i], controller);
        }
      }

      controller.isFinished.value = true;
      debugPrint('✅ All files received!');
    } catch (e) {
      debugPrint('Error during receive: $e');
    }
  }

  // Download individual file
  static Future<void> _downloadFile(
    SenderModel sender,
    int secretCode,
    int fileIndex,
    String fileName,
    FileController controller,
  ) async {
    final Dio dio = Dio();

    try {
      // Determine file type and get appropriate directory
      final String fileType = _getFileType(fileName);
      final Directory saveDir = await _getSaveDirectoryByType(fileType);
      String savePath = path.join(saveDir.path, fileName);
      savePath = await _getUniquePath(savePath);

      debugPrint('📥 Downloading to: $savePath');

      controller.updateStatus(fileIndex, FileStatus.downloading);

      final Stopwatch stopwatch = Stopwatch()..start();
      int lastReceived = 0;
      int lastTime = 0;
      int speedUpdateCounter = 0;

      _sendStatusUpdate(sender, fileIndex, false);

      // Download file
      await dio.download(
        'http://${sender.ip}:${sender.port}/$secretCode/$fileIndex',
        savePath,
        cancelToken: controller.cancelTokens[fileIndex],
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final double progress = (received / total) * 100;
            controller.updateProgress(fileIndex, progress);

            speedUpdateCounter++;
            if (speedUpdateCounter % 10 == 0) {
              final int currentTime = stopwatch.elapsedMilliseconds;
              final int timeDiff = currentTime - lastTime;
              final int receivedDiff = received - lastReceived;

              if (timeDiff > 0) {
                final double speed = (receivedDiff / timeDiff) * 1000;
                controller.updateSpeed(speed);

                final int remaining = total - received;
                if (speed > 0) {
                  final int estimatedSeconds = (remaining / speed).round();
                  controller.estimatedTime.value = controller.formatTime(
                    estimatedSeconds,
                  );
                }
              }

              lastReceived = received;
              lastTime = currentTime;
            }
          }
        },
      );

      // Verify file exists
      final File downloadedFile = File(savePath);
      if (await downloadedFile.exists()) {
        final int fileSize = await downloadedFile.length();
        debugPrint('✅ Downloaded: $fileName ($fileSize bytes) at $savePath');

        controller.updateStatus(fileIndex, FileStatus.downloaded);
        controller.totalTimeElapsed.value += stopwatch.elapsed.inSeconds;

        // ⭐ CRITICAL: Scan file for gallery/file manager
        await _scanMediaFile(savePath, fileName, fileType);

        // Save to history
        await HistoryService.addHistory(
          TransferHistory(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            fileName: fileName,
            filePath: savePath,
            fileSize: fileSize,
            senderName: sender.hostName,
            senderIP: sender.ip,
            timestamp: DateTime.now(),
            isReceived: true,
            isSuccess: true,
          ),
        );

        _sendStatusUpdate(sender, fileIndex, true);
      } else {
        debugPrint('❌ File not found after download: $savePath');
        controller.updateStatus(fileIndex, FileStatus.error);
      }
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        controller.updateStatus(fileIndex, FileStatus.cancelled);
        debugPrint('Cancelled: $fileName');
      } else {
        controller.updateStatus(fileIndex, FileStatus.error);
        debugPrint('Error downloading: $e');
      }
    } catch (e) {
      controller.updateStatus(fileIndex, FileStatus.error);
      debugPrint('Unexpected error: $e');
    }
  }

  // ⭐ Determine file type from extension
  static String _getFileType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    // Images
    if ([
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
      'bmp',
      'heic',
      'heif',
    ].contains(extension)) {
      return 'Images';
    }
    // Videos
    else if ([
      'mp4',
      'avi',
      'mkv',
      'mov',
      'wmv',
      'flv',
      '3gp',
      'webm',
      'm4v',
    ].contains(extension)) {
      return 'Videos';
    }
    // Audio
    else if ([
      'mp3',
      'wav',
      'aac',
      'm4a',
      'flac',
      'ogg',
      'wma',
      'opus',
    ].contains(extension)) {
      return 'Audios';
    }
    // Documents
    else if (['pdf', 'doc', 'docx', 'txt', 'rtf', 'odt'].contains(extension)) {
      return 'Documents';
    }
    // Archives
    else if (['zip', 'rar', '7z', 'tar', 'gz', 'bz2'].contains(extension)) {
      return 'Archives';
    }
    // APK
    else if (extension == 'apk') {
      return 'APKs';
    }
    // Others
    else {
      return 'Others';
    }
  }

  // ⭐ Get save directory based on file type
  static Future<Directory> _getSaveDirectoryByType(String fileType) async {
    Directory baseDir;

    if (Platform.isAndroid) {
      // Use DCIM for media files (shows in gallery)
      if (['Images', 'Videos'].contains(fileType)) {
        baseDir = Directory('/storage/emulated/0/DCIM');
      }
      // Use Music for audio files
      else if (fileType == 'Audios') {
        baseDir = Directory('/storage/emulated/0/Music');
      }
      // Use Documents for documents
      else if (fileType == 'Documents') {
        baseDir = Directory('/storage/emulated/0/Documents');
      }
      // Use Download for everything else
      else {
        final List<Directory> possibleDirs = [
          Directory('/storage/emulated/0/Download'),
          Directory('/storage/emulated/0/Downloads'),
        ];

        baseDir = possibleDirs[0];
        for (var dir in possibleDirs) {
          if (await dir.exists()) {
            baseDir = dir;
            break;
          }
        }
      }

      // Fallback if directory doesn't exist
      if (!await baseDir.exists()) {
        baseDir =
            await getExternalStorageDirectory() ??
            await getApplicationDocumentsDirectory();
      }
    } else if (Platform.isIOS) {
      baseDir = await getApplicationDocumentsDirectory();
    } else {
      baseDir =
          await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
    }

    // Create ZeroShare subfolder
    final Directory saveDir = Directory(
      path.join(baseDir.path, 'ZeroShare', fileType),
    );

    if (!await saveDir.exists()) {
      await saveDir.create(recursive: true);
      debugPrint('📁 Created directory: ${saveDir.path}');
    }

    return saveDir;
  }

  // ⭐ Scan media file for gallery and file manager
  static Future<void> _scanMediaFile(
    String filePath,
    String fileName,
    String fileType,
  ) async {
    try {
      debugPrint('🔄 Scanning file for system: $fileName');

      // Method 1: Use MediaScanner plugin (works for all file types)
      await MediaScanner.loadMedia(path: filePath);
      debugPrint('✅ MediaScanner: File scanned successfully');

      // Method 2: Trigger Android MediaScanner via broadcast (backup)
      if (Platform.isAndroid) {
        await _triggerAndroidMediaScanner(filePath);
      }

      // Method 3: For images/videos, also try content resolver
      if (['Images', 'Videos'].contains(fileType) && Platform.isAndroid) {
        await _addToAndroidMediaStore(filePath, fileType);
      }

      debugPrint('✅ File is now visible in gallery and file managers');
    } catch (e) {
      debugPrint('⚠️ Failed to scan media file: $e');
      // Don't throw error, file is already saved successfully
    }
  }

  // Method to trigger Android MediaScanner via broadcast
  static Future<void> _triggerAndroidMediaScanner(String filePath) async {
    if (!Platform.isAndroid) return;

    try {
      // Use Process to send broadcast
      final result = await Process.run('am', [
        'broadcast',
        '-a',
        'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
        '-d',
        'file://$filePath',
      ]);

      if (result.exitCode == 0) {
        debugPrint('✅ Android MediaScanner triggered');
      } else {
        debugPrint('⚠️ MediaScanner broadcast failed: ${result.stderr}');
      }
    } catch (e) {
      debugPrint('⚠️ Failed to trigger MediaScanner: $e');
    }
  }

  // Method to add file to Android MediaStore
  static Future<void> _addToAndroidMediaStore(
    String filePath,
    String fileType,
  ) async {
    if (!Platform.isAndroid) return;

    try {
      // Send broadcast to refresh media
      await Process.run('am', [
        'broadcast',
        '-a',
        'android.intent.action.MEDIA_MOUNTED',
        '-d',
        'file:///storage/emulated/0',
      ]);
      debugPrint('✅ MediaStore refresh broadcast sent');
    } catch (e) {
      debugPrint('⚠️ Failed to refresh MediaStore: $e');
    }
  }

  // Send status update to sender
  static void _sendStatusUpdate(
    SenderModel sender,
    int fileIndex,
    bool isCompleted,
  ) {
    try {
      final box = GetStorage();
      final String username = box.read('username') ?? 'User';

      Dio().post(
        'http://${sender.ip}:${sender.port}/receiver-data',
        options: Options(
          headers: {
            'receiverID': _receiverID.toString(),
            'os': Platform.operatingSystem,
            'hostName': username,
            'currentFile': fileIndex.toString(),
            'isCompleted': isCompleted.toString(),
          },
        ),
      );
    } catch (e) {
      // Ignore network errors for status updates
    }
  }

  // Get unique file path to avoid overwriting
  static Future<String> _getUniquePath(String filePath) async {
    final File file = File(filePath);

    if (!await file.exists()) {
      return filePath;
    }

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

  // Utility: Get file size formatted
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
