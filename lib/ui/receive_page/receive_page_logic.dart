// lib/ui/receive_page/receive_page_logic.dart
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zero_share/controllers/file_controller.dart';
import 'package:zero_share/models/files_model.dart';
import 'package:zero_share/services/receiver_service.dart';
import 'package:zero_share/routes/app_routes.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ReceivePageLogic extends GetxController
    with GetSingleTickerProviderStateMixin {
  AnimationController? radarController;
  RxBool isStartDiscovery = false.obs;
  RxList<SenderModel> discoveredDevices = <SenderModel>[].obs;
  RxBool isScanning = false.obs;

  final FileController fileController = FileController();
  MobileScannerController? qrScannerController;

  // Add these variables for periodic scanning
  Timer? _discoveryTimer;
  Timer? _countdownTimer;
  int discoveryTimeLeft = 30;
  static const int _scanInterval = 3; // Scan every 3 seconds
  static const int _discoveryDuration = 30; // Total discovery duration
  bool _isScanning = false; // Prevent overlapping scans

  @override
  void onInit() async {
    super.onInit();

    radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    await radarController?.repeat();
    update();
  }

  @override
  void onClose() {
    _discoveryTimer?.cancel();
    _countdownTimer?.cancel();
    radarController?.dispose();
    qrScannerController?.dispose();
    super.onClose();
  }

  Future<bool> _requestPermissions() async {
    if (!Platform.isAndroid) return false;

    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final int sdkInt = androidInfo.version.sdkInt;

    final List<Permission> permissionsToRequest = [
      Permission.location,
      Permission.storage,
    ];

    if (sdkInt >= 33) {
      permissionsToRequest.addAll([
        Permission.audio,
        Permission.videos,
        Permission.photos,
      ]);
    } else if (sdkInt >= 29) {
      permissionsToRequest.add(Permission.storage);
    } else {
      permissionsToRequest.add(Permission.storage);
    }

    final Map<Permission, PermissionStatus> statuses =
        await permissionsToRequest.request();

    for (var permission in permissionsToRequest) {
      if (statuses[permission]?.isDenied ?? false) {
        debugPrint('Required permissions denied: ${permission.toString()}');
        return false;
      }
    }

    debugPrint('Required permissions GRANTED');
    return true;
  }

  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // Replace startReceiving method
  void startReceiving() async {
    try {
      await _requestPermissions();
      isStartDiscovery.value = true;
      discoveredDevices.clear();
      discoveryTimeLeft = _discoveryDuration;
      _isScanning = false;
      update();

      // Initial scan
      await _performScan();

      // Start countdown timer (updates every second for smooth UI)
      _countdownTimer?.cancel();
      _countdownTimer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          if (!isStartDiscovery.value) {
            timer.cancel();
            return;
          }

          discoveryTimeLeft--;
          update(); // Update UI for countdown

          if (discoveryTimeLeft <= 0) {
            stopReceiving(isinitial: true);
            Get.snackbar(
              'Discovery Completed',
              'Found ${discoveredDevices.length} device(s)',
              duration: const Duration(seconds: 2),
            );
          }
        },
      );

      // Start periodic scanning (separate from countdown)
      _discoveryTimer?.cancel();
      _discoveryTimer = Timer.periodic(
        const Duration(seconds: _scanInterval),
        (timer) {
          if (!isStartDiscovery.value) {
            timer.cancel();
            return;
          }

          // Run scan without blocking
          _performScan();
        },
      );
    } catch (e) {
      debugPrint('Discovery error: $e');
      Get.snackbar('Error', 'Scan failed: $e');
      stopReceiving();
    }
  }

  // Add new _performScan method - make it non-blocking
  Future<void> _performScan() async {
    // Prevent overlapping scans
    if (_isScanning) return;

    _isScanning = true;

    try {
      // Run scan in background without awaiting in Timer
      await ReceiverService.scanForSenders().then((senders) {
        if (!isStartDiscovery.value) return;

        // Add only new devices (avoid duplicates)
        for (var sender in senders) {
          if (!discoveredDevices
              .any((d) => d.ip == sender.ip && d.port == sender.port)) {
            discoveredDevices.add(sender);
          }
        }
        update(); // Update UI when new devices found
      }).catchError((e) {
        debugPrint('Scan error: $e');
      }).whenComplete(() async {
        _isScanning = false;
      });
    } catch (e) {
      debugPrint('Scan error: $e');
      _isScanning = false;
    }
  }

  // Replace stopReceiving method
  void stopReceiving({bool isinitial = false}) async {
    if (!isinitial) {
      discoveredDevices.clear();
    }
    _discoveryTimer?.cancel();
    _countdownTimer?.cancel();
    _discoveryTimer = null;
    _countdownTimer = null;
    isStartDiscovery.value = false;
    discoveryTimeLeft = 0;
    _isScanning = false;

    update();
  }

  void connectToSender(SenderModel sender) async {
    try {
      final Map<String, dynamic> result =
          await ReceiverService.requestConnection(
        sender,
      );

      if (result['success'] == true) {
        final int code = result['code'];
        navigateToReceivingProgress(sender, code);
      } else {
        discoveredDevices.remove(sender);
        update();
        Get.snackbar('Connection Failed', 'Device is not available');
      }
    } catch (e) {
      discoveredDevices.remove(sender);
      update();
      Get.snackbar('Alert', 'Device is not available');
    }
  }

  // QR Code Scanner Methods
  void openQRScanner() async {
    final bool hasPermission = await _requestCameraPermission();
    if (!hasPermission) {
      Get.snackbar(
        'Permission Required',
        'Camera permission is needed to scan QR code',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    qrScannerController = MobileScannerController();
    isScanning.value = true;
    update();

    await Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: _buildQRScannerDialog(),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildQRScannerDialog() {
    return Container(
      height: 500,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Scan QR Code',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: closeQRScanner,
                ),
              ],
            ),
          ),

          // Scanner View
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: MobileScanner(
                  controller: qrScannerController,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      if (barcode.rawValue != null) {
                        handleQRCodeScanned(barcode.rawValue!);
                        break;
                      }
                    }
                  },
                ),
              ),
            ),
          ),

          // Instructions
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Position the QR code within the frame',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void handleQRCodeScanned(String qrData) async {
    if (!isScanning.value) return;

    closeQRScanner();

    try {
      // Parse QR data: 10.160.164.234:4040:422819
      final List<String> parts = qrData.split(':');

      if (parts.length != 3) {
        Get.snackbar(
          'Invalid QR Code',
          'The scanned QR code is not valid',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final String ip = parts[0];
      final int port = int.parse(parts[1]);
      final int secretCode = int.parse(parts[2]);

      Get.snackbar(
        'Connecting...',
        'Attempting to connect to device',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      final SenderModel? sender =
          await ReceiverService.checkIfPhotonServer(ip, port);

      if (sender == null) {
        Get.snackbar(
          'Error',
          'Could not connect to sender',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      // Navigate to receiving progress with the secret code
      navigateToReceivingProgress(sender, secretCode);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to process QR code: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void closeQRScanner() {
    isScanning.value = false;
    qrScannerController?.dispose();
    qrScannerController = null;
    Get.back();
    update();
  }

  void navigateToReceivingProgress(SenderModel sender, int secretCode) {
    stopReceiving();
    Get.toNamed(
      AppRoutes.receivingProgressPage,
      arguments: {'sender': sender, 'secretCode': secretCode},
    )?.then((onValue) {
      stopReceiving();
    });
  }

  void navigateToQRCodeScreen() {
    Get.toNamed(AppRoutes.qrCodePage);
  }
}
