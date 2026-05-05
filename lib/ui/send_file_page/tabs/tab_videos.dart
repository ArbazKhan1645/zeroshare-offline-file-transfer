import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:zero_share/ui/send_file_page/send_file_logic.dart';
import 'package:zero_share/ui/send_file_page/widgets/folder_widget.dart';

class TabVideos extends StatelessWidget {
  const TabVideos({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<SendFileLogic>();

    return Obx(() {
      // Check if folderVideos is empty
      if (logic.folderVideos.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.only(top: 16.0),
        itemCount: logic.folderVideos.length,
        itemBuilder: (context, index) {
          final String folderName = logic.folderVideos.keys.elementAt(index);
          final List<AssetEntity> items = logic.folderVideos[folderName]!;

          return Obx(
            () => FolderWidget(
              isImageTab: false,
              folderName: folderName,
              items: items,
              isExpanded: logic.selectedFolderIndex.value == index,
              onExpand: () => logic.onFolderTap(index),
            ),
          );
        },
      );
    });
  }
}
