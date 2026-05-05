import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zero_share/generated/assets.dart';
import 'package:zero_share/utils/color.dart';
import 'package:zero_share/utils/sizer_utils.dart';
import 'package:zero_share/Widgets/common_text.dart';
import 'package:zero_share/ui/splash_page/splash_logic.dart';

class SplashViewPage extends StatelessWidget {
  SplashViewPage({super.key});

  final controller = Get.find<SplashScreenLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.colorWhite,
      extendBodyBehindAppBar: true,
      body: GetBuilder<SplashScreenLogic>(
        builder: (logic) {
          return Stack(
            children: [
              Positioned.fill(
                child: Align(
                  child: Image.asset(
                    Assets.imagesLogoTransparent,
                    width: AppSizes.width_36,
                    height: AppSizes.height_36,
                  ),
                ),
              ),
              Positioned(
                top: 170,
                bottom: 0,
                left: 0,
                right: 0,
                child: Align(
                  child: CommonText(
                    textAlign: TextAlign.center,
                    text: 'ZeroShare - Transfer all files and data'.tr,
                    textColor: AppColor.colorWhite,
                    fontSize: AppFontSize.size_16,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
