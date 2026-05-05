import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zero_share/Widgets/common_text.dart';
import 'package:zero_share/generated/assets.dart';
import 'package:zero_share/utils/sizer_utils.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CommonButton extends StatelessWidget {
  final void Function() onTap;

  final String text;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? shadowColor;
  final Color? iconColor;
  final String? icon;
  final bool showIcon;

  const CommonButton({
    super.key,
    required this.onTap,
    required this.text,
    this.backgroundColor,
    this.foregroundColor,
    this.shadowColor,
    this.icon,
    this.iconColor,
    this.showIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.fullWidth - 50,
      height: AppSizes.height_6,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: (shadowColor ?? Get.theme.colorScheme.primary).withValues(
                alpha: 0.5,
              ),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onTap,
          // style: ButtonStyle(elevation: MaterialStateProperty(12.0 )),
          style: ElevatedButton.styleFrom(
            //shadowColor: Get.theme.colorScheme.primary,
            elevation: 0,
            backgroundColor: backgroundColor ?? Get.theme.colorScheme.primary,
            foregroundColor: foregroundColor ?? Get.theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            splashFactory: InkSplash.splashFactory,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CommonText(
                text: text,
                textColor: Get.theme.colorScheme.onSurfaceVariant,
                textAlign: TextAlign.center,
                fontSize: AppFontSize.size_16,
              ),
              Visibility(
                visible: showIcon,
                child: SvgPicture.asset(
                  Assets.iconsIcArrowForward,
                  width: AppSizes.width_6,
                  height: AppSizes.width_6,
                  fit: BoxFit.scaleDown,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
