import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:zero_share/Widgets/common_text.dart';
import 'package:zero_share/utils/color.dart';
import 'package:zero_share/ui/received_app_gallery/files_gallery_logic.dart';

class GalleryAudios extends StatelessWidget {
  GalleryAudios({super.key});

  final FilesLogic controller = Get.find<FilesLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        title: const Text('Audios'),
      ),
      body: GetBuilder<FilesLogic>(
        builder: (logic) {
          final audios = logic.videos;
          return audios.isEmpty
              ? const Center(
                  child: CommonText(
                    text: 'No Audio History Available',
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: audios.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.audiotrack, color: Colors.blue),
                      title: Text(audios[index].path.split('/').last),
                    );
                  },
                );
        },
      ),
    );
  }
}
