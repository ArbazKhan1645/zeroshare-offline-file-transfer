import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:zero_share/models/files_model.dart';
import 'package:zero_share/services/receiver_service.dart';
import 'package:zero_share/routes/app_routes.dart';
import 'package:flutter/material.dart';

class ScannerLogic extends GetxController {
  final MobileScannerController mobileScanner = MobileScannerController();

  @override
  void onInit() async {
    super.onInit();
    try {
      await _requestPermissions();

      try {
        // open a scanner screen manually since mobile_scanner doesn't have .scan()
        await Get.to(
          () => _ScannerView(
            scannerController: mobileScanner,
            onScanned: (code) {
              try {
                if (code.isNotEmpty) {
                  handleScannedData(code);
                } else {
                  debugPrint('Empty QR code scanned');
                  Get.back();
                }
              } catch (e) {
                debugPrint('Error in onScanned callback: $e');

                Get.back();
              }
            },
          ),
        );
      } catch (e) {
        debugPrint('Scanner error: $e');

        Get.back();
      }

      update();
    } catch (e) {
      debugPrint('Critical error in ScannerLogic onInit: $e');
    }
  }

  Future<bool> _requestPermissions() async {
    try {
      if (!Platform.isAndroid) {
        debugPrint('Not Android platform, skipping Android permissions');
        return false;
      }

      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo;

      try {
        androidInfo = await deviceInfo.androidInfo;
      } catch (e) {
        debugPrint('Error getting Android device info: $e');

        return false;
      }

      final int sdkInt = androidInfo.version.sdkInt;
      debugPrint('Android SDK version: $sdkInt');

      final List<Permission> permissionsToRequest = [Permission.camera];

      Map<Permission, PermissionStatus> statuses;

      try {
        statuses = await permissionsToRequest.request();
      } catch (e) {
        debugPrint('Error requesting permissions: $e');

        return false;
      }

      for (var permission in permissionsToRequest) {
        if (statuses[permission]?.isDenied ?? false) {
          debugPrint('Required permissions denied: ${permission.toString()}');

          return false;
        }
      }

      debugPrint('Required permissions GRANTED');

      return true;
    } catch (e) {
      debugPrint('Critical error in _requestPermissions: $e');

      return false;
    }
  }

  void handleScannedData(String scannedData) async {
    try {
      debugPrint('Handling scanned data: $scannedData');

      // QR format: IP:PORT:SECRET_CODE
      List<String> parts;

      try {
        parts = scannedData.split(':');
      } catch (e) {
        debugPrint('Error splitting scanned data: $e');

        Get.snackbar('Error', 'Invalid QR code format');
        Get.back();
        return;
      }

      if (parts.length != 3) {
        debugPrint(
          'Invalid QR code format - expected 3 parts, got ${parts.length}',
        );

        Get.snackbar('Error', 'Invalid QR code format');
        Get.back();
        return;
      }

      final String ip = parts[0];
      int port;
      int code;

      try {
        port = int.parse(parts[1]);
        code = int.parse(parts[2]);
      } catch (e) {
        debugPrint('Error parsing port/code: $e');

        Get.snackbar('Error', 'Invalid QR code data');
        Get.back();
        return;
      }

      debugPrint('Connecting to sender: $ip:$port with code: $code');
      SenderModel? sender;

      try {
        sender = await ReceiverService.checkIfPhotonServer(ip, port);
      } catch (e) {
        debugPrint('Error checking server: $e');

        Get.snackbar('Error', 'Could not connect to sender');
        Get.back();
        return;
      }

      if (sender != null) {
        try {
          debugPrint('Sender found, navigating to receiving page');
          await Get.offNamed(
            AppRoutes.receivingProgressPage,
            arguments: {'sender': sender, 'secretCode': code},
          );
        } catch (e) {
          debugPrint('Error navigating to receiving page: $e');

          Get.snackbar('Error', 'Navigation failed');
          Get.back();
        }
      } else {
        debugPrint('Could not connect to sender');

        Get.snackbar('Error', 'Could not connect to sender');
        Get.back();
      }
    } catch (e) {
      debugPrint('Critical error in handleScannedData: $e');

      Get.snackbar('Error', 'Invalid QR Code: $e');
      Get.back();
    }
  }

  @override
  void onClose() {
    try {
      mobileScanner.dispose();
      super.onClose();
      debugPrint('ScannerLogic closed');
    } catch (e) {
      debugPrint('Error in ScannerLogic onClose: $e');

      try {
        super.onClose();
      } catch (superError) {
        debugPrint('Error calling super.onClose: $superError');
      }
    }
  }
}

class _ScannerView extends StatelessWidget {
  final MobileScannerController scannerController;
  final Function(String) onScanned;

  const _ScannerView({
    required this.scannerController,
    required this.onScanned,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () {
              try {
                scannerController.toggleTorch();
              } catch (e) {
                debugPrint('Error toggling torch: $e');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () {
              try {
                scannerController.switchCamera();
              } catch (e) {
                debugPrint('Error switching camera: $e');
              }
            },
          ),
        ],
      ),
      body: MobileScanner(
        controller: scannerController,
        onDetect: (BarcodeCapture capture) {
          try {
            final code = capture.barcodes.first.rawValue ?? '';
            if (code.isNotEmpty) {
              onScanned(code);
              Get.back(); // close after scanning once
            }
          } catch (e) {
            debugPrint('Error in onDetect: $e');
          }
        },
      ),
    );
  }
}
