import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:zero_share/ui/send_file_page/send_file_logic.dart';
import 'package:zero_share/ui/send_file_page/widgets/folder_widget.dart';

class TabPhoto extends StatelessWidget {
  const TabPhoto({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<SendFileLogic>();

    return Obx(() {
      // Check if folderPhotos is empty
      if (logic.folderPhotos.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.only(top: 16.0),
        itemCount: logic.folderPhotos.length,
        itemBuilder: (context, index) {
          final String folderName = logic.folderPhotos.keys.elementAt(index);
          final List<AssetEntity> items = logic.folderPhotos[folderName]!;

          return Obx(
            () => FolderWidget(
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
