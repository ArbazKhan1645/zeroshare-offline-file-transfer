import 'dart:io';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:zero_share/Widgets/common_text.dart';
import 'package:zero_share/ui/dashboard/dashboard_logic.dart';
import 'package:zero_share/utils/color.dart';
import 'package:zero_share/utils/sizer_utils.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  static const List<IconData> _iconList = <IconData>[
    Icons.history,
    Icons.music_note,
    Icons.folder,
    Icons.more_horiz,
  ];

  static const List<String> _labels = <String>[
    'Recent',
    'Music',
    'History',
    'More',
  ];

  Future<void> _handleBackNavigation() async {
    final bool shouldExit =
        await Get.dialog<bool>(
          AlertDialog(
            backgroundColor: AppColor.colorWhite,
            title: CommonText(
              text: 'Exit ZeroShare!'.tr,
              textColor: AppColor.primary,
              fontSize: AppFontSize.size_18,
            ),
            content: CommonText(
              text: 'Do you want to exit ZeroShare?'.tr,
              textColor: AppColor.primary,
              fontSize: AppFontSize.size_16,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Get.back(result: false),
                child: CommonText(
                  text: 'No'.tr,
                  textColor: AppColor.primary,
                  fontSize: AppFontSize.size_16,
                ),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: CommonText(
                  text: 'Yes'.tr,
                  textColor: AppColor.primary,
                  fontSize: AppFontSize.size_16,
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldExit) {
      return;
    }

    if (Platform.isAndroid) {
      await SystemNavigator.pop();
      return;
    }

    exit(0);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!didPop) {
          await _handleBackNavigation();
        }
      },
      child: GetBuilder<DashboardLogic>(
        builder: (controller) {
          return Scaffold(
            extendBody: true,
            body: Obx(() => controller.pages[controller.currentIndex.value]),
            floatingActionButton: FloatingActionButton(
              backgroundColor: AppColor.primary,
              elevation: 2,
              onPressed: controller.openHomeTab,
              shape: const CircleBorder(),
              child: const Icon(Icons.home, color: AppColor.colorWhite),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: AnimatedBottomNavigationBar.builder(
              itemCount: _iconList.length,
              backgroundColor: AppColor.colorWhite,
              activeIndex: controller.currentIndex.value,
              gapLocation: GapLocation.center,
              notchSmoothness: NotchSmoothness.softEdge,
              splashColor: AppColor.primary,
              notchAndCornersAnimation: controller.borderRadiusAnimation,
              hideAnimationController:
                  controller.hideBottomBarAnimationController,
              shadow: const BoxShadow(
                offset: Offset(0, -2),
                blurRadius: 10,
                spreadRadius: 2,
                color: Colors.black12,
              ),
              tabBuilder: (int index, bool isActive) {
                final Color color = isActive
                    ? AppColor.primary
                    : AppColor.colorTextGreyLight;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(_iconList[index], size: 24, color: color),
                    const SizedBox(height: 4),
                    Text(
                      _labels[index],
                      style: TextStyle(
                        color: color,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
              onTap: (int index) async {
                if (index == 1) {
                  await controller.openMusicTab();
                  return;
                }

                controller.changePage(index);
              },
            ),
          );
        },
      ),
    );
  }
}
