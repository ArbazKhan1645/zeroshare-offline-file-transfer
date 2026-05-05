// lib/ui/qr_code_page/qr_code_logic.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:zero_share/services/sender_service.dart';

class QrCodeLogic extends GetxController {
  String qrData = '';
  RxBool isServerRunning = false.obs;
  String? serverIP;
  int? serverPort;
  int? secretCode;

  List<File>? filesToSend;

  @override
  void onInit() {
    super.onInit();
    try {
      // Get files from arguments if available
      final args = Get.arguments;
      if (args != null && args is List<File>) {
        filesToSend = args;
        startServerAndGenerateQR();
        debugPrint(
          'QR Code page initialized with ${filesToSend?.length} files',
        );
      } else {
        debugPrint('No files provided in arguments');
      }
    } catch (e) {
      debugPrint('Error in QrCodeLogic onInit: $e');
    }
  }

  Future<void> startServerAndGenerateQR() async {
    try {
      if (filesToSend == null || filesToSend!.isEmpty) {
        debugPrint('No files selected for QR generation');
        Get.snackbar('Error', 'No files selected');

        return;
      }

      debugPrint('Starting server for ${filesToSend!.length} files');
      Map<String, dynamic> result;

      try {
        result = await SenderService.startServer(filesToSend!);
      } catch (e) {
        debugPrint('SenderService.startServer error: $e');

        Get.snackbar('Error', 'Failed to start server: ${e.toString()}');
        return;
      }

      if (result['success'] == true) {
        try {
          isServerRunning.value = true;
          serverIP = result['ip'];
          serverPort = result['port'];
          secretCode = result['code'];

          // Generate QR data: IP:PORT:CODE
          qrData = '$serverIP:$serverPort:$secretCode';

          update();
          debugPrint('QR Code generated: $qrData');
        } catch (e) {
          debugPrint('Error processing server result: $e');

          Get.snackbar('Error', 'Server started but QR generation failed');
        }
      } else {
        final String errorMsg = result['error'] ?? 'Failed to start server';
        debugPrint('Server start failed: $errorMsg');

        Get.snackbar('Error', errorMsg);
      }
    } catch (e) {
      debugPrint('Critical error in startServerAndGenerateQR: $e');

      Get.snackbar('Error', 'An unexpected error occurred');
    }
  }

  void stopServer() async {
    try {
      debugPrint('Stopping server...');
      await SenderService.stopServer();
      isServerRunning.value = false;
      debugPrint('Server stopped successfully');

      try {
        Get.back();
      } catch (e) {
        debugPrint('Error navigating back: $e');
      }
    } catch (e) {
      debugPrint('Error stopping server: $e');

      // Still try to update state and navigate
      try {
        isServerRunning.value = false;
        Get.back();
      } catch (fallbackError) {
        debugPrint('Fallback error: $fallbackError');
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
      debugPrint('QrCodeLogic closed');
    } catch (e) {
      debugPrint('Error in onClose: $e');

      try {
        super.onClose();
      } catch (superError) {
        debugPrint('Error calling super.onClose: $superError');
      }
    }
  }
}
