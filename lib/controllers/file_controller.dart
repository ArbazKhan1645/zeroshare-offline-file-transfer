// lib/controllers/file_controller.dart
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:zero_share/models/files_model.dart';

class FileController extends GetxController {
  RxList<double> progressList = <double>[].obs;
  RxList<FileStatus> statusList = <FileStatus>[].obs;
  RxList<bool> cancelledList = <bool>[].obs;

  RxDouble currentSpeed = 0.0.obs;
  RxDouble minSpeed = 0.0.obs;
  RxDouble maxSpeed = 0.0.obs;

  RxString estimatedTime = ''.obs;
  RxInt totalTimeElapsed = 0.obs;
  RxBool isFinished = false.obs;

  List<CancelToken> cancelTokens = [];

  void initializeForFiles(int fileCount) {
    progressList.value = List.filled(fileCount, 0.0);
    statusList.value = List.filled(fileCount, FileStatus.waiting);
    cancelledList.value = List.filled(fileCount, false);
    cancelTokens = List.generate(fileCount, (_) => CancelToken());

    currentSpeed.value = 0.0;
    minSpeed.value = 0.0;
    maxSpeed.value = 0.0;
    estimatedTime.value = '';
    totalTimeElapsed.value = 0;
    isFinished.value = false;
  }

  void updateProgress(int index, double progress) {
    if (index < progressList.length) {
      progressList[index] = progress;
      progressList.refresh();
    }
  }

  void updateStatus(int index, FileStatus status) {
    if (index < statusList.length) {
      statusList[index] = status;
      statusList.refresh();
    }
  }

  void updateSpeed(double speed) {
    currentSpeed.value = speed;

    if (minSpeed.value == 0 || speed < minSpeed.value) {
      minSpeed.value = speed;
    }
    if (speed > maxSpeed.value) {
      maxSpeed.value = speed;
    }
  }

  void cancelDownload(int index) {
    if (index < cancelTokens.length) {
      cancelTokens[index].cancel('User cancelled');
      cancelledList[index] = true;
      updateStatus(index, FileStatus.cancelled);
      cancelledList.refresh();
    }
  }

  void reset() {
    currentSpeed.value = 0.0;
    minSpeed.value = 0.0;
    maxSpeed.value = 0.0;
    estimatedTime.value = '';
    totalTimeElapsed.value = 0;
    isFinished.value = false;
  }

  String formatSpeed(double bytesPerSecond) {
    if (bytesPerSecond < 1024) {
      return '${bytesPerSecond.toStringAsFixed(2)} B/s';
    } else if (bytesPerSecond < 1024 * 1024) {
      return '${(bytesPerSecond / 1024).toStringAsFixed(2)} KB/s';
    } else {
      return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(2)} MB/s';
    }
  }

  String formatTime(int seconds) {
    if (seconds < 60) {
      return '$seconds sec';
    } else if (seconds < 3600) {
      final int min = seconds ~/ 60;
      final int sec = seconds % 60;
      return '$min min $sec sec';
    } else {
      final int hr = seconds ~/ 3600;
      final int min = (seconds % 3600) ~/ 60;
      return '$hr hr $min min';
    }
  }
}
