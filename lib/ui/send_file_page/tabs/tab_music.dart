import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:zero_share/ui/send_file_page/send_file_logic.dart';
import 'package:zero_share/ui/send_file_page/widgets/music_list_widget.dart';

class TabMusic extends StatelessWidget {
  const TabMusic({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SendFileLogic>(
      init: Get.find<SendFileLogic>(), // Ensure controller is initialized
      builder: (controller) {
        // Check if musicFiles is empty
        if (controller.musicFiles.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Convert the musicFiles Map to a list of AssetEntity
        final List<AssetEntity> allMusicFiles =
            controller.musicFiles.values.expand((list) => list).toList();

        debugPrint('should ${allMusicFiles.length}');

        return MusicListWidget(
          items: allMusicFiles,
          musicData: controller.musicFiles,
        );
      },
    );
  }
}
