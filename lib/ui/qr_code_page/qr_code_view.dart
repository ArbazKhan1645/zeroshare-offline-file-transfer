// lib/ui/qr_code_page/qr_code_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:zero_share/ui/qr_code_page/qr_code_logic.dart';
import 'package:zero_share/utils/color.dart';
import 'package:zero_share/utils/sizer_utils.dart';
import 'package:zero_share/Widgets/common_appbar.dart';
import 'package:zero_share/Widgets/common_text.dart';

class QrCodeView extends StatelessWidget {
  QrCodeView({super.key});

  final controller = Get.put(QrCodeLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.onSurface,
      appBar: CommonAppBar(
        onBackTap: () {
          controller.stopServer();
        },
      ),
      body: GetBuilder<QrCodeLogic>(
        builder: (controller) {
          if (!controller.isServerRunning.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CommonText(
                  textAlign: TextAlign.center,
                  text: 'Scan The QR Code To Connect!',
                  textColor: Get.theme.colorScheme.secondary,
                  fontWeight: FontWeight.w800,
                  fontSize: AppFontSize.size_16,
                ),
                SizedBox(height: AppSizes.height_4),
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 60),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 30,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.3),
                            blurRadius: 10,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: AppSizes.height_2),
                          QrImageView(
                            data: controller.qrData,
                            size: 200.0,
                            backgroundColor: Colors.white,
                          ),
                          SizedBox(height: AppSizes.height_2),
                          CommonText(
                            text: 'Server: ${controller.serverIP}',
                            textAlign: TextAlign.center,
                            textColor: AppColor.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: AppFontSize.size_12,
                          ),
                          CommonText(
                            text: 'Code: ${controller.secretCode}',
                            textAlign: TextAlign.center,
                            textColor: AppColor.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: AppFontSize.size_12,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSizes.height_4),
              ],
            ),
          );
        },
      ),
    );
  }
}
