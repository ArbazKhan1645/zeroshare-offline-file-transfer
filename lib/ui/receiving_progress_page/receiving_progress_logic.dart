// lib/ui/receiving_progress_page/receiving_progress_logic.dart
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:zero_share/controllers/file_controller.dart';

import 'package:zero_share/models/files_model.dart';
import 'package:zero_share/services/receiver_service.dart';

class ReceivingProgressLogic extends GetxController {
  final FileController fileController = FileController();

  SenderModel? sender;
  int? secretCode;
  List<String> fileNames = [];

  RxBool isLoading = true.obs;
  RxBool isReceiving = false.obs;

  @override
  void onInit() {
    super.onInit();

    try {
      final args = Get.arguments;

      if (args != null && args is Map<String, dynamic>) {
        try {
          sender = args['sender'];
          secretCode = args['secretCode'];
          debugPrint(
            'Receiving page initialized with sender: ${sender?.hostName}',
          );
          _loadFileList();
        } catch (e) {
          debugPrint('Error processing arguments: $e');

          try {
            Get.back();
          } catch (navError) {
            debugPrint(
              'Navigation error after args processing failure: $navError',
            );
          }
        }
      } else {
        debugPrint('No valid arguments provided to receiving page');

        try {
          Get.back();
        } catch (e) {
          debugPrint('Navigation error: $e');
        }
      }
    } catch (e) {
      debugPrint('Critical error in ReceivingProgressLogic onInit: $e');
    }
  }

  Future<void> _loadFileList() async {
    try {
      if (sender == null) {
        debugPrint('Cannot load file list - sender is null');

        return;
      }

      debugPrint('Loading file list from sender: ${sender!.hostName}');

      try {
        fileNames = await ReceiverService.getFileList(sender!);
        isLoading.value = false;
        update();
        debugPrint('File list loaded: ${fileNames.length} files');
      } catch (e) {
        debugPrint('Error getting file list: $e');

        isLoading.value = false;
        Get.snackbar('Error', 'Failed to load file list: $e');
        update();
      }
    } catch (e) {
      debugPrint('Critical error in _loadFileList: $e');

      isLoading.value = false;
      update();
    }
  }

  Future<void> startReceiving() async {
    try {
      if (sender == null || secretCode == null) {
        debugPrint('Cannot start receiving - sender or secret code is null');

        Get.snackbar('Error', 'Invalid connection parameters');
        return;
      }

      bool hasPermission;

      try {
        hasPermission = await ReceiverService.requestStoragePermission();
      } catch (e) {
        debugPrint('Error requesting storage permission: $e');

        Get.snackbar(
          'Permission Error',
          'Failed to request storage permission',
        );
        return;
      }

      if (!hasPermission) {
        debugPrint('Storage permission denied by user');

        Get.snackbar(
          'Permission Denied',
          'Storage permission required to save files',
        );
        return;
      }

      isReceiving.value = true;
      update();
      debugPrint('Starting file reception...');

      try {
        await ReceiverService.receiveFiles(
          sender!,
          secretCode!,
          fileController,
        );

        if (fileController.isFinished.value) {
          try {
            final int successCount = fileController.statusList
                .where((s) => s == FileStatus.downloaded)
                .length;

            debugPrint('Transfer complete: $successCount files received');

            Get.snackbar(
              'Transfer Complete',
              '$successCount file(s) received successfully',
              snackPosition: SnackPosition.BOTTOM,
            );
          } catch (e) {
            debugPrint('Error processing completion status: $e');
          }
        }
      } catch (e) {
        debugPrint('Error during file reception: $e');

        Get.snackbar('Error', 'Transfer failed: $e');
      }

      isReceiving.value = false;
      update();
    } catch (e) {
      debugPrint('Critical error in startReceiving: $e');

      isReceiving.value = false;
      update();
      Get.snackbar('Error', 'An unexpected error occurred');
    }
  }

  void finishAndGoBack() {
    try {
      debugPrint('Finishing and going back...');

      try {
        fileController.reset();
      } catch (e) {
        debugPrint('Error resetting file controller: $e');
      }

      try {
        Get.back();
      } catch (e) {
        debugPrint('Error navigating back: $e');
      }
    } catch (e) {
      debugPrint('Error in finishAndGoBack: $e');
    }
  }

  @override
  void onClose() {
    try {
      // Don't reset here to allow "Done" button to work
      super.onClose();
      debugPrint('ReceivingProgressLogic closed');
    } catch (e) {
      debugPrint('Error in ReceivingProgressLogic onClose: $e');

      try {
        super.onClose();
      } catch (superError) {
        debugPrint('Error calling super.onClose: $superError');
      }
    }
  }
}
