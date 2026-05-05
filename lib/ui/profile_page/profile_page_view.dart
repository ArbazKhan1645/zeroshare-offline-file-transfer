// ignore_for_file: avoid_dynamic_calls

import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:zero_share/Widgets/common_text.dart';

import 'package:zero_share/generated/assets.dart';
import 'package:zero_share/utils/color.dart';

import 'package:zero_share/Widgets/common_gradient_bg.dart';
import 'package:zero_share/Widgets/text_form_field.dart';
import 'package:zero_share/utils/constant.dart';
import 'package:zero_share/utils/sizer_utils.dart';
import 'package:zero_share/ui/profile_page/profile_page_logic.dart';

class ProfilePageView extends StatelessWidget {
  ProfilePageView({super.key});

  final logic = Get.find<ProfilePageLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.onSurface,
      body: GetBuilder<ProfilePageLogic>(
        builder: (controller) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                SizedBox(height: AppSizes.height_2),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppPaddings.padding_36,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          controller.changeAvatar(context);
                        },
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: AppColor.primary,
                              child: controller.selectedAvatarImage == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: AppColor.colorWhite,
                                    )
                                  : ClipOval(
                                      child: Image.asset(
                                        controller.selectedAvatarImage!,
                                        fit: BoxFit.cover,
                                        width: 80,
                                        height: 80,
                                      ),
                                    ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  splashColor: AppColor.colorGreyLight,
                                  onTap: () async {
                                    await controller.changeAvatar(context);
                                  },
                                  child: const CircleAvatar(
                                    radius: 12,
                                    backgroundColor: AppColor.colorWhite,
                                    child: Icon(
                                      Icons.camera_alt,
                                      size: 15,
                                      color: AppColor.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSizes.height_2),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CommonText(
                            text: 'Name'.tr,
                            textColor: Get.theme.colorScheme.secondary,
                            fontSize: AppFontSize.size_14,
                          ),
                          SizedBox(height: AppSizes.height_1),
                          GetBuilder<ProfilePageLogic>(
                            id: Constant.idUserNameInput,
                            builder: (logic) {
                              return CommonTextFormField(
                                controller: logic.userNameController,
                                hintText: 'Enter Name'.tr,
                                fillColor: Get
                                    .theme.colorScheme.surfaceContainerHighest,
                                validatorText: 'txtEnterUserName'.tr,
                                onTextChanged: (value) {
                                  logic.saveUserName(
                                    value,
                                  ); // Save username on submit
                                },
                              );
                            },
                          ),
                          SizedBox(height: AppSizes.height_2),
                        ],
                      ),
                      SizedBox(height: AppSizes.height_4),
                      // Menu buttons
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MenuButton(
                            icon: Icons.share,
                            text: 'Share App',
                            onTap: () {
                              controller.shareApp();
                            },
                          ),
                          MenuButton(
                            icon: Icons.privacy_tip,
                            text: 'Privacy & Policy',
                            onTap: () {
                              controller.viewPrivacyPolicy();
                            },
                          ),
                          MenuButton(
                            icon: Icons.star,
                            text: 'Rate Us',
                            onTap: () {
                              controller.requestReview();
                            },
                          ),
                          // MenuButton(
                          //     icon: Icons.info,
                          //     text: 'How To Use?',
                          //     onTap: () {}),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return GetBuilder<ProfilePageLogic>(
      builder: (logic) {
        return SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.28,
          child: CommonGradientBGWidget(
            children: [
              SizedBox(height: AppSizes.height_8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(100.0),
                          ),
                          color: AppColor.primary,
                        ),
                        child: Image.asset(
                          Assets.imagesLogoTransparent,
                          width: AppSizes.width_12,
                        ),
                      ),
                      SizedBox(width: AppSizes.width_2),
                      CommonText(
                        textAlign: TextAlign.center,
                        text: 'txtAppTitle'.tr.toUpperCase(),
                        textColor: Get.theme.colorScheme.primary,
                        fontSize: AppFontSize.size_16,
                      ),
                    ],
                  ),
                  //Search icon disabled --Update 2
                  // Material(
                  //   color: Colors.transparent,
                  //   child: InkWell(
                  //     splashColor: AppColor.colorGreyLight,
                  //     child: SvgPicture.asset(
                  //       Assets.iconsIcSearch,
                  //       color: AppColor.primary,
                  //     ),
                  //     onTap: () {
                  //       // Handle search button press
                  //       Get.back();
                  //     },
                  //   ),
                  // ),
                ],
              ),
              SizedBox(height: AppSizes.height_4),
              CommonText(
                text:
                    'Effortlessly Share Your Files with Ease and Precision!'.tr,
                textColor: Get.theme.colorScheme.secondary,
                fontWeight: FontWeight.w400,
                fontSize: AppFontSize.size_14,
              ),
            ],
          ),
        );
      },
    );
  }
}

class MenuButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Function onTap;

  const MenuButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: AppColor.colorGreyLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: AppColor.primary,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(icon, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  CommonText(
                    text: text,
                    textColor: Get.theme.colorScheme.secondary,
                    fontSize: AppFontSize.size_16,
                  ),
                ],
              ),
              SvgPicture.asset(
                Assets.iconsIcArrowForward,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
