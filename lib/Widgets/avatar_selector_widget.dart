import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zero_share/generated/assets.dart';
import 'package:zero_share/utils/color.dart';
import 'package:zero_share/utils/sizer_utils.dart';

import 'package:zero_share/Widgets/common_text.dart';

class AvatarSelectionDialog extends StatelessWidget {
  const AvatarSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> avatars = [
      Assets.imagesImgAvatarFemaleBlue,
      Assets.imagesImgAvatarFemaleGreen,
      Assets.imagesImgAvatarFemaleLightPurple,
      Assets.imagesImgAvatarFemalePurple,
      Assets.imagesImgAvatarFemaleRed,
      Assets.imagesImgAvatarFemaleYellow,
      Assets.imagesImgAvatarMale,
      Assets.imagesImgAvatarMaleGreen,
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: AppSizes.height_2),
        CommonText(
          text: 'Select Your Avatar'.tr,
          textColor: Get.theme.colorScheme.secondary,
          fontWeight: FontWeight.w600,
          fontSize: AppFontSize.size_14,
        ),
        SizedBox(height: AppSizes.height_2),
        Expanded(
          child: Center(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: avatars.length,
              itemBuilder: (context, index) {
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: AppColor.colorGreyLight.withValues(alpha: 0.9),
                    onTap: () {
                      Navigator.pop(context, avatars[index]);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: CircleAvatar(
                        radius: 20, // Increased radius for a larger avatar
                        backgroundColor: AppColor.primary,
                        child: ClipOval(
                          child: Image.asset(
                            avatars[index],
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
