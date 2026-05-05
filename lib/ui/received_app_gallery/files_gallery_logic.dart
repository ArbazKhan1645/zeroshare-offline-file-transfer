// lib/ui/received_app_gallery/files_gallery_logic.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:zero_share/services/history_service.dart';

class FilesLogic extends GetxController {
  RxList<File> images = <File>[].obs;
  RxList<File> videos = <File>[].obs;
  RxList<File> audios = <File>[].obs;
  RxList<File> documents = <File>[].obs;
  RxList<File> others = <File>[].obs;
  RxList<File> recentFiles = <File>[].obs;

  // History data
  RxList<TransferHistory> allHistory = <TransferHistory>[].obs;

  // Categorized history
  RxList<TransferHistory> imageHistory = <TransferHistory>[].obs;
  RxList<TransferHistory> videoHistory = <TransferHistory>[].obs;
  RxList<TransferHistory> audioHistory = <TransferHistory>[].obs;
  RxList<TransferHistory> documentHistory = <TransferHistory>[].obs;

  @override
  void onInit() {
    super.onInit();

    try {
      loadHistory();
      loadFilesFromHistory();
      update();
      debugPrint('FilesLogic initialized');
    } catch (e) {
      debugPrint('Error in FilesLogic onInit: $e');
    }
  }

