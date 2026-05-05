import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zero_share/routes/app_routes.dart';
import 'package:zero_share/ui/home/home_view.dart';
import 'package:zero_share/ui/profile_page/profile_page_view.dart';
import 'package:zero_share/ui/received_app_gallery/files_gallery_view.dart';
import 'package:zero_share/ui/send_file_page/send_file_logic.dart';
import 'package:zero_share/ui/send_file_page/tabs/tab_music.dart';

class DashboardLogic extends GetxController with GetTickerProviderStateMixin {
  final RxInt currentIndex = 0.obs;

  final List<Widget> pages = <Widget>[
    const HomeView(),
    const TabMusic(),
    FilesView(showAppBar: false),
    ProfilePageView(),
  ];

  late final AnimationController fabAnimationController;
  late final AnimationController borderRadiusAnimationController;
  late final Animation<double> fabAnimation;
  late final Animation<double> borderRadiusAnimation;
  late final CurvedAnimation fabCurve;
  late final CurvedAnimation borderRadiusCurve;
  late final AnimationController hideBottomBarAnimationController;

  Timer? interstitialTimer;

  @override
  void onInit() {
    super.onInit();

    fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    borderRadiusAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    fabCurve = CurvedAnimation(
      parent: fabAnimationController,
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );

    borderRadiusCurve = CurvedAnimation(
      parent: borderRadiusAnimationController,
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );

    fabAnimation = Tween<double>(begin: 0, end: 1).animate(fabCurve);
    borderRadiusAnimation =
        Tween<double>(begin: 0, end: 1).animate(borderRadiusCurve);

    hideBottomBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    Future<void>.delayed(const Duration(seconds: 1), () {
      fabAnimationController.forward();
      borderRadiusAnimationController.forward();
    });
  }

  void changePage(int index) {
    currentIndex.value = index;
    update();
  }

  Future<void> openMusicTab() async {
    final SendFileLogic sendFileLogic = Get.isRegistered<SendFileLogic>()
        ? Get.find<SendFileLogic>()
        : Get.put(SendFileLogic(), permanent: true);

    sendFileLogic.manualupdatearg(2);
    await Get.toNamed(AppRoutes.sendFile);
    update();
  }

  void openHomeTab() {
    fabAnimationController
      ..reset()
      ..forward();
    borderRadiusAnimationController
      ..reset()
      ..forward();
    changePage(0);
  }

  @override
  void onClose() {
    interstitialTimer?.cancel();
    fabAnimationController.dispose();
    borderRadiusAnimationController.dispose();
    hideBottomBarAnimationController.dispose();
    super.onClose();
  }
}
