// lib/ui/sending_progress_page/sending_progress_logic.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:zero_share/services/sender_service.dart';
import 'package:zero_share/utils/utils.dart';

class SendingProgressLogic extends GetxController {
  List<File> filesToSend = [];
  RxBool isServerRunning = false.obs;
  RxString serverIP = ''.obs;
  RxInt serverPort = 0.obs;
  RxInt secretCode = 0.obs;
  RxString qrData = ''.obs;

  @override
  void onReady() async {
    super.onReady();
    try {
      final data = Get.arguments as List<File>?;

      if (data == null || data.isEmpty) {
        debugPrint('No files selected for sending');
        await Utils.showToast(null, 'No files selected to send');

        try {
          Get.back();
        } catch (e) {
          debugPrint('Error navigating back: $e');
        }
        return;
      } else {
        await Utils.showToast(null, '${data.length} files selected to send');
        debugPrint('${data.length} files selected for sending');
      }

      filesToSend = data;
      await _startServer();
    } catch (e) {
      debugPrint('Critical error in SendingProgressLogic onReady: $e');

      await Utils.showToast(null, 'Failed to initialize sending');

      try {
        Get.back();
      } catch (navError) {
        debugPrint('Navigation error in catch block: $navError');
      }
    }
  }

  Future<void> _startServer() async {
    try {
      debugPrint('Starting server for ${filesToSend.length} files');
      Map<String, dynamic> result;

      try {
        result = await SenderService.startServer(filesToSend);
      } catch (e) {
        debugPrint('SenderService.startServer error: $e');

        await Utils.showToast(null, 'Failed to start server: ${e.toString()}');

        try {
          Get.back();
        } catch (navError) {
          debugPrint('Navigation error after server start failure: $navError');
        }
        return;
      }

      if (result['success'] == true) {
        try {
          isServerRunning.value = true;
          serverIP.value = result['ip'];
          serverPort.value = result['port'];
          secretCode.value = result['code'];
          qrData.value =
              '${serverIP.value}:${serverPort.value}:${secretCode.value}';

          update();
          debugPrint('Server started successfully: ${qrData.value}');
        } catch (e) {
          debugPrint('Error processing server result: $e');

          await Utils.showToast(null, 'Server started but setup failed');

          try {
            Get.back();
          } catch (navError) {
            debugPrint('Navigation error after setup failure: $navError');
          }
        }
      } else {
        final String errorMsg = result['error'] ?? 'Failed to start server';
        debugPrint('Server start failed: $errorMsg');

        await Utils.showToast(null, errorMsg);

        try {
          Get.back();
        } catch (navError) {
          debugPrint('Navigation error after server failure: $navError');
        }
      }
    } catch (e) {
      debugPrint('Critical error in _startServer: $e');

      await Utils.showToast(null, 'An unexpected error occurred');

      try {
        Get.back();
      } catch (navError) {
        debugPrint('Navigation error in critical catch: $navError');
      }
    }
  }

  void stopServer() async {
    try {
      debugPrint('Stopping sending server...');

      try {
        await SenderService.stopServer();
        isServerRunning.value = false;
        debugPrint('Sending server stopped successfully');
      } catch (e) {
        debugPrint('Error stopping server: $e');

        // Still update state
        isServerRunning.value = false;
      }

      try {
        Get.back();
      } catch (e) {
        debugPrint('Error navigating back: $e');
      }
    } catch (e) {
      debugPrint('Critical error in stopServer: $e');

      // Fallback: still try to update state and navigate
      try {
        isServerRunning.value = false;
        Get.back();
      } catch (fallbackError) {
        debugPrint('Fallback also failed: $fallbackError');
      }
    }
  }

  @override
  void onClose() {
    try {
      if (isServerRunning.value) {
        try {
          SenderService.stopServer();
          debugPrint('Server stopped during onClose');
        } catch (e) {
          debugPrint('Error stopping server in onClose: $e');
        }
      }

      super.onClose();
      debugPrint('SendingProgressLogic closed');
    } catch (e) {
      debugPrint('Error in SendingProgressLogic onClose: $e');

      try {
        super.onClose();
      } catch (superError) {
        debugPrint('Error calling super.onClose: $superError');
      }
    }
  }
}
