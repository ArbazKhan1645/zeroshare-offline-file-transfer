import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:zero_share/Widgets/common_gradient_bg.dart';
import 'package:zero_share/routes/app_routes.dart';
import 'package:zero_share/services/history_service.dart';
import 'package:zero_share/ui/home/home_logic.dart';
import 'package:zero_share/ui/received_app_gallery/files_gallery_view.dart';
import 'package:zero_share/ui/send_file_page/send_file_logic.dart';
import 'package:zero_share/utils/color.dart';
import 'package:zero_share/utils/sizer_utils.dart';
import 'package:zero_share/Widgets/common_text.dart';
import 'package:zero_share/Widgets/stacked_images.dart';
import 'package:zero_share/generated/assets.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.onSurface,
      body: GetBuilder<HomeLogic>(
        init: HomeLogic(),
        builder: (logic) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: AppSizes.height_4),
              _buildSectionTitle('txtRecent'.tr),
              _buildRecentFilesSection(logic),
              const SizedBox(height: 200),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.35,
      child: CommonGradientBGWidget(
        children: [
          SizedBox(height: AppSizes.height_8),
          _buildAppBar(),
          SizedBox(height: AppSizes.height_6),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.primary,
              ),
              child: Image.asset(
                Assets.imagesLogoTransparent,
                width: AppSizes.width_12,
              ),
            ),
            SizedBox(width: AppSizes.width_2),
            CommonText(
              text: 'txtAppTitle'.tr.toUpperCase(),
              textColor: Get.theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
              fontSize: AppFontSize.size_16,
            ),
          ],
        ),
        IconButton(
          icon: Icon(
            Icons.person_2_outlined,
            color: AppColor.primary,
            size: AppSizes.height_3,
          ),
          onPressed: () => Get.toNamed(AppRoutes.profilePage),
          splashRadius: 24,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final actions = [
      _ActionButton(
        icon: Assets.iconsIcSend,
        label: 'txtSend'.tr,
        onTap: () {
          final con = Get.isRegistered<SendFileLogic>()
              ? Get.find<SendFileLogic>()
              : Get.put(SendFileLogic(), permanent: true);
          con.manualupdatearg(0);

          Get.toNamed(AppRoutes.sendFile);
        },
      ),
      _ActionButton(
        icon: Assets.iconsIcReceive,
        label: 'txtReceive'.tr,
        onTap: () {
          Get.toNamed(AppRoutes.receivePage);
        },
      ),
      _ActionButton(
        icon: Assets.iconsIcConnect,
        label: 'Room',
        onTap: () {
          Get.toNamed(AppRoutes.connectPage);
        },
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: CommonText(
        text: title,
        textColor: Get.theme.colorScheme.secondary,
        fontWeight: FontWeight.w600,
        fontSize: AppFontSize.size_16,
      ),
    );
  }

  Widget _buildRecentFilesSection(HomeLogic logic) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPaddings.padding_20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColor.colorWhite,
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(AppPaddings.padding_08),
        child: Column(
          children: [
            SizedBox(height: AppSizes.height_1),
            _buildRecentGrid(logic),
            _buildViewAllSection(logic),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentGrid(HomeLogic logic) {
    // Use StreamBuilder for real-time updates
    return StreamBuilder<List<TransferHistory>>(
      stream: HistoryService.historyStream,
      initialData: logic.recentHistory,
      builder: (context, snapshot) {
        // Show loading indicator only on initial load
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final histories = snapshot.data ?? [];
        final recentHistories = histories.take(6).toList();

        // Show empty state if no history
        if (recentHistories.isEmpty) {
          return _buildEmptyState();
        }

        // Build grid with recent files
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: recentHistories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            final file = recentHistories[index];
            return _FileCard(file: file);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(
              Icons.folder_open_rounded,
              size: 64,
              color: AppColor.colorGreyDark.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            CommonText(
              text: 'No recent files'.tr,
              textColor: AppColor.colorGreyDark,
              fontSize: AppFontSize.size_14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewAllSection(HomeLogic logic) {
    return Obx(() {
      if (logic.recentImagePaths.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppSizes.height_3),
          CommonText(
            text: 'txtCheckRecentlyAddedFiles'.tr,
            textColor: Get.theme.colorScheme.secondary,
            fontWeight: FontWeight.w400,
            fontSize: AppFontSize.size_14,
          ),
          SizedBox(height: AppSizes.height_1),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppPaddings.padding_12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomStackImages(urlImages: logic.recentImagePaths),
                _ViewButton(
                  onTap: () => Get.to(() => FilesView(showAppBar: true)),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

// ========== Custom Widgets ==========

class _ActionButton extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: AppSizes.width_15,
            height: AppSizes.height_7,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.primary,
            ),
            child: SvgPicture.asset(
              icon,
              fit: BoxFit.scaleDown,
            ),
          ),
          SizedBox(height: AppSizes.height_2),
          CommonText(
            text: label,
            textColor: Get.theme.colorScheme.primary,
            fontWeight: FontWeight.w400,
            fontSize: AppFontSize.size_14,
          ),
        ],
      ),
    );
  }
}

class _FileCard extends StatelessWidget {
  final TransferHistory file;

  const _FileCard({required this.file});

  @override
  Widget build(BuildContext context) {
    final isReceived = file.isReceived;
    final fileType = _getFileType(file.fileName);

    return InkWell(
      onTap: () => _openFile(file.filePath),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File Preview/Icon Section
            Expanded(
              flex: 3,
              child: _buildFilePreview(fileType, file.filePath),
            ),

            // File Info Section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // File name
                    Text(
                      file.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // File details
                    Row(
                      children: [
                        Icon(
                          isReceived
                              ? Icons.download_rounded
                              : Icons.upload_rounded,
                          size: 14,
                          color: isReceived ? Colors.green : Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${file.sizeFormatted} â€¢ ${file.timeFormatted}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview(FileType type, String? filePath) {
    return Container(
      decoration: BoxDecoration(
        color: _getFileTypeColor(type).withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Center(
        child: _buildFileTypeWidget(type, filePath),
      ),
    );
  }

  Widget _buildFileTypeWidget(FileType type, String? filePath) {
    switch (type) {
      case FileType.image:
        return _buildImagePreview(filePath);

      case FileType.video:
        return Stack(
          alignment: Alignment.center,
          children: [
            if (filePath != null && filePath.isNotEmpty)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.file(
                  File(filePath),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => _buildFileIcon(type),
                ),
              )
            else
              _buildFileIcon(type),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ],
        );

      default:
        return _buildFileIcon(type);
    }
  }

  Widget _buildImagePreview(String? filePath) {
    if (filePath == null || filePath.isEmpty) {
      return _buildFileIcon(FileType.image);
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Image.file(
        File(filePath),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => _buildFileIcon(FileType.image),
      ),
    );
  }

  Widget _buildFileIcon(FileType type) {
    return Icon(
      _getFileTypeIcon(type),
      size: 56,
      color: _getFileTypeColor(type),
    );
  }

  FileType _getFileType(String fileName) {
    final ext = fileName.toLowerCase().split('.').last;

    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext)) {
      return FileType.image;
    } else if (['mp4', 'avi', 'mkv', 'mov', 'wmv', 'flv'].contains(ext)) {
      return FileType.video;
    } else if (['mp3', 'wav', 'aac', 'flac', 'm4a'].contains(ext)) {
      return FileType.audio;
    } else if (['pdf'].contains(ext)) {
      return FileType.pdf;
    } else if (['doc', 'docx'].contains(ext)) {
      return FileType.doc;
    } else if (['xls', 'xlsx'].contains(ext)) {
      return FileType.excel;
    } else if (['zip', 'rar', '7z', 'tar'].contains(ext)) {
      return FileType.archive;
    } else if (['apk'].contains(ext)) {
      return FileType.apk;
    }

    return FileType.other;
  }

  IconData _getFileTypeIcon(FileType type) {
    switch (type) {
      case FileType.image:
        return Icons.image_rounded;
      case FileType.video:
        return Icons.videocam_rounded;
      case FileType.audio:
        return Icons.audiotrack_rounded;
      case FileType.pdf:
        return Icons.picture_as_pdf_rounded;
      case FileType.doc:
        return Icons.description_rounded;
      case FileType.excel:
        return Icons.table_chart_rounded;
      case FileType.archive:
        return Icons.folder_zip_rounded;
      case FileType.apk:
        return Icons.android_rounded;
      case FileType.other:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _getFileTypeColor(FileType type) {
    switch (type) {
      case FileType.image:
        return Colors.purple;
      case FileType.video:
        return Colors.red;
      case FileType.audio:
        return Colors.orange;
      case FileType.pdf:
        return Colors.redAccent;
      case FileType.doc:
        return Colors.blue;
      case FileType.excel:
        return Colors.green;
      case FileType.archive:
        return Colors.amber;
      case FileType.apk:
        return Colors.teal;
      case FileType.other:
        return Colors.grey;
    }
  }

  void _openFile(String filePath) {
    if (filePath.isEmpty) {
      Get.snackbar(
        'Error',
        'File path not found',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    OpenFile.open(filePath).then((result) {
      if (result.type != ResultType.done) {
        Get.snackbar(
          'Error',
          result.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    });
  }
}

class _ViewButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ViewButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppPaddings.padding_24,
          vertical: AppPaddings.padding_08,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColor.primaryLight,
        ),
        child: CommonText(
          text: 'txtView'.tr,
          textColor: Get.theme.colorScheme.primary,
          fontSize: AppFontSize.size_14,
        ),
      ),
    );
  }
}

enum FileType {
  image,
  video,
  audio,
  pdf,
  doc,
  excel,
  archive,
  apk,
  other,
}
