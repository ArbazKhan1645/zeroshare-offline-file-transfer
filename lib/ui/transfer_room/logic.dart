// lib/ui/transfer_room/transfer_room_logic.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:zero_share/models/files_model.dart';
import 'package:zero_share/services/room_service.dart';

class TransferRoomLogic extends GetxController {
  Rx<RoomSession?> session = Rx<RoomSession?>(null);
  RxList<TransferMessage> messages = <TransferMessage>[].obs;
  RxBool isConnected = false.obs;
  RxBool userDisconnected = false.obs;
  RxString connectedUser = ''.obs;
  RxBool showQR = false.obs;
  RxBool isSending = false.obs;
  bool _hasLeftRoom = false;

  @override
  void onInit() {
    super.onInit();
    try {
      if (Get.arguments != null && Get.arguments is RoomSession) {
        try {
          session.value = Get.arguments as RoomSession;

          RoomService.onMessageReceived = _onMessageReceived;
          RoomService.onUserJoined = _onUserJoined;
          RoomService.onUserLeft = _onUserLeft;
          RoomService.onProgressUpdate = _onProgressUpdate;

          if (session.value!.guestName != null &&
              session.value!.guestName!.isNotEmpty) {
            isConnected.value = true;
            connectedUser.value = session.value!.isHost
                ? session.value!.guestName!
                : session.value!.hostName;
          }

          messages.value = List.from(RoomService.messages);
          debugPrint('Transfer room initialized successfully');
        } catch (e) {
          debugPrint('Error setting up room session: $e');
        }
      } else {
        debugPrint('No valid room session in arguments');
      }
    } catch (e) {
      debugPrint('Critical error in TransferRoomLogic onInit: $e');
    }
  }

