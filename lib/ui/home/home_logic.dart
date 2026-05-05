// lib/ui/home/home_logic.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:zero_share/models/files_model.dart';
import 'package:zero_share/services/history_service.dart';

class HomeLogic extends GetxController {
  List<FileModel> myFiles = [];
  int savePercentage = 5;

  RxList<TransferHistory> recentHistory = <TransferHistory>[].obs;

  // Stream subscription for real-time updates
  StreamSubscription<List<TransferHistory>>? _historySubscription;

  @override
  void onInit() {
    super.onInit();

    try {
      myFiles = [];

      // Initial load with error handling
      try {
        loadRecentHistory();
      } catch (e) {
        debugPrint('Error during initial history load: $e');
      }

      // Start listening to history stream for real-time updates
      try {
        _startListeningToHistoryStream();
      } catch (e) {
        debugPrint('Error starting history stream: $e');
      }

      // Uncomment when needed
      // Future.delayed(const Duration(milliseconds: 500), () {
      //   if (AdMobService.instance.isAppOpenAdsPaused) return;
      //   AdMobService.instance.showAppOpenAd();
      // });

      update();
      debugPrint('onInit completed successfully with stream listener');
    } catch (e) {
      debugPrint('Critical error during onInit: $e');
    }
  }

  /// Listen to HistoryService stream for automatic updates
  void _startListeningToHistoryStream() {
    try {
      _historySubscription = HistoryService.historyStream.listen(
        (updatedHistory) {
          try {
            debugPrint(
              '🔥 History stream updated - ${updatedHistory.length} items',
            );

            // Update recent history (take only first 5)
            recentHistory.value = updatedHistory.take(5).toList();

            // Trigger UI update
            update();
          } catch (e) {
            debugPrint('Error processing history stream data: $e');
          }
        },
        onError: (error, stack) {
          debugPrint('❌ Error in history stream: $error');
        },
        cancelOnError: false,
      );

      debugPrint('✅ Started listening to history stream');
    } catch (e) {
      debugPrint('Failed to start history stream listener: $e');
    }
  }

  /// Stop listening to stream
  void _stopListeningToHistoryStream() {
    try {
      _historySubscription?.cancel();
      _historySubscription = null;
      debugPrint('❌ Stopped listening to history stream');
    } catch (e) {
      debugPrint('Error stopping history stream: $e');
    }
  }

  List<String> get recentImagePaths {
    try {
      final paths = recentHistory
          .where(
            (file) =>
                file.filePath.toLowerCase().endsWith('.jpg') ||
                file.filePath.toLowerCase().endsWith('.png') ||
                file.filePath.toLowerCase().endsWith('.jpeg') ||
                file.filePath.toLowerCase().endsWith('.webp'),
          )
          .map((file) => file.filePath)
          .take(6)
          .toList();
      debugPrint('Recent image paths loaded: ${paths.length}');
      return paths;
    } catch (e) {
      debugPrint('Error getting recent image paths: $e');

      return [];
    }
  }

  Future<void> loadRecentHistory() async {
    try {
      final allHistory = await HistoryService.getAllHistory();

      try {
        recentHistory.value = allHistory.take(5).toList();
        debugPrint('✅ Loaded ${recentHistory.length} recent history entries');
        update();
      } catch (e) {
        debugPrint('Error updating recent history value: $e');
      }
    } catch (e) {
      debugPrint('Error loading recent history: $e');

      try {
        recentHistory.clear();
      } catch (clearError) {
        debugPrint('Error clearing recent history: $clearError');
      }
    }
  }

  /// Manual refresh method for pull-to-refresh
  Future<void> refreshHistory() async {
    try {
      debugPrint('🔄 Manual refresh triggered');
      await loadRecentHistory();
    } catch (e) {
      debugPrint('Error during manual refresh: $e');
    }
  }

  Future<List<File>> fetchRecentFiles() async {
    final List<File> allFiles = [];
    debugPrint('Fetching recent files from storage...');

    try {
      final imageDir = Directory('/storage/emulated/0/DCIM/ZeroShare/Images');
      final videoDir = Directory('/storage/emulated/0/DCIM/ZeroShare/Videos');
      final audioDir = Directory('/storage/emulated/0/DCIM/ZeroShare/Audios');

      Future<void> addFilesFromDir(Directory dir, String name) async {
        try {
          if (await dir.exists()) {
            try {
              final dirFiles = dir.listSync().whereType<File>().toList();
              allFiles.addAll(dirFiles);
              debugPrint('Added ${dirFiles.length} $name files');
            } catch (e) {
              debugPrint('Error listing files in $name directory: $e');
            }
          } else {
            debugPrint('Directory not found: ${dir.path}');
          }
        } catch (e) {
          debugPrint('Error reading $name directory: $e');
        }
      }

      await addFilesFromDir(imageDir, 'image');
      await addFilesFromDir(videoDir, 'video');
      await addFilesFromDir(audioDir, 'audio');

      try {
        allFiles.sort(
          (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
        );
        debugPrint('Total files found: ${allFiles.length}');
      } catch (e) {
        debugPrint('Error sorting files: $e');
      }

      return allFiles.take(6).toList();
    } catch (e) {
      debugPrint('Critical error fetching recent files: $e');

      return [];
    }
  }

  @override
  void onReady() {
    super.onReady();
    try {
      debugPrint('HomeLogic ready');
    } catch (e) {
      debugPrint('Error in onReady: $e');
    }
  }

  @override
  void onClose() {
    try {
      // Clean up stream subscription
      _stopListeningToHistoryStream();

      super.onClose();
      debugPrint('HomeLogic closed and stream listener disposed');
    } catch (e) {
      debugPrint('Error during onClose: $e');

      // Still call super.onClose even if there's an error
      try {
        super.onClose();
      } catch (superError) {
        debugPrint('Error calling super.onClose: $superError');
      }
    }
  }
}
