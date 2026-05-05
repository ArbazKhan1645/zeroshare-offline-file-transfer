// lib/ui/send_file_page/send_file_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:zero_share/Widgets/common_button.dart';

import 'package:zero_share/generated/assets.dart';
import 'package:zero_share/routes/app_routes.dart';
import 'package:zero_share/ui/send_file_page/send_file_logic.dart';
import 'package:zero_share/ui/send_file_page/tabs/tab_documents.dart';
import 'package:zero_share/ui/send_file_page/tabs/tab_music.dart';
import 'package:zero_share/ui/send_file_page/tabs/tab_photo.dart';
import 'package:zero_share/ui/send_file_page/tabs/tab_videos.dart';
import 'package:zero_share/Widgets/common_text.dart';
import 'package:zero_share/utils/color.dart';
import 'package:zero_share/utils/sizer_utils.dart';
import 'package:zero_share/utils/utils.dart';

class SendFileView extends StatelessWidget {
  const SendFileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SendFileLogic>();

    return Scaffold(
      body: FutureBuilder(
        // ðŸ‘‡ Add small delay (e.g. 300â€“500ms) before building the UI
        future: Future.delayed(const Duration(milliseconds: 500)),
        builder: (context, snapshot) {
          // âœ… Now render the main body
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                expandedHeight: 170.0,
                pinned: true,
                clipBehavior: Clip.none,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: const AppBarBackground(),
                  centerTitle: true,
                  titlePadding: const EdgeInsets.only(bottom: 70),
                  title: CommonText(
                    text: 'Send Files',
                    textColor: Get.theme.colorScheme.secondary,
                    fontSize: AppFontSize.size_16,
                  ),
                ),
                leading: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: AppColor.colorGreyLight,
                    child: SvgPicture.asset(
                      Assets.iconsIcArrowBack,
                      fit: BoxFit.scaleDown,
                    ),
                    onTap: () => Get.back(),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: Container(
                    alignment: Alignment.center,
                    child: TabBar(
                      controller: controller.tabController,
                      onTap: controller.changeTab,
                      indicatorPadding:
                          const EdgeInsets.symmetric(horizontal: 8),
                      indicatorWeight: 4.0,
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                      dividerColor: Colors.transparent,
                      labelStyle: TextStyle(
                        color: Get.theme.colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                        fontSize: AppFontSize.size_14,
                      ),
                      unselectedLabelStyle: TextStyle(
                        color: Get.theme.colorScheme.secondary
                            .withValues(alpha: 0.6),
                        fontWeight: FontWeight.w400,
                        fontSize: AppFontSize.size_14,
                      ),
                      tabs: const [
                        Tab(text: 'Photos'),
                        Tab(text: 'Videos'),
                        Tab(text: 'Music'),
                        Tab(text: 'Others'),
                      ],
                    ),
                  ),
                ),
              ),
              SliverFillRemaining(
                child: TabBarView(
                  controller: controller.tabController,
                  children: const [
                    TabPhoto(),
                    TabVideos(),
                    TabMusic(),
                    TabDocuments(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const BottomNavBarWidget(),
    );
  }
}

class BottomNavBarWidget extends StatelessWidget {
  const BottomNavBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SendFileLogic>();

    return Container(
      decoration: const BoxDecoration(
        color: AppColor.colorWhite,
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryLight,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40.0),
          topRight: Radius.circular(40.0),
        ),
        border: Border.fromBorderSide(
          BorderSide(color: AppColor.colorTextGreyLight),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16.0),
              child: SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Obx(() {
                        final totalCount = controller.totalSelectedFileCount;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText(
                              text: totalCount == 0
                                  ? 'No files selected'
                                  : totalCount == 1
                                      ? '1 file selected'
                                      : '$totalCount files selected',
                              fontSize: AppFontSize.size_14,
                            ),
                            if (totalCount > 0) ...[
                              const SizedBox(height: 4),
                              CommonText(
                                text: controller.getSelectedFilesInfo(),
                                textColor: AppColor.colorTextGreyLight,
                                fontSize: AppFontSize.size_12,
                              ),
                            ],
                          ],
                        );
                      }),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Obx(() {
                        final hasSelection =
                            controller.totalSelectedFileCount > 0;
                        return CommonButton(
                          onTap: hasSelection
                              ? () async {
                                  await _handleSendFiles(controller);
                                }
                              : () {},
                          text: 'Send',
                          backgroundColor: hasSelection
                              ? AppColor.primary
                              : AppColor.colorTextGreyLight,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSendFiles(SendFileLogic controller) async {
    try {
      await controller.requestPermissions();

      List<File> filesToSend = await controller.getAllSelectedFiles();

      if (controller.selectedDocumentFiles.isNotEmpty) {
        filesToSend.addAll(controller.selectedDocumentFiles);
      }

      if (filesToSend.isEmpty) {
        await Utils.showToast(Get.context, 'No files selected');
        return;
      }

      // âœ… Remove duplicates (by file name + extension + path)
      final uniqueFiles = <String, File>{};
      for (var file in filesToSend) {
        final name = file.path.split('/').last.toLowerCase();
        final ext = name.split('.').length > 1 ? name.split('.').last : '';
        final key = '${name}_${ext}_${file.path.toLowerCase()}';
        uniqueFiles[key] = file;
      }

      filesToSend = uniqueFiles.values.toList();

      // âœ… Proceed with only unique files
      await Get.toNamed(
        AppRoutes.sendingProgressPage,
        arguments: filesToSend,
      );
    } catch (e) {
      await Utils.showToast(Get.context, 'Error preparing files: $e');
    }
  }
}

class AppBarBackground extends StatelessWidget {
  const AppBarBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColor.primary,
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryLight,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        gradient: LinearGradient(
          colors: [AppColor.colorWhite, AppColor.primaryLight],
          begin: Alignment.center,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40.0),
          bottomRight: Radius.circular(40.0),
        ),
      ),
    );
  }
}