  void _onMessageReceived(TransferMessage message) {
    try {
      if (_hasLeftRoom) return;

      // Find and update or add
      final int existingIndex = messages.indexWhere((m) => m.id == message.id);

      if (existingIndex != -1) {
        // Update existing message
        messages[existingIndex] = message;
        debugPrint('✅ Updated existing message at index $existingIndex');
      } else {
        // Add new message
        messages.add(message);
        debugPrint('✅ Added new message');
      }

      update();

      // Show snackbar only for newly completed files
      if (message.status == TransferStatus.completed &&
          !message.isSentByMe &&
          message.progress >= 1.0) {
        try {
          Get.snackbar(
            'File Received 📥',
            message.fileName,
            duration: const Duration(seconds: 2),
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } catch (e) {
          debugPrint('Error showing file received snackbar: $e');
        }
      }
    } catch (e) {
      debugPrint('Error in _onMessageReceived: $e');
    }
  }

  void _onProgressUpdate(String messageId, double progress) {
    try {
      if (_hasLeftRoom) return;

      final int index = messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        // Only update if progress changed significantly
        if ((progress - messages[index].progress).abs() > 0.01 ||
            progress >= 1.0) {
          try {
            messages[index] = messages[index].copyWith(progress: progress);

            // If 100% and still not completed, force check
            if (progress >= 1.0 &&
                messages[index].status != TransferStatus.completed) {
              Future.delayed(const Duration(milliseconds: 500), () {
                try {
                  final serviceMessages = RoomService.messages;
                  final serviceMsg = serviceMessages.firstWhereOrNull(
                    (m) => m.id == messageId,
                  );

                  if (serviceMsg != null &&
                      serviceMsg.status == TransferStatus.completed) {
                    messages[index] = serviceMsg;
                    update();
                  }
                } catch (e) {
                  debugPrint('Error in delayed completion check: $e');
                }
              });
            }

            update();
          } catch (e) {
            debugPrint('Error updating message progress: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error in _onProgressUpdate: $e');
    }
  }

  void _onUserJoined(String userName) async {
    try {
      if (_hasLeftRoom) return;

      isConnected.value = true;
      connectedUser.value = userName;
      userDisconnected.value = false;

      session.value = RoomService.currentSession;

      update();

      try {
        Get.snackbar(
          'User Joined 🎉',
          '$userName joined the room',
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        debugPrint('Error showing user joined snackbar: $e');
      }

      debugPrint('User joined: $userName');
    } catch (e) {
      debugPrint('Error in _onUserJoined: $e');
    }
  }

  void _onUserLeft(String userName) async {
    try {
      if (_hasLeftRoom) return;

      isConnected.value = false;
      userDisconnected.value = true;
      update();

      try {
        Get.snackbar(
          'Room Closed',
          '$userName has left the room',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } catch (e) {
        debugPrint('Error showing user left snackbar: $e');
      }

      Future.delayed(const Duration(seconds: 2), () {
        try {
          if (userDisconnected.value && !_hasLeftRoom) {
            leaveRoom();
          }
        } catch (e) {
          debugPrint('Error in delayed leave room: $e');
        }
      });

      debugPrint('User left: $userName');
    } catch (e) {
      debugPrint('Error in _onUserLeft: $e');
    }
  }

  Future<void> pickAndSendFiles() async {
    try {
      if (isSending.value) {
        Get.snackbar('Please Wait', 'Already sending files...');
        return;
      }

      if (!isConnected.value) {
        Get.snackbar(
          'No Connection',
          'Waiting for user to join...',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      FilePickerResult? result;

      try {
        result = await FilePicker.pickFiles(allowMultiple: true);
      } catch (e) {
        debugPrint('File picker error: $e');

        Get.snackbar(
          'Error',
          'Failed to open file picker',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (result != null && result.files.isNotEmpty) {
        isSending.value = true;

        for (var file in result.files) {
          if (file.path != null) {
            try {
              await _sendFile(File(file.path!));
              // Small delay between files
              await Future.delayed(const Duration(milliseconds: 500));
              try {} catch (e) {
                debugPrint('');
              }
            } catch (e) {
              debugPrint('Error sending file ${file.name}: $e');
            }
          }
        }

        isSending.value = false;
        debugPrint('Finished sending ${result.files.length} files');
      }
    } catch (e) {
      isSending.value = false;
      debugPrint('Error in pickAndSendFiles: $e');

      Get.snackbar(
        'Error',
        'Failed to pick files: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<bool> _sendFile(File file) async {
    try {
      if (session.value == null) {
        debugPrint('Cannot send file - no session');
        return false;
      }

      session.value = RoomService.currentSession;

      String? recipientIP;

      if (session.value!.isHost) {
        recipientIP = session.value!.guestIP;
      } else {
        recipientIP = session.value!.hostIP;
      }

      if (recipientIP == null ||
          recipientIP.isEmpty ||
          recipientIP == 'Unknown') {
        debugPrint('Cannot find recipient IP');

        Get.snackbar(
          'Connection Error',
          'Cannot find recipient',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      bool success;

      try {
        success = await RoomService.sendFile(
          file,
          recipientIP,
          session.value!.port,
        );
      } catch (e) {
        debugPrint('RoomService.sendFile error: $e');

        return false;
      }

      if (success) {
        try {
          messages.value = List.from(RoomService.messages);
          update();
        } catch (e) {
          debugPrint('Error updating messages after send: $e');
        }
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('❌ Send file error: $e');

      return false;
    }
  }

  Future<void> openFile(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);

      if (result.type != ResultType.done) {
        debugPrint('Cannot open file: ${result.message}');

        Get.snackbar(
          'Cannot Open',
          'No app found to open this file',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        debugPrint('File opened successfully: $filePath');
      }
    } catch (e) {
      debugPrint('Error opening file: $e');

      Get.snackbar(
        'Error',
        'Cannot open file: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> leaveRoom() async {
    try {
      _hasLeftRoom = true;

      try {
        await RoomService.leaveRoom();

        try {} catch (e) {
          debugPrint('');
        }
        debugPrint('Left room successfully');
      } catch (e) {
        debugPrint('Error leaving room service: $e');
      }

      try {
        Get.until((route) => route.isFirst);
      } catch (e) {
        debugPrint('Error navigating back: $e');

        // Try alternative navigation
        try {
          Get.back();
        } catch (fallbackError) {
          debugPrint('Fallback navigation also failed: $fallbackError');
        }
      }
    } catch (e) {
      debugPrint('Critical error in leaveRoom: $e');
    }
  }

  @override
  void onClose() {
    try {
      if (!_hasLeftRoom) {
        try {
          RoomService.leaveRoom();
        } catch (e) {
          debugPrint('Error leaving room in onClose: $e');
        }
      }

      super.onClose();
      debugPrint('TransferRoomLogic closed');
    } catch (e) {
      debugPrint('Error in TransferRoomLogic onClose: $e');

      try {
        super.onClose();
      } catch (superError) {
        debugPrint('Error calling super.onClose: $superError');
      }
    }
  }
}
