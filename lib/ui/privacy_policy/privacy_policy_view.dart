import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:zero_share/utils/color.dart';
import 'package:zero_share/utils/sizer_utils.dart';
import 'package:zero_share/generated/assets.dart';
import 'package:zero_share/utils/constant.dart';
import 'package:zero_share/ui/privacy_policy/privacy_policy_logic.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GetBuilder<PrivacyPolicyLogic>(
          builder: (controller) {
            return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: AppColor.colorTransparent,
                title: const Text(
                  'ZeroShare Privacy Policy',
                  style: TextStyle(
                    color: AppColor.colorBlack,
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                    fontFamily: Constant.fontFamilyPoppins,
                  ),
                ),
                leading: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: AppColor.colorGreyLight,
                    child: SvgPicture.asset(
                      Assets.iconsIcArrowBack,
                      fit: BoxFit.scaleDown,
                    ),
                    onTap: () {
                      Get.back();
                    },
                  ),
                ),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppSizes.height_4),
                    MarkdownBody(
                      data:
                          'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.',
                      styleSheet: MarkdownStyleSheet.fromTheme(
                        Theme.of(context).copyWith(
                          textTheme: Theme.of(
                            context,
                          ).textTheme.apply(bodyColor: AppColor.colorBlack),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSizes.height_2),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
