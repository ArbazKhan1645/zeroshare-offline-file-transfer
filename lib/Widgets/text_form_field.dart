import 'package:flutter/material.dart';
import 'package:zero_share/utils/constant.dart';
import 'package:zero_share/utils/sizer_utils.dart';

import 'package:zero_share/utils/color.dart';

class CommonTextFormField extends StatelessWidget {
  final String hintText;
  final String validatorText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool autofocus;
  final bool enabled;
  final Color fillColor;
  final Function(String)? onTextChanged;
  final double radius;
  final int maxLines;
  final FocusNode? focusNode;
  final String? Function(String? value)? validator;

  const CommonTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.fillColor,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.autofocus = false,
    this.enabled = true,
    this.onTextChanged,
    this.radius = 16,
    this.maxLines = 1,
    this.validatorText = '',
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      cursorColor: AppColor.colorBlack,
      style: TextStyle(
        fontSize: AppFontSize.size_12,
        fontWeight: FontWeight.w400,
        color: AppColor.colorBlack,
        fontFamily: Constant.fontFamilyNunitoSans,
      ),
      maxLines: maxLines,
      onChanged: onTextChanged,
      enabled: enabled,
      validator: validator ??
          (String? value) {
            if (value == null || value.isEmpty) {
              return validatorText;
            }
            return null;
          },
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColor.colorTransparent,
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: AppFontSize.size_15,
          fontWeight: FontWeight.w400,
          color: AppColor.colorGreyDark,
          fontFamily: Constant.fontFamilyNunitoSans,
        ),
        errorStyle: TextStyle(
          fontSize: AppFontSize.size_14,
          fontWeight: FontWeight.w400,
          color: AppColor.colorRed,
          fontFamily: Constant.fontFamilyNunitoSans,
        ),
        // contentPadding: EdgeInsetsDirectional.fromSTEB(
        //   0,
        //   (maxLines > 1) ? AppSizes.height_1 : 0,
        //   AppSizes.width_15,
        //   (maxLines > 1) ? AppSizes.height_1 : 0,
        // ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColor.colorGreyLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColor.colorGreyDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColor.colorGreyDark),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColor.colorGreyDark),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColor.colorGreyDark),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColor.colorRed),
        ),
      ),
    );
  }
}
