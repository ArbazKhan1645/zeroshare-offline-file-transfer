import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zero_share/Widgets/common_text.dart';
import 'package:zero_share/utils/color.dart';
import 'package:zero_share/ui/received_app_gallery/files_gallery_logic.dart';

class GalleryVideos extends StatelessWidget {
  GalleryVideos({super.key});

  final FilesLogic controller = Get.find<FilesLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        title: const Text('Videos'),
      ),
      body: GetBuilder<FilesLogic>(
        builder: (logic) {
          final videos = logic.audios;
          return videos.isEmpty
              ? const Center(
                  child: CommonText(
                    text: 'No Video History Available',
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.video_file, color: Colors.blue),
                      title: Text(videos[index].path.split('/').last),
                    );
                  },
                );
        },
      ),
    );
  }
}
