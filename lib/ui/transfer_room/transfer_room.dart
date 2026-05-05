// lib/ui/transfer_room/transfer_room_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:zero_share/models/files_model.dart';
import 'package:zero_share/services/room_service.dart';
import 'package:zero_share/ui/transfer_room/logic.dart';
import 'package:zero_share/utils/color.dart';

class TransferRoomView extends StatelessWidget {
  TransferRoomView({super.key});

  final logic = Get.put(TransferRoomLogic());

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (await _showExitConfirmation(context)) {
          await logic.leaveRoom();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: AppColor.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              if (await _showExitConfirmation(context)) {
                await logic.leaveRoom();
              }
            },
          ),
          title: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  logic.session.value?.isHost ?? false
                      ? 'Transfer Room (Host)'
                      : 'Transfer Room',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  logic.isConnected.value
                      ? '${logic.connectedUser.value} â€¢ Online'
                      : 'Waiting for connection...',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Obx(
              () => Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: logic.isConnected.value ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      logic.isConnected.value ? 'LIVE' : 'WAITING',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Room Info Banner
            _buildRoomInfo(),

            // Messages List
            Expanded(
              child: Obx(() {
                if (logic.messages.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildMessagesList();
              }),
            ),

            // User Disconnected Banner

            // Input Area
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  // Room Info Banner
  Widget _buildRoomInfo() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColor.primary.withValues(alpha: 0.1),
              AppColor.primary.withValues(alpha: 0.05),
            ],
          ),
          border: Border(
            bottom: BorderSide(
              color: AppColor.primary.withValues(alpha: 0.2),
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColor.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.room_outlined,
                color: AppColor.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Room ID: ${logic.session.value?.roomId ?? '---'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColor.colorBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${logic.messages.length} transfers',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (logic.isConnected.value)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.people_rounded,
                  color: Colors.green,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Empty State
  Widget _buildEmptyState() {
    return Center(child: _buildQRCodeSection());
  }

  // Messages List (Chat-style)
  Widget _buildMessagesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: logic.messages.length,
      itemBuilder: (context, index) {
        final message = logic.messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  // Message Bubble (like WhatsApp)
// In transfer_room_view.dart - Update _buildMessageBubble

  Widget _buildMessageBubble(TransferMessage message) {
    final progress = message.progress;
    final bool isSentByMe = message.isSentByMe;
    final bool isInProgress = progress == 100.0
        ? false
        : (message.status == TransferStatus.sending ||
            message.status == TransferStatus.receiving);

    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: Get.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment:
              isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isSentByMe) ...[
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 4),
                child: Text(
                  message.senderName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSentByMe
                      ? [
                          AppColor.primary,
                          const Color(0xFF45B649),
                        ]
                      : [
                          Colors.white,
                          Colors.grey[50]!,
                        ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isSentByMe ? 16 : 4),
                  bottomRight: Radius.circular(isSentByMe ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: message.status == TransferStatus.completed
                      ? () => logic.openFile(message.filePath)
                      : null,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSentByMe
                                    ? Colors.white.withValues(alpha: 0.3)
                                    : AppColor.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                _getFileIcon(message.fileName),
                                color: isSentByMe
                                    ? Colors.white
                                    : AppColor.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.fileName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isSentByMe
                                          ? Colors.white
                                          : AppColor.colorBlack,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatFileSize(message.fileSize),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isSentByMe
                                          ? Colors.white70
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // âœ… Progress Bar
                        if (isInProgress) ...[
                          const SizedBox(height: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: message.progress,
                                  backgroundColor: isSentByMe
                                      ? Colors.white.withValues(alpha: 0.3)
                                      : Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isSentByMe
                                        ? Colors.white
                                        : AppColor.primary,
                                  ),
                                  minHeight: 6,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${(message.progress * 100).toStringAsFixed(0)}% ${message.status == TransferStatus.sending ? "Uploading" : "Downloading"}...',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isSentByMe
                                      ? Colors.white70
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (!isInProgress)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isSentByMe
                                      ? Colors.white.withValues(alpha: 0.2)
                                      : AppColor.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getStatusIcon(message.status),
                                      size: 14,
                                      color: isSentByMe
                                          ? Colors.white
                                          : AppColor.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _getStatusText(message.status),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isSentByMe
                                            ? Colors.white
                                            : AppColor.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const Spacer(),
                            Text(
                              _formatTime(message.timestamp),
                              style: TextStyle(
                                fontSize: 11,
                                color: isSentByMe
                                    ? Colors.white70
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCodeSection() {
    return Obx(() {
      if (!(logic.session.value?.isHost ?? false)) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColor.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: QrImageView(
                data: RoomService.getQRData(),
                size: 200,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.circle,
                  color: AppColor.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Room ID: ${logic.session.value?.roomId ?? '---'}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      );
    });
  }

  // Disconnected Banner
  Widget _buildDisconnectedBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        border: Border(
          top: BorderSide(color: Colors.orange[300]!),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_rounded, color: Colors.orange[800]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${logic.connectedUser.value} has left the room',
              style: TextStyle(
                color: Colors.orange[900],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Input Area
  Widget _buildInputArea() {
    return Obx(() {
      if (logic.userDisconnected.value) {
        return _buildDisconnectedBanner();
      }
      {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Send File Button
              Expanded(
                child: Obx(
                  () => ElevatedButton.icon(
                    onPressed: logic.userDisconnected.value
                        ? null
                        : logic.pickAndSendFiles,
                    icon: const Icon(Icons.attach_file_rounded),
                    label: const Text(
                      'Send Files',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  // Utilities
  IconData _getFileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif'].contains(ext)) {
      return Icons.image_rounded;
    } else if (['mp4', 'avi', 'mkv'].contains(ext)) {
      return Icons.video_file_rounded;
    } else if (['mp3', 'wav', 'aac'].contains(ext)) {
      return Icons.audio_file_rounded;
    } else if (['pdf', 'doc', 'docx'].contains(ext)) {
      return Icons.description_rounded;
    } else if (['zip', 'rar'].contains(ext)) {
      return Icons.folder_zip_rounded;
    }
    return Icons.insert_drive_file_rounded;
  }

  IconData _getStatusIcon(status) {
    switch (status.toString()) {
      case 'TransferStatus.completed':
        return Icons.check_circle_rounded;
      case 'TransferStatus.sending':
      case 'TransferStatus.receiving':
        return Icons.sync_rounded;
      case 'TransferStatus.failed':
        return Icons.error_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }

  String _getStatusText(status) {
    switch (status.toString()) {
      case 'TransferStatus.completed':
        return 'Completed';
      case 'TransferStatus.sending':
        return 'Sending';
      case 'TransferStatus.receiving':
        return 'Receiving';
      case 'TransferStatus.failed':
        return 'Failed';
      default:
        return 'Waiting';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<bool> _showExitConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.exit_to_app_rounded, color: Colors.orange),
                SizedBox(width: 10),
                Text('Leave Room?'),
              ],
            ),
            content: const Text(
              'Are you sure you want to leave this transfer room?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Leave'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
