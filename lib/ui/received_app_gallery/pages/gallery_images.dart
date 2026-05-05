import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:zero_share/Widgets/common_text.dart';
import 'package:zero_share/utils/color.dart';
import 'package:zero_share/ui/full_page_img/full_page_img_view.dart';
import 'package:zero_share/ui/received_app_gallery/files_gallery_logic.dart';

class GalleryImages extends StatelessWidget {
  GalleryImages({super.key});

  final FilesLogic controller = Get.find<FilesLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        title: const Text('Images'),
      ),
      body: GetBuilder<FilesLogic>(
        builder: (logic) {
          final images = logic.images;
          return images.isEmpty
              ? const Center(
                  child: CommonText(
                    text: 'No Image History Available',
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Get.to(
                          () => const FullPageImgView(),
                          arguments: images[index],
                        );
                      },
                      child: Image.file(
                        images[index],
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}
