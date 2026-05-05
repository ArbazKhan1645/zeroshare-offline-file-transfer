import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zero_share/ui/full_page_img/full_page_img_logic.dart';

class FullPageImgView extends StatelessWidget {
  const FullPageImgView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FullPageImgLogic());

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Image.file(controller.imageFile, fit: BoxFit.contain),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () {
                Get.back();
              },
            ),
          ),
        ],
      ),
    );
  }
}
