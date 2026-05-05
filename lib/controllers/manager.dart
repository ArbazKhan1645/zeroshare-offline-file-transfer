// lib/services/connection_manager.dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:zero_share/models/files_model.dart';

class ConnectionManager extends GetxController {
  static ConnectionManager get instance => Get.find<ConnectionManager>();

  // Connection state
  RxBool isConnected = false.obs;
  Rx<SenderModel?> connectedDevice = Rx<SenderModel?>(null);
  RxInt secretCode = 0.obs;
  RxString role = ''.obs; // 'sender' or 'receiver'

  // Transfer state
  RxBool isTransferring = false.obs;
  RxInt currentFileIndex = 0.obs;
  RxInt totalFiles = 0.obs;
  RxDouble overallProgress = 0.0.obs;
  RxList<String> fileNames = <String>[].obs;

  // Live status
  Timer? _heartbeatTimer;

  void startConnection({
    required SenderModel device,
    required int code,
    required String userRole,
  }) {
    connectedDevice.value = device;
    secretCode.value = code;
    role.value = userRole;
    isConnected.value = true;
  }

  void updateTransferProgress({
    required int fileIndex,
    required int total,
    required double progress,
  }) {
    currentFileIndex.value = fileIndex;
    totalFiles.value = total;
    overallProgress.value = ((fileIndex + progress / 100) / total) * 100;
    isTransferring.value = true;
  }

  void disconnect() {
    isConnected.value = false;
    connectedDevice.value = null;
    secretCode.value = 0;
    role.value = '';
    isTransferring.value = false;
    currentFileIndex.value = 0;
    totalFiles.value = 0;
    overallProgress.value = 0.0;
    fileNames.clear();
    _heartbeatTimer?.cancel();
  }

  @override
  void onClose() {
    _heartbeatTimer?.cancel();
    super.onClose();
  }
}
