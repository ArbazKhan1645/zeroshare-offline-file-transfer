// lib/ui/received_app_gallery/files_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:zero_share/services/history_service.dart';

import 'package:zero_share/Widgets/common_text.dart';
import 'package:zero_share/utils/color.dart';
import 'package:zero_share/utils/sizer_utils.dart';
import 'package:zero_share/ui/received_app_gallery/files_gallery_logic.dart';

class FilesView extends StatelessWidget {
  final bool showAppBar;

  FilesView({super.key, required this.showAppBar}) {
    Get.lazyPut(() => FilesLogic());
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FilesLogic>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: AppColor.primary,
          elevation: 0,
          title: CommonText(
            text: 'History',
            textColor: AppColor.colorWhite,
            fontWeight: FontWeight.w600,
            fontSize: AppFontSize.size_18,
          ),
          leading: showAppBar
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                )
              : null,
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.white),
              onPressed: () => _showClearHistoryDialog(context, controller),
              tooltip: 'Clear History',
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Received'),
              Tab(text: 'Sent'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildHistoryList(controller),
            _buildHistoryList(controller, filterReceived: true),
            _buildHistoryList(controller, filterSent: true),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(
    FilesLogic controller, {
    bool filterReceived = false,
    bool filterSent = false,
  }) {
    return FutureBuilder<List<TransferHistory>>(
      future: _getHistory(filterReceived, filterSent),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.history, size: 64, color: Colors.grey[400]),
                ),
                const SizedBox(height: 24),
                Text(
                  'No transfer history',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your transfers will appear here',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        final histories = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: histories.length,
          itemBuilder: (context, index) {
            final item = histories[index];
            return _buildModernCard(item, context, controller);
          },
        );
      },
    );
  }

  Widget _buildModernCard(
    TransferHistory item,
    BuildContext context,
    FilesLogic controller,
  ) {
    final isReceived = item.isReceived;
    final primaryColor = isReceived ? Colors.green : Colors.blue;
    final lightColor = isReceived ? Colors.green[50] : Colors.blue[50];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isReceived
              ? () => _openFile(item, context)
              : () => _openFile(item, context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: lightColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _getFileIcon(item.fileName),
                    color: primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: lightColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isReceived ? Icons.download : Icons.upload,
                                  size: 12,
                                  color: primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isReceived ? 'Received' : 'Sent',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.sizeFormatted,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${item.senderName} â€¢ ${item.senderIP}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.timeFormatted,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.more_vert,
                      size: 20,
                      color: Colors.grey[700],
                    ),
                  ),
                  onSelected: (value) =>
                      _handleMenuAction(value, item, context, controller),
                  itemBuilder: (context) => [
                    if (item.isReceived)
                      const PopupMenuItem(
                        value: 'open',
                        child: Row(
                          children: [
                            Icon(
                              Icons.open_in_new,
                              size: 20,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Open File',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Colors.red,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension)) {
      return Icons.image;
    } else if (['mp4', 'avi', 'mkv', 'mov', 'wmv'].contains(extension)) {
      return Icons.video_library;
    } else if (['mp3', 'wav', 'aac', 'flac', 'm4a'].contains(extension)) {
      return Icons.music_note;
    } else if (['pdf'].contains(extension)) {
      return Icons.picture_as_pdf;
    } else if (['doc', 'docx'].contains(extension)) {
      return Icons.description;
    } else if (['zip', 'rar', '7z'].contains(extension)) {
      return Icons.folder_zip;
    } else if (['apk'].contains(extension)) {
      return Icons.android;
    }
    return Icons.insert_drive_file;
  }

  Future<List<TransferHistory>> _getHistory(
    bool filterReceived,
    bool filterSent,
  ) async {
    if (filterReceived) {
      return await HistoryService.getReceivedHistory();
    } else if (filterSent) {
      return await HistoryService.getSentHistory();
    } else {
      return await HistoryService.getAllHistory();
    }
  }

  Future<void> _handleMenuAction(
    String action,
    TransferHistory item,
    BuildContext context,
    FilesLogic controller,
  ) async {
    switch (action) {
      case 'open':
        await _openFile(item, context);
        break;
      case 'delete':
        await _deleteHistoryItem(item, context, controller);
        break;
    }
  }

  Future<void> _openFile(TransferHistory item, BuildContext context) async {
    final File file = File(item.filePath);

    if (!await file.exists()) {
      if (context.mounted) {
        _showError(context, 'File not found');
      }

      return;
    }

    try {
      final result = await OpenFile.open(item.filePath);
      if (result.type != ResultType.done) {
        if (context.mounted) {
          _showError(context, 'Could not open file: ${result.message}');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Error opening file: $e');
      }
    }
  }

  Future<void> _deleteHistoryItem(
    TransferHistory item,
    BuildContext context,
    FilesLogic controller,
  ) async {
    await HistoryService.deleteHistory(item.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Removed from history'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }

    await controller.loadHistory();
  }

  Future<void> _showClearHistoryDialog(
    BuildContext context,
    FilesLogic controller,
  ) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Clear History',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Are you sure you want to clear all transfer history? This action cannot be undone.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Clear All',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await HistoryService.clearAllHistory();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('History cleared successfully'),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }

      await controller.loadHistory();
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
