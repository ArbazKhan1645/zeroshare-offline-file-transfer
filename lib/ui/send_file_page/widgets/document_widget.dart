// ignore_for_file: avoid_dynamic_calls

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zero_share/generated/assets.dart';

import 'package:zero_share/Widgets/common_text.dart';
import 'package:zero_share/utils/color.dart';
import 'package:zero_share/utils/sizer_utils.dart';
import 'package:zero_share/ui/send_file_page/send_file_logic.dart';

class AllDocumentWidget extends StatelessWidget {
  final Function(DocumentType) onFilterSelected;

  const AllDocumentWidget({super.key, required this.onFilterSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppPaddings.padding_32,
        right: AppPaddings.padding_32,
        top: AppPaddings.padding_32,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border:
              Border.all(color: AppColor.colorGreyDark.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: AppSizes.height_2),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppPaddings.padding_20,
              ),
              child: CommonText(
                text: 'Documents',
                fontSize: AppFontSize.size_14,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSizes.height_3),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppPaddings.padding_32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      widgetDocType(
                        docTypeTitle: 'ALL',
                        bgColor: AppColor.colorDimYellow,
                        iconPath: Assets.iconsIcAll,
                        onTap: () {
                          onFilterSelected(DocumentType.all);
                          // Get.toNamed(AppRoutes.home);
                        },
                      ),
                      widgetDocType(
                        docTypeTitle: 'PDF',
                        bgColor: AppColor.colorDimRed,
                        iconPath: Assets.iconsIcPdf,
                        onTap: () {
                          //  Get.to(() => DocumentTypePage(documentType: DocumentType.pdf));
                          onFilterSelected(DocumentType.pdf);
                        },
                      ),
                      widgetDocType(
                        docTypeTitle: 'EXCEL',
                        bgColor: AppColor.colorDimGreen,
                        iconPath: Assets.iconsIcExcel,
                        onTap: () {
                          // Get.to(() => DocumentTypePage(documentType: DocumentType.excel));
                          onFilterSelected(DocumentType.excel);
                        },
                      ),
                      widgetDocType(
                        docTypeTitle: 'PPT',
                        bgColor: AppColor.colorDimOrange,
                        iconPath: Assets.iconsIcPpt,
                        onTap: () {
                          //   Get.to(() => DocumentTypePage(documentType: DocumentType.ppt));
                          onFilterSelected(DocumentType.ppt);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.height_3),
                  widgetDocType(
                    docTypeTitle: 'TXT',
                    bgColor: AppColor.colorDimPurple,
                    iconPath: Assets.iconsIcTxt,
                    onTap: () {
                      // Get.to(() => DocumentTypePage(documentType: DocumentType.txt));
                      onFilterSelected(DocumentType.txt);
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSizes.height_2),
          ],
        ),
      ),
    );
  }

  Widget widgetDocType({
    required String docTypeTitle,
    required Color bgColor,
    required String iconPath,
    required Function onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: AppColor.colorGreyLight.withValues(alpha: 0.5),
        onTap: () {
          onTap();
        },
        child: Column(
          children: [
            Container(
              width: AppSizes.width_12,
              height: AppSizes.height_6,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SvgPicture.asset(iconPath, fit: BoxFit.scaleDown),
            ),
            SizedBox(height: AppSizes.height_0_2),
            CommonText(
              text: docTypeTitle,
              fontSize: AppFontSize.size_11,
              fontWeight: FontWeight.w400,
            ),
          ],
        ),
      ),
    );
  }
}