  Future<void> loadHistory() async {
    try {
      allHistory.value = await HistoryService.getAllHistory();

      try {
        // Filter only received files
        final receivedHistory = allHistory.where((h) => h.isReceived).toList();

        // Categorize history by file type
        imageHistory.value =
            receivedHistory.where((h) => _isImageFile(h.fileName)).toList();
        videoHistory.value =
            receivedHistory.where((h) => _isVideoFile(h.fileName)).toList();
        audioHistory.value =
            receivedHistory.where((h) => _isAudioFile(h.fileName)).toList();
        documentHistory.value =
            receivedHistory.where((h) => _isDocumentFile(h.fileName)).toList();

        update();
        debugPrint(
          'History loaded: ${allHistory.length} total, ${receivedHistory.length} received',
        );
      } catch (e) {
        debugPrint('Error categorizing history: $e');
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
    }
  }

  void loadFilesFromHistory() async {
    try {
      final List<File> imageFiles = [];
      final List<File> videoFiles = [];
      final List<File> audioFiles = [];
      final List<File> documentFiles = [];
      final List<File> otherFiles = [];

      // Get all received files from history
      final receivedHistory = allHistory.where((h) => h.isReceived).toList();

      for (var history in receivedHistory) {
        try {
          final File file = File(history.filePath);

          // Check if file still exists
          bool exists;
          try {
            exists = await file.exists();
          } catch (e) {
            debugPrint('Error checking file existence: ${history.filePath}');

            continue;
          }

          if (exists) {
            try {
              // Categorize by file extension
              final String extensions =
                  history.filePath.split('.').last.toLowerCase();

              if (_isImageExtension(extensions)) {
                imageFiles.add(file);
              } else if (_isVideoExtension(extensions)) {
                videoFiles.add(file);
              } else if (_isAudioExtension(extensions)) {
                audioFiles.add(file);
              } else if (_isDocumentExtension(extensions)) {
                documentFiles.add(file);
              } else {
                otherFiles.add(file);
              }
            } catch (e) {
              debugPrint('Error categorizing file: ${history.filePath}');
            }
          } else {
            // File no longer exists
            debugPrint('⚠️ File not found: ${history.filePath}');
          }
        } catch (e) {
          debugPrint('Error processing history item: $e');
        }
      }

      // Sort by last modified date (newest first)
      try {
        imageFiles.sort(
          (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
        );
      } catch (e) {
        debugPrint('Error sorting image files: $e');
      }

      try {
        videoFiles.sort(
          (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
        );
      } catch (e) {
        debugPrint('Error sorting video files: $e');
      }

      try {
        audioFiles.sort(
          (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
        );
      } catch (e) {
        debugPrint('Error sorting audio files: $e');
      }

      try {
        documentFiles.sort(
          (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
        );
      } catch (e) {
        debugPrint('Error sorting document files: $e');
      }

      // Update observable lists
      images.value = imageFiles;
      videos.value = videoFiles;
      audios.value = audioFiles;
      documents.value = documentFiles;
      others.value = otherFiles;

      // Merge and sort recent files
      try {
        final List<File> allFiles = [
          ...imageFiles,
          ...videoFiles,
          ...audioFiles,
          ...documentFiles,
          ...otherFiles,
        ];

        allFiles.sort(
          (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
        );

        // Keep only the latest 10 files
        recentFiles.value = allFiles.take(10).toList();
      } catch (e) {
        debugPrint('Error creating recent files list: $e');
      }

      update();
      debugPrint(
        'Files loaded - Images: ${imageFiles.length}, Videos: ${videoFiles.length}, Audios: ${audioFiles.length}, Docs: ${documentFiles.length}',
      );
    } catch (e) {
      debugPrint('Critical error in loadFilesFromHistory: $e');
    }
  }

  bool _isImageFile(String fileName) {
    try {
      final extension = fileName.split('.').last.toLowerCase();
      return _isImageExtension(extension);
    } catch (e) {
      debugPrint('Error checking image file: $e');

      return false;
    }
  }

  bool _isVideoFile(String fileName) {
    try {
      final extension = fileName.split('.').last.toLowerCase();
      return _isVideoExtension(extension);
    } catch (e) {
      debugPrint('Error checking video file: $e');

      return false;
    }
  }

  bool _isAudioFile(String fileName) {
    try {
      final extension = fileName.split('.').last.toLowerCase();
      return _isAudioExtension(extension);
    } catch (e) {
      debugPrint('Error checking audio file: $e');

      return false;
    }
  }

  bool _isDocumentFile(String fileName) {
    try {
      final extension = fileName.split('.').last.toLowerCase();
      return _isDocumentExtension(extension);
    } catch (e) {
      debugPrint('Error checking document file: $e');

      return false;
    }
  }

  bool _isImageExtension(String ext) {
    return [
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
      'bmp',
      'heic',
      'heif',
      'svg',
      'ico',
    ].contains(ext);
  }

  bool _isVideoExtension(String ext) {
    return [
      'mp4',
      'avi',
      'mkv',
      'mov',
      'wmv',
      'flv',
      '3gp',
      'webm',
      'm4v',
      'mpeg',
      'mpg',
    ].contains(ext);
  }

  bool _isAudioExtension(String ext) {
    return [
      'mp3',
      'wav',
      'aac',
      'm4a',
      'flac',
      'ogg',
      'wma',
      'opus',
      'aiff',
      'ape',
    ].contains(ext);
  }

  bool _isDocumentExtension(String ext) {
    return [
      'pdf',
      'doc',
      'docx',
      'txt',
      'rtf',
      'odt',
      'xls',
      'xlsx',
      'ppt',
      'pptx',
      'csv',
    ].contains(ext);
  }

  String getFileType(String fileName) {
    try {
      final extension = fileName.split('.').last.toLowerCase();

      if (_isImageExtension(extension)) return 'Image';
      if (_isVideoExtension(extension)) return 'Video';
      if (_isAudioExtension(extension)) return 'Audio';
      if (_isDocumentExtension(extension)) return 'Document';
      if (extension == 'apk') return 'APK';
      if (['zip', 'rar', '7z', 'tar', 'gz'].contains(extension)) {
        return 'Archive';
      }

      return 'File';
    } catch (e) {
      debugPrint('Error getting file type: $e');

      return 'File';
    }
  }

  String getFileIcon(String fileName) {
    try {
      final extension = fileName.split('.').last.toLowerCase();

      if (_isImageExtension(extension)) return '🖼️';
      if (_isVideoExtension(extension)) return '🎥';
      if (_isAudioExtension(extension)) return '🎵';
      if (_isDocumentExtension(extension)) return '📄';
      if (extension == 'apk') return '📦';
      if (['zip', 'rar', '7z', 'tar', 'gz'].contains(extension)) return '🗜️';

      return '📁';
    } catch (e) {
      debugPrint('Error getting file icon: $e');

      return '📁';
    }
  }

  void navigateToGallery(String type) {
    try {
      switch (type) {
        case 'Images':
          Get.toNamed('/gallery_images');
          break;
        case 'Videos':
          Get.toNamed('/gallery_videos');
          break;
        case 'Audios':
          Get.toNamed('/gallery_audios');
          break;
        case 'Documents':
          Get.toNamed('/gallery_documents');
          break;
      }
      debugPrint('Navigated to $type gallery');
    } catch (e) {
      debugPrint('Error navigating to gallery: $e');
    }
  }

  int getFileCount(String type) {
    try {
      switch (type) {
        case 'Images':
          return images.length;
        case 'Videos':
          return videos.length;
        case 'Audios':
          return audios.length;
        case 'Documents':
          return documents.length;
        case 'Others':
          return others.length;
        default:
          return 0;
      }
    } catch (e) {
      debugPrint('Error getting file count: $e');

      return 0;
    }
  }

  int getTotalSize(String type) {
    try {
      List<File> files;
      switch (type) {
        case 'Images':
          files = images;
          break;
        case 'Videos':
          files = videos;
          break;
        case 'Audios':
          files = audios;
          break;
        case 'Documents':
          files = documents;
          break;
        default:
          files = [];
      }

      return files.fold(0, (sum, file) {
        try {
          return sum + file.lengthSync();
        } catch (e) {
          debugPrint('Error getting file size: ${file.path}');
          return sum;
        }
      });
    } catch (e) {
      debugPrint('Error getting total size: $e');

      return 0;
    }
  }

  String formatSize(int bytes) {
    try {
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(2)} KB';
      }
      if (bytes < 1024 * 1024 * 1024) {
        return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
      }
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    } catch (e) {
      debugPrint('Error formatting size: $e');

      return '$bytes B';
    }
  }

  Future<void> cleanupHistory() async {
    try {
      final receivedHistory = allHistory.where((h) => h.isReceived).toList();
      int deletedCount = 0;

      for (var history in receivedHistory) {
        try {
          final File file = File(history.filePath);

          // If file doesn't exist, remove from history
          bool exists;
          try {
            exists = await file.exists();
          } catch (e) {
            debugPrint('Error checking file existence during cleanup: $e');

            continue;
          }

          if (!exists) {
            try {
              await HistoryService.deleteHistory(history.id);
              deletedCount++;
              debugPrint(
                '🗑️ Removed non-existent file from history: ${history.fileName}',
              );
            } catch (e) {
              debugPrint('Error deleting history item: $e');
            }
          }
        } catch (e) {
          debugPrint('Error processing cleanup for history item: $e');
        }
      }

      // Reload after cleanup
      await loadHistory();
      loadFilesFromHistory();

      debugPrint('Cleanup completed: $deletedCount items removed');
    } catch (e) {
      debugPrint('Critical error in cleanupHistory: $e');
    }
  }

  @override
  void onClose() {
    try {
      super.onClose();
      debugPrint('FilesLogic closed');
    } catch (e) {
      debugPrint('Error in FilesLogic onClose: $e');

      try {
        super.onClose();
      } catch (superError) {
        debugPrint('Error calling super.onClose: $superError');
      }
    }
  }
}
