import 'package:flutter/material.dart';

import 'package:zero_share/utils/color.dart';
import 'package:zero_share/utils/sizer_utils.dart';

class CommonBottomWidget extends StatelessWidget {
  final List<Widget> children;

  const CommonBottomWidget({required this.children, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPaddings.padding_20,
        vertical: AppPaddings.padding_08,
      ),
      decoration: const BoxDecoration(
        color: AppColor.colorWhite,
        boxShadow: [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18.0),
          topRight: Radius.circular(18.0),
        ),
      ),
      child: Column(
        //mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
