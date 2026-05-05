import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:zero_share/Widgets/common_bottom_widget.dart';
import 'package:zero_share/Widgets/common_button.dart';
import 'package:zero_share/Widgets/white_card_widget.dart';
import 'package:zero_share/generated/assets.dart';
import 'package:zero_share/models/plans_model.dart';
import 'package:zero_share/ui/premium_plans_page/premium_plans_logic.dart';
import 'package:zero_share/utils/color.dart';
import 'package:zero_share/utils/preference.dart';
import 'package:zero_share/utils/sizer_utils.dart';

import 'package:zero_share/Widgets/common_text.dart';
import 'package:zero_share/routes/app_routes.dart';

class PremiumPlansView extends StatelessWidget {
  PremiumPlansView({super.key});

  final controller = Get.find<PremiumPlansLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<PremiumPlansLogic>(
        builder: (controller) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppPaddings.padding_36,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: AppSizes.height_10),
                      SvgPicture.asset(Assets.iconsIcHomeOutlined),
                      SizedBox(height: AppSizes.height_2),
                      CommonText(
                        text: 'txtUnlockUnLimitedAccessToPremiumFeatures'.tr,
                        textColor: Get.theme.colorScheme.secondary,
                        fontSize: AppFontSize.size_20,
                      ),
                      SizedBox(height: AppSizes.height_2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppPaddings.padding_16,
                          vertical: AppPaddings.padding_04,
                        ),
                        decoration: BoxDecoration(
                          color: Get.theme.colorScheme.primary.withValues(
                            alpha: 0.07,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: CommonText(
                          text: 'txtMostPopular'.tr,
                          textColor: Get.theme.colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                          fontSize: AppFontSize.size_16,
                        ),
                      ),
                      SizedBox(height: AppSizes.height_4),
                    ],
                  ),

                  GetBuilder<PremiumPlansLogic>(
                    builder: (logic) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(width: AppSizes.width_4),
                          Expanded(
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                buildPlanContainer(logic.myPlans[0], () {
                                  debugPrint('Hello On Tap 1');
                                }),
                                Positioned(
                                  top: -12,
                                  left: 0,
                                  right: 0,
                                  child: Align(
                                    child: _buildSaveContainer(logic),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Stack(
                              children: [
                                buildPlanContainer(logic.myPlans[1], () {
                                  debugPrint('Hello On Tap 2');
                                }),
                              ],
                            ),
                          ),
                          SizedBox(width: AppSizes.width_4),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: AppSizes.height_2),
                  //options
                  _buildOptions(),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SizedBox(
        height: AppSizes.height_10,
        child: CommonBottomWidget(
          children: [
            SizedBox(width: AppSizes.width_4),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppPaddings.padding_24,
              ),
              child: CommonButton(
                onTap: () {
                  Preference.shared.setIsIntroductionWithPlans(true);
                  Get.toNamed(AppRoutes.home);
                  // Get.offNamedUntil(
                  //     AppRoutes.home, ModalRoute.withName(AppRoutes.home));
                },
                text: 'txtContinue'.tr,
              ),
            ),
            SizedBox(width: AppSizes.width_4),
          ],
        ),
      ),
    );
  }

  Widget buildPlanContainer(PlansModel plan, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppPaddings.padding_16),
        decoration: BoxDecoration(
          color: AppColor.colorWhite,
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: plan.isSaving == true
                ? AppColor.colorYellowDark
                : AppColor.colorWhite,
            width: 2.0,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: AppSizes.height_2),
            CommonText(
              text: plan.duration ?? '',
              textColor: Get.theme.colorScheme.secondary,
              fontWeight: FontWeight.w300,
              fontSize: AppFontSize.size_14,
            ),
            SizedBox(height: AppSizes.height_1),
            CommonText(
              text: 'PKR ${plan.discountedPrice}',
              textColor: Get.theme.colorScheme.secondary,
              fontWeight: FontWeight.w800,
              fontSize: AppFontSize.size_18,
            ),
            SizedBox(height: AppSizes.height_1),
            CommonText(
              text: plan.price?.toString() ?? '',
              textColor: AppColor.colorTextGreyLight,
              fontSize: AppFontSize.size_16,
              textDecoration: TextDecoration.lineThrough,
              decorationColor: AppColor.colorTextGreyLight,
            ),
            SizedBox(height: AppSizes.height_2),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveContainer(PremiumPlansLogic logic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppPaddings.padding_08),
      decoration: const BoxDecoration(
        color: AppColor.colorRed,
        boxShadow: [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: CommonText(
        textAlign: TextAlign.center,
        text: '${'Save ${logic.savePercentage}'}%',
        textColor: AppColor.colorYellowDark,
        fontWeight: FontWeight.w600,
        fontSize: AppFontSize.size_16,
      ),
    );
  }

  Widget buildRow({required String title, required String icon}) {
    return Row(
      children: [
        SvgPicture.asset(
          icon,
          width: AppSizes.width_4,
          height: AppSizes.height_4,
        ),
        SizedBox(width: AppSizes.width_4),
        Expanded(
          child: CommonText(
            text: title,
            textColor: Get.theme.colorScheme.secondary,
            fontSize: AppFontSize.size_16,
          ),
        ),
      ],
    );
  }

  Widget _buildOptions() {
    return Column(
      children: [
        SizedBox(height: AppSizes.height_2),
        WhiteCardWidget(
          onTap: () {},
          children: [
            buildRow(
              title: 'txtAdsFreeVersion'.tr,
              icon: Assets.iconsIcAdsFreeVersion,
            ),
          ],
        ),
        SizedBox(height: AppSizes.height_2),
        WhiteCardWidget(
          onTap: () {},
          children: [
            buildRow(
              title: 'txtUnlimitedDataTransfer'.tr,
              icon: Assets.iconsIcDataTransfer,
            ),
          ],
        ),
        SizedBox(height: AppSizes.height_2),
        WhiteCardWidget(
          onTap: () {},
          children: [
            buildRow(
              title: 'txtFastDataSharing'.tr,
              icon: Assets.iconsIcFastDataSharing,
            ),
          ],
        ),
        SizedBox(height: AppSizes.height_2),
        WhiteCardWidget(
          onTap: () {},
          children: [
            buildRow(
              title: 'txtSendLargeFiles'.tr,
              icon: Assets.iconsIcSendLargeFiles,
            ),
          ],
        ),
        SizedBox(height: AppSizes.height_2),
      ],
    );
  }
}
