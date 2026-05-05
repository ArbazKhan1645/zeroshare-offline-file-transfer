import 'package:flutter/material.dart';
import 'package:zero_share/utils/color.dart';
import 'package:zero_share/utils/constant.dart';
import 'package:zero_share/utils/sizer_utils.dart';

class CommonText extends StatelessWidget {
  final String text;
  final Color textColor;
  final double? fontSize;
  final String fontFamily;
  final FontWeight fontWeight;
  final FontStyle fontStyle;
  final TextAlign textAlign;
  final TextDecoration textDecoration;
  final Color decorationColor;
  final int? maxLines;

  const CommonText({
    super.key,
    required this.text,
    this.fontSize,
    this.maxLines,
    this.textColor = AppColor.colorBlack,
    this.fontFamily = Constant.fontFamilyPoppins,
    this.fontWeight = FontWeight.w500,
    this.fontStyle = FontStyle.normal,
    this.textAlign = TextAlign.start,
    this.textDecoration = TextDecoration.none,
    this.decorationColor = AppColor.colorBlack,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
      style: TextStyle(
        fontSize: fontSize ?? AppFontSize.size_14,
        color: textColor,
        fontFamily: fontFamily,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        decoration: textDecoration,
        decorationColor: decorationColor,
      ),
    );
  }
}
