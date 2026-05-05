import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:zero_share/ui/send_file_page/send_file_logic.dart';
import 'package:zero_share/utils/color.dart';
import 'package:zero_share/Widgets/common_text.dart';
import 'package:zero_share/utils/sizer_utils.dart';

class MusicListWidget extends StatelessWidget {
  final List<AssetEntity> items;
  final Map<String, List<AssetEntity>> musicData;

  const MusicListWidget({
    super.key,
    required this.items,
    required this.musicData,
  });

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<SendFileLogic>();

    return ListView.builder(
      shrinkWrap: true,
      itemCount: musicData.keys.length,
      itemBuilder: (context, index) {
        final String alphabet = musicData.keys.elementAt(index);
        final List<AssetEntity> songs = musicData[alphabet]!;

        // âœ… UI Level Filtering - Remove duplicates by ID
        final Set<String> seenIds = {};
        final List<AssetEntity> uniqueSongs = songs.where((song) {
          if (seenIds.contains(song.id)) {
            return false; // Skip duplicate
          }
          seenIds.add(song.id);
          return true; // Keep unique
        }).toList();

        // âœ… If no unique songs after filtering, skip this section
        if (uniqueSongs.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(8.0),
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CommonText(
                    text: alphabet,
                    fontSize: AppFontSize.size_14,
                  ),
                  CommonText(
                    text: ' (${uniqueSongs.length})', // âœ… Show unique count
                    textColor: AppColor.colorTextGreyLight,
                    fontSize: AppFontSize.size_14,
                  ),
                ],
              ),
              ...uniqueSongs.map((song) {
                return Obx(() {
                  final isSelected = logic.selectedFiles.contains(song);

                  return ListTile(
                    onTap: () {
                      logic.toggleFileSelection(song);
                    },
                    leading: Container(
                      width: 40,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColor.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.music_note,
                        color: AppColor.primary,
                      ),
                    ),
                    title: CommonText(
                      text: song.title ?? 'Unknown',
                      fontSize: AppFontSize.size_14,
                      maxLines: 1,
                    ),
                    subtitle: FutureBuilder<String>(
                      future: getSongSize(song),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text('Calculating...');
                        }
                        if (!snapshot.hasData) {
                          return const Text('Unknown size');
                        }
                        return CommonText(
                          text: snapshot.data ?? 'Unknown',
                          fontSize: AppFontSize.size_14,
                          maxLines: 1,
                        );
                      },
                    ),
                    trailing: Checkbox(
                      value: isSelected,
                      activeColor: AppColor.primary,
                      onChanged: (val) {
                        logic.toggleFileSelection(song);
                      },
                    ),
                  );
                });
              }),
            ],
          ),
        );
      },
    );
  }

  Future<String> getSongSize(AssetEntity song) async {
    final file = await song.file;
    if (file == null) return 'Unknown size';

    final bytes = await file.length();

    return _formatFileSize(bytes);
  }

  // âœ… Helper method to format file size properly
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
