// lib/ui/receiving_progress_page/receiving_progress_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zero_share/controllers/manager.dart';
import 'package:zero_share/controllers/status_widget.dart';
import 'package:zero_share/models/files_model.dart';
import 'package:zero_share/ui/receiving_progress_page/receiving_progress_logic.dart';
import 'package:zero_share/utils/color.dart';
import 'package:zero_share/Widgets/common_appbar.dart';

class ReceivingProgressView extends StatelessWidget {
  ReceivingProgressView({super.key});

  final controller = Get.put(ReceivingProgressLogic());
  final connManager = ConnectionManager.instance;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, d) => _handleBackPress(context),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: CommonAppBar(
          onBackTap: () => _handleBackPress(context).then((canPop) {
            Get.until((pro) => pro.isFirst);
          }),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return _buildLoadingState();
          }

          return Column(
            children: [
              // Connection Status Widget
              const ConnectionStatusWidget(),

              // Sender Info Card
              _buildSenderInfoCard(),

              // Files List
              Expanded(child: _buildFilesList()),

              // Progress Info
              if (controller.isReceiving.value) _buildProgressInfo(),

              // Action Button
              _buildActionButton(),
            ],
          );
        }),
      ),
    );
  }

  // Loading State
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: AppColor.colorWhite,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColor.primary.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColor.primary,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Connecting to sender...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColor.colorTextGreyLight,
            ),
          ),
        ],
      ),
    );
  }

  // Elegant Sender Info Card
  Widget _buildSenderInfoCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.colorWhite,
            AppColor.primaryLight.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColor.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withValues(alpha: 0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with Status Indicator
          Stack(
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColor.primary.withValues(alpha: 0.2),
                      AppColor.primary.withValues(alpha: 0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    controller.sender!.avatar
                            .toString()
                            .toLowerCase()
                            .contains('assets')
                        ? controller.sender!.avatar.toString()
                        : 'assets/images/img_avatar_female_blue.png',
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Obx(
                  () => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: connManager.isConnected.value
                          ? Colors.green
                          : Colors.grey,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppColor.colorWhite, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: (connManager.isConnected.value
                                  ? Colors.green
                                  : Colors.grey)
                              .withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.circle,
                      size: 8,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 18),

          // Sender Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        controller.sender?.hostName ?? 'Unknown Device',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColor.colorBlack,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.wifi,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 5),
                    Text(
                      controller.sender?.ip ?? '--',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        controller.sender?.os.toUpperCase() ?? 'OS',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColor.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.folder_copy_rounded,
                      size: 14,
                      color: AppColor.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${controller.fileNames.length} files ready',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColor.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Elegant Files List
  Widget _buildFilesList() {
    if (controller.fileNames.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_rounded,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              'No files to receive',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: controller.fileNames.length,
      itemBuilder: (context, index) {
        final String fileName = controller.fileNames[index];
        final double progress =
            controller.fileController.progressList.length > index
                ? controller.fileController.progressList[index]
                : 0.0;
        final FileStatus status =
            controller.fileController.statusList.length > index
                ? controller.fileController.statusList[index]
                : FileStatus.waiting;

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 50)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColor.colorWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _getStatusColor(status).withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _getStatusColor(status).withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Status Icon
                      _buildStatusIcon(status),
                      const SizedBox(width: 15),

                      // File Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fileName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColor.colorBlack,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _getStatusText(status),
                              style: TextStyle(
                                fontSize: 12,
                                color: _getStatusColor(status),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Progress Percentage
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${progress.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(status),
                          ),
                        ),
                      ),

                      // Cancel Button
                      if (status == FileStatus.downloading) ...[
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: () =>
                              controller.fileController.cancelDownload(index),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      minHeight: 6,
                      backgroundColor:
                          _getStatusColor(status).withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getStatusColor(status),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Progress Info Card
  Widget _buildProgressInfo() {
    return Obx(() {
      if (controller.fileController.currentSpeed.value == 0) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColor.primary.withValues(alpha: 0.1),
              AppColor.primary.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColor.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoItem(
              icon: Icons.speed_rounded,
              label: 'Transfer Speed',
              value: controller.fileController.formatSpeed(
                controller.fileController.currentSpeed.value,
              ),
            ),
            Container(
              width: 1,
              height: 50,
              color: AppColor.primary.withValues(alpha: 0.3),
            ),
            _buildInfoItem(
              icon: Icons.timer_outlined,
              label: 'Time Remaining',
              value: controller.fileController.estimatedTime.value.isEmpty
                  ? 'Calculating...'
                  : controller.fileController.estimatedTime.value,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColor.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColor.primary, size: 24),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColor.primary,
          ),
        ),
      ],
    );
  }

  // Action Button
  Widget _buildActionButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.colorWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Obx(() {
        if (controller.fileController.isFinished.value) {
          return _buildSuccessButton();
        }

        if (controller.isReceiving.value) {
          return _buildReceivingButton();
        }

        return _buildStartButton();
      }),
    );
  }

  Widget _buildStartButton() {
    return ElevatedButton.icon(
      onPressed: controller.startReceiving,
      icon: const Icon(Icons.download_rounded, size: 24),
      label: const Text(
        'Start Receiving',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.primary,
        foregroundColor: AppColor.colorWhite,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 5,
        shadowColor: AppColor.primary.withValues(alpha: 0.4),
      ),
    );
  }

  Widget _buildReceivingButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.primary.withValues(alpha: 0.2),
            AppColor.primary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColor.primary.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColor.primary,
            ),
          ),
          SizedBox(width: 15),
          Text(
            'Receiving Files...',
            style: TextStyle(
              color: AppColor.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessButton() {
    return ElevatedButton.icon(
      onPressed: () {
        controller.finishAndGoBack();
        connManager.disconnect();
        Get.until((pro) => pro.isFirst);
      },
      icon: const Icon(Icons.check_circle_rounded, size: 24),
      label: const Text(
        'Done',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: AppColor.colorWhite,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 5,
        shadowColor: Colors.green.withValues(alpha: 0.4),
      ),
    );
  }

  // Status Icon Builder
  Widget _buildStatusIcon(FileStatus status) {
    switch (status) {
      case FileStatus.downloading:
        return Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColor.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColor.primary,
          ),
        );
      case FileStatus.downloaded:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: Colors.green,
            size: 24,
          ),
        );
      case FileStatus.cancelled:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.cancel_rounded,
            color: Colors.orange,
            size: 24,
          ),
        );
      case FileStatus.error:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.error_rounded,
            color: Colors.red,
            size: 24,
          ),
        );
      default:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.pending_rounded,
            color: Colors.grey[600],
            size: 24,
          ),
        );
    }
  }

  String _getStatusText(FileStatus status) {
    switch (status) {
      case FileStatus.downloading:
        return 'Downloading...';
      case FileStatus.downloaded:
        return 'Completed';
      case FileStatus.cancelled:
        return 'Cancelled';
      case FileStatus.error:
        return 'Failed';
      default:
        return 'Waiting...';
    }
  }

  Color _getStatusColor(FileStatus status) {
    switch (status) {
      case FileStatus.downloading:
        return AppColor.primary;
      case FileStatus.downloaded:
        return Colors.green;
      case FileStatus.cancelled:
        return Colors.orange;
      case FileStatus.error:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Handle Back Press
  Future<bool> _handleBackPress(BuildContext context) async {
    if (controller.isReceiving.value &&
        !controller.fileController.isFinished.value) {
      final bool? confirm = await _showExitConfirmation(context);
      if (confirm == true) {
        controller.fileController.reset();
        connManager.disconnect();

        return true;
      }
      return false;
    }
    controller.fileController.reset();
    connManager.disconnect();
    return true;
  }

  Future<bool?> _showExitConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 10),
            Text('Cancel Transfer?'),
          ],
        ),
        content: const Text(
          'Files are still being received. Cancelling will stop the transfer. Continue?',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Continue Receiving',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}
