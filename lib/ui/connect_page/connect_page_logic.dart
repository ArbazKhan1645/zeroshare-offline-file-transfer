// lib/ui/connect_page/connect_page_logic.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:zero_share/models/files_model.dart';
import 'package:zero_share/services/room_service.dart';
import 'dart:io';
import 'package:zero_share/ui/transfer_room/transfer_room.dart';

class ConnectPageLogic extends GetxController
    with GetSingleTickerProviderStateMixin {
  AnimationController? radarController;
  RxBool isStartDiscovery = false.obs;
  RxBool isRoomMode = false.obs;
  RxBool isStartingRoom = false.obs;

  RxList<RoomSession> discoveredRooms = <RoomSession>[].obs;

  @override
  void onInit() async {
    super.onInit();
    try {
      radarController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 5),
      );
      await radarController?.repeat();
      update();
      debugPrint('ConnectPageLogic initialized');
    } catch (e) {
      debugPrint('Error in ConnectPageLogic onInit: $e');
    }
  }

  @override
  void onClose() {
    try {
      _discoveryTimer?.cancel();
      _countdownTimer?.cancel();
      radarController?.dispose();
      super.onClose();
      debugPrint('ConnectPageLogic closed');
    } catch (e) {
      debugPrint('Error in ConnectPageLogic onClose: $e');

      try {
        super.onClose();
      } catch (superError) {
        debugPrint('Error calling super.onClose: $superError');
      }
    }
  }

  Future<bool> _requestPermissions() async {
    try {
      if (!Platform.isAndroid) {
        debugPrint('Not Android, skipping permission request');
        return true;
      }

      Map<Permission, PermissionStatus> statuses;

      try {
        statuses = await [
          Permission.camera,
          Permission.location,
          Permission.storage,
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ].request();
      } catch (e) {
        debugPrint('Error requesting permissions: $e');

        return false;
      }

      final bool allGranted =
          statuses.values.every((status) => status.isGranted);

      if (!allGranted) {
        debugPrint('Some permissions denied');
      } else {
        debugPrint('All permissions granted');
      }

      return allGranted;
    } catch (e) {
      debugPrint('Critical error in _requestPermissions: $e');

      return false;
    }
  }

  void toggleRoomMode() async {
    try {
      isRoomMode.value = !isRoomMode.value;

      if (!isRoomMode.value && isStartingRoom.value) {
        try {
          await RoomService.leaveRoom();
          isStartingRoom.value = false;
          debugPrint('Left room during toggle');
        } catch (e) {
          debugPrint('Error leaving room during toggle: $e');
        }
      }

      if (isStartDiscovery.value) {
        try {
          stopDiscovery();
        } catch (e) {
          debugPrint('Error stopping discovery: $e');
        }
      }

      update();
      debugPrint('Room mode toggled: ${isRoomMode.value}');
    } catch (e) {
      debugPrint('Error in toggleRoomMode: $e');
    }
  }

  Future<void> startRoom() async {
    try {
      await _requestPermissions();
      isStartingRoom.value = true;
      update();

      RoomSession? session;

      try {
        session = await RoomService.startRoom();
      } catch (e) {
        debugPrint('RoomService.startRoom error: $e');

        isStartingRoom.value = false;
        Get.snackbar('Error', 'Failed to start room: $e');
        return;
      }

      if (session != null) {
        try {
          Get.snackbar(
            'Room Started! 🎉',
            'Room ID: ${session.roomId}\nIP: ${session.hostIP}',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          await Get.to(() => TransferRoomView(), arguments: session);
          debugPrint('Room started successfully: ${session.roomId}');
        } catch (e) {
          debugPrint('Error showing room start notification: $e');
        }
      } else {
        isStartingRoom.value = false;
        debugPrint('Failed to start room - session is null');

        Get.snackbar('Error', 'Failed to start room');
      }
    } catch (e) {
      isStartingRoom.value = false;
      debugPrint('Critical error in startRoom: $e');

      Get.snackbar('Error', 'Failed: $e');
    }
  }

  Timer? _discoveryTimer;
  Timer? _countdownTimer;
  final RxInt discoveryTimeLeft = 30.obs;
  static const int _scanInterval = 3;
  static const int _discoveryDuration = 30;
  bool _isScanning = false;

  void startDiscovery() async {
    try {
      await _requestPermissions();
      isStartDiscovery.value = true;
      discoveredRooms.clear();
      discoveryTimeLeft.value = _discoveryDuration;
      _isScanning = false;
      update();

      // Initial scan
      try {
        await _performScan();
      } catch (e) {
        debugPrint('Initial scan error: $e');
      }

      // Start countdown timer
      _countdownTimer?.cancel();
      _countdownTimer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          try {
            update();
            if (!isStartDiscovery.value) {
              timer.cancel();
              return;
            }

            discoveryTimeLeft.value--;

            if (discoveryTimeLeft.value <= 0) {
              stopDiscovery();
              Get.snackbar(
                'Discovery Completed',
                'Found ${discoveredRooms.length} room(s)',
                duration: const Duration(seconds: 2),
              );
            }
          } catch (e) {
            debugPrint('Countdown timer error: $e');
          }
        },
      );

      // Start periodic scanning
      _discoveryTimer?.cancel();
      _discoveryTimer = Timer.periodic(
        const Duration(seconds: _scanInterval),
        (timer) {
          try {
            if (!isStartDiscovery.value) {
              timer.cancel();
              return;
            }

            _performScan();
          } catch (e) {
            debugPrint('Discovery timer error: $e');
          }
        },
      );

      debugPrint('Discovery started');
    } catch (e) {
      debugPrint('Discovery error: $e');

      Get.snackbar('Error', 'Scan failed: $e');
      stopDiscovery();
    }
  }

  Future<void> _performScan() async {
    try {
      if (_isScanning) return;

      _isScanning = true;

      await RoomService.scanForRooms().then((rooms) {
        try {
          if (!isStartDiscovery.value) return;

          for (var room in rooms) {
            if (!discoveredRooms
                .any((r) => r.hostIP == room.hostIP && r.port == room.port)) {
              discoveredRooms.add(room);
            }
          }
          update();
          debugPrint('Scan completed: ${rooms.length} rooms found');
        } catch (e) {
          debugPrint('Error processing scan results: $e');
        }
      }).catchError((e, stack) {
        debugPrint('Scan error: $e');
      }).whenComplete(() async {
        _isScanning = false;
        update();
      });
    } catch (e) {
      debugPrint('Scan error: $e');

      _isScanning = false;
      update();
    }
  }

  void stopDiscovery() {
    try {
      _discoveryTimer?.cancel();
      _countdownTimer?.cancel();
      _discoveryTimer = null;
      _countdownTimer = null;
      isStartDiscovery.value = false;
      discoveryTimeLeft.value = 0;
      _isScanning = false;
      update();
      debugPrint('Discovery stopped');
    } catch (e) {
      debugPrint('Error stopping discovery: $e');
    }
  }

  void joinRoom(RoomSession room) async {
    try {
      Get.snackbar('Connecting', "Joining ${room.hostName}'s room...");

      RoomSession? session;

      try {
        session = await RoomService.joinRoom(room.hostIP, room.port);
      } catch (e) {
        debugPrint('RoomService.joinRoom error: $e');

        Get.snackbar('Error', 'Failed to join: $e');
        return;
      }

      if (session != null) {
        try {
          Get.snackbar(
            'Connected! 🎉',
            "Joined ${room.hostName}'s room",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          await Get.to(() => TransferRoomView(), arguments: session);
          debugPrint('Joined room: ${room.roomId}');
        } catch (e) {
          debugPrint('Error navigating to room: $e');
        }
      } else {
        debugPrint('Join room failed - session is null');

        Get.snackbar('Error', 'Room is full or unavailable');
      }
    } catch (e) {
      debugPrint('Critical error in joinRoom: $e');

      Get.snackbar('Error', 'Failed to join: $e');
    }
  }

  void navigateToQRScanner() async {
    try {
      await _requestPermissions();

      final MobileScannerController mobileScanner = MobileScannerController();

      try {
        await Get.to(
          () => _ScannerView(
            scannerController: mobileScanner,
            onScanned: (code) {
              try {
                if (code.isNotEmpty) {
                  handleScannedQR(code);
                }
              } catch (e) {
                debugPrint('Error in QR scan callback: $e');
              }
            },
          ),
        );
      } catch (e) {
        debugPrint('Scanner error: $e');

        Get.snackbar('Error', 'Scanner failed: $e');
      }
    } catch (e) {
      debugPrint('Error in navigateToQRScanner: $e');
    }
  }

  void handleScannedQR(String scannedData) async {
    try {
      List<String> parts;

      try {
        parts = scannedData.split(':');
      } catch (e) {
        debugPrint('Error parsing QR data: $e');

        Get.snackbar('Error', 'Invalid QR code format');
        return;
      }

      if (parts.length != 3) {
        debugPrint('Invalid QR code format: ${parts.length} parts');

        Get.snackbar('Error', 'Invalid QR code');
        return;
      }

      final String ip = parts[0];
      int port;

      try {
        port = int.parse(parts[1]);
      } catch (e) {
        debugPrint('Error parsing port: $e');

        Get.snackbar('Error', 'Invalid QR code data');
        return;
      }

      try {
        Get.back();
      } catch (e) {
        debugPrint('Error closing scanner: $e');
      }

      Get.snackbar('Connecting', 'Joining room...');

      RoomSession? session;

      try {
        session = await RoomService.joinRoom(ip, port);
      } catch (e) {
        debugPrint('Join room error from QR: $e');

        Get.snackbar('Error', 'Could not join room: $e');
        return;
      }

      if (session != null) {
        try {
          Get.snackbar(
            'Connected! 🎉',
            'Joined room successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          await Get.to(() => TransferRoomView(), arguments: session);
          debugPrint('Joined room from QR successfully');
        } catch (e) {
          debugPrint('Error navigating to room from QR: $e');
        }
      } else {
        debugPrint('Join room from QR failed - session is null');

        Get.snackbar('Error', 'Could not join room');
      }
    } catch (e) {
      debugPrint('Critical error in handleScannedQR: $e');

      Get.snackbar('Error', 'Invalid QR: $e');
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
        title: const Text('Scan Room QR'),
        backgroundColor: Colors.black,
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
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: scannerController,
            onDetect: (capture) {
              try {
                final code = capture.barcodes.first.rawValue ?? '';
                if (code.isNotEmpty) {
                  onScanned(code);
                }
              } catch (e) {
                debugPrint('Error in QR detection: $e');
              }
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
