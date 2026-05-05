import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:zero_share/Widgets/common_text.dart';
import 'package:zero_share/utils/color.dart';
import 'package:zero_share/utils/sizer_utils.dart';

class CommonButtonWithIcon extends StatefulWidget {
  final void Function() onTap;
  final String text, icon;
  final double? iconSize, fontSize, width;
  final Color? backgroundColor, textColor, borderColor;
  final Color iconColor;

  const CommonButtonWithIcon({
    super.key,
    required this.onTap,
    required this.text,
    this.iconSize,
    this.fontSize,
    this.width,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    required this.icon,
    required this.iconColor,
  });

  @override
  State<CommonButtonWithIcon> createState() => _CommonButtonWithIconState();
}

class _CommonButtonWithIconState extends State<CommonButtonWithIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  bool isDragged = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.1, 0.0), // Move slightly forward
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat(reverse: true); // Repeat animation back and forth
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? (AppSizes.fullWidth - 80),
      height: AppSizes.height_6,
      child: ElevatedButton(
        onPressed: widget.onTap,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: widget.borderColor ?? Get.theme.colorScheme.primary,
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          splashFactory: InkSplash.splashFactory,
          surfaceTintColor: Get.theme.colorScheme.primary,
          foregroundColor: widget.backgroundColor != null
              ? Get.theme.colorScheme.primary
              : Get.theme.colorScheme.surface,
          backgroundColor:
              widget.backgroundColor ?? Get.theme.colorScheme.primary,
        ),
        child: Row(
          children: [
            // Draggable Widget with Animation
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppPaddings.padding_08,
              ),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return SlideTransition(
                    position: _animation,
                    child: Draggable(
                      axis: Axis.horizontal,
                      // data: "icon", // Data to be dragged
                      feedback: Container(
                        width: AppSizes.width_8,
                        height: AppSizes.width_8,
                        decoration: BoxDecoration(
                          color: Get.theme.colorScheme.primary,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(50),
                          ),
                        ),
                        child: SvgPicture.asset(
                          widget.icon,
                          width: widget.iconSize ?? AppSizes.width_6,
                          height: widget.iconSize ?? AppSizes.width_6,
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                      childWhenDragging: Container(
                        width: AppSizes.width_8,
                        height: AppSizes.width_8,
                        decoration: const BoxDecoration(
                          color: AppColor.colorTransparent,
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                      ),
                      child: Container(
                        width: AppSizes.width_8,
                        height: AppSizes.width_8,
                        decoration: BoxDecoration(
                          color: Get.theme.colorScheme.primary,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(50),
                          ),
                        ),
                        child: SvgPicture.asset(
                          widget.icon,
                          width: widget.iconSize ?? AppSizes.width_6,
                          height: widget.iconSize ?? AppSizes.width_6,
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Spacer(),

            Expanded(
              child: CommonText(
                text: widget.text,
                maxLines: 1,
                textColor: widget.backgroundColor != null
                    ? widget.textColor ?? Get.theme.colorScheme.primary
                    : Get.theme.colorScheme.inverseSurface,
                textAlign: TextAlign.end,
                fontSize: widget.fontSize ?? AppFontSize.size_14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
