import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:zero_share/Widgets/common_text.dart';
import 'package:zero_share/generated/assets.dart';
import 'package:zero_share/utils/constant.dart';

import 'package:zero_share/utils/sizer_utils.dart';

import 'package:zero_share/utils/color.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final VoidCallback? onBackTap;
  final VoidCallback? onActionTap;
  final Widget? actionWidget;
  final bool showBackArrow;

  const CommonAppBar({
    super.key,
    this.title,
    this.onBackTap,
    this.onActionTap,
    this.actionWidget,
    this.showBackArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    Constant.languageEn;
    return Container(
      padding: Platform.isIOS
          ? EdgeInsets.zero
          : EdgeInsets.only(top: AppSizes.height_3_5),
      decoration: BoxDecoration(
        color: Get.context!.theme.colorScheme.inversePrimary,
        borderRadius: const BorderRadiusDirectional.only(
          bottomStart: Radius.circular(30),
          bottomEnd: Radius.circular(30),
        ),
      ),
      child: AppBar(
        backgroundColor: Get.context!.theme.colorScheme.inversePrimary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.only(
            bottomStart: Radius.circular(30),
            bottomEnd: Radius.circular(30),
          ),
        ),
        //  elevation: 10,
        surfaceTintColor: Get.context!.theme.colorScheme.inversePrimary,
        shadowColor: Get.theme.colorScheme.primary.withValues(alpha: 0.3),
        centerTitle: true,
        title: CommonText(
          text: title ?? '',
          textColor: AppColor.primary,
          fontSize: AppFontSize.size_18,
        ),
        titleSpacing: AppSizes.width_1,
        leading: Visibility(
          visible: showBackArrow,
          child: RotatedBox(
            quarterTurns: 0,
            child: Container(
              color: Colors.transparent,
              margin: EdgeInsetsDirectional.only(start: AppSizes.width_3),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  splashColor: AppColor.colorGreyLight,
                  child: IconButton(
                    splashColor: AppColor.colorGreyLight,
                    icon: SvgPicture.asset(
                      Assets.iconsIcArrowBack,
                      height: AppSizes.height_2_5,
                      width: AppSizes.height_2_5,
                    ),
                    onPressed: onBackTap ??
                        () {
                          Get.forceAppUpdate();
                          Get.back();
                        },
                  ),
                ),
              ),
            ),
          ),
        ),
        actions: [
          if (actionWidget != null)
            Container(
              margin: EdgeInsetsDirectional.only(end: AppSizes.width_5_5),
              child: IconButton(icon: actionWidget!, onPressed: onActionTap),
            ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        Platform.isIOS ? AppFontSize.size_50 : AppFontSize.size_75,
      );
}
