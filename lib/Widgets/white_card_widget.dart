import 'package:flutter/material.dart';

import 'package:zero_share/utils/color.dart';
import 'package:zero_share/utils/sizer_utils.dart';

class WhiteCardWidget extends StatelessWidget {
  final Function() onTap;
  final List<Widget> children;

  const WhiteCardWidget({
    required this.onTap,
    required this.children,
    super.key,
  });

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
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }
}
