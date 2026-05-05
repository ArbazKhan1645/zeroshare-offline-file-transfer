import 'package:flutter/material.dart';

import 'package:zero_share/utils/color.dart';
import 'package:zero_share/utils/sizer_utils.dart';

class CommonGradientBGWidget extends StatelessWidget {
  final List<Widget> children;

  const CommonGradientBGWidget({required this.children, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPaddings.padding_36,
        vertical: AppPaddings.padding_08,
      ),
      decoration: const BoxDecoration(
        color: AppColor.primary,
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryLight,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        gradient: LinearGradient(
          colors: [
            AppColor.colorWhite,
            AppColor.primaryLight,
          ],
          begin: Alignment.center,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40.0),
          bottomRight: Radius.circular(40.0),
        ),
      ),
      child: InkWell(
        child: Column(
          //  mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }
}
