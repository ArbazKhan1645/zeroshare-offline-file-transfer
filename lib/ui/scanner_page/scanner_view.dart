import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zero_share/ui/connect_page/connect_page_logic.dart';
import 'package:zero_share/ui/scanner_page/scanner_logic.dart';
import 'package:zero_share/Widgets/common_appbar.dart';

class ScannerView extends StatelessWidget {
  ScannerView({super.key});

  final ScannerLogic controller = Get.find<ScannerLogic>();
  final ConnectPageLogic controllerConnectPage = Get.find<ConnectPageLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.onSurface,
      appBar: const CommonAppBar(),
      body: GetBuilder<ScannerLogic>(
        builder: (controller) {
          return const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                // Add scanner button here
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                ),
              ),
              // Expanded(
              //   flex: 1,
              //   child: Container(
              //     width: double.infinity,
              //     decoration: BoxDecoration(
              //       color: AppColor.colorWhite,
              //       boxShadow: [
              //         BoxShadow(
              //           color: Color(0x11000000),
              //           blurRadius: 16,
              //           offset: Offset(0, 4),
              //           spreadRadius: 0,
              //         ),
              //       ],
              //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              //     ),
              //     child: Column(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Icon(Icons.check_circle, color: AppColor.primary, size: 50),
              //         SizedBox(height: 10),
              //         CommonText(
              //           textAlign: TextAlign.start,
              //           text: 'txtFindTheDevice'.tr,
              //           textColor: Get.theme.colorScheme.primary,
              //           fontWeight: FontWeight.w400,
              //           fontSize: AppFontSize.size_8,
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          );
        },
      ),
    );
  }
}
