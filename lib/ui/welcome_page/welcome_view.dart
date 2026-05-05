import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zero_share/Widgets/common_button_with_icon.dart';
import 'package:zero_share/Widgets/common_text.dart';
import 'package:zero_share/generated/assets.dart';
import 'package:zero_share/utils/sizer_utils.dart';
import 'package:zero_share/utils/preference.dart';
import 'package:zero_share/ui/welcome_page/welcome_logic.dart';

class WelcomeScreenPage extends StatelessWidget {
  WelcomeScreenPage({super.key});

  final controller = Get.find<WelcomeScreenLogic>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.primary,
      body: GetBuilder<WelcomeScreenLogic>(
        builder: (logic) {
          return Stack(
            children: [
              Align(
                child: Image.asset(
                  Assets.imagesLogoTransparent,
                  width: AppSizes.width_36,
                  height: AppSizes.height_36,
                ),
              ),
              Positioned(
                bottom: MediaQuery.of(context).size.height / 2 - 200,
                right: 24,
                left: 24,
                child: CommonText(
                  textAlign: TextAlign.center,
                  text: 'txtZeroShareTRANSFERDATA'.tr,
                  textColor: Get.theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: AppFontSize.size_24,
                ),
              ),
              Positioned(
                bottom: 90,
                right: 64,
                left: 64,
                child: CommonButtonWithIcon(
                  onTap: () {
                    Preference.shared.setIsGetStarted(true);
                    logic.navigateToPlans();
                  },
                  text: 'txtStart'.tr,
                  icon: Assets.iconsIcArrowForward,
                  iconColor: Get.theme.colorScheme.onPrimary,
                  backgroundColor: Get.theme.colorScheme.onPrimary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
