import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:zero_share/generated/assets.dart';
import 'package:zero_share/utils/color.dart';
import 'package:zero_share/Widgets/common_text.dart';
import 'package:zero_share/utils/sizer_utils.dart';
import 'package:flutter/services.dart';
import 'package:zero_share/ui/send_file_page/send_file_logic.dart';

class FolderWidget extends StatelessWidget {
  final List<AssetEntity> items;
  final String folderName;
  final bool isExpanded;
  final VoidCallback onExpand;
  final bool isImageTab;

  const FolderWidget({
    super.key,
    required this.items,
    required this.folderName,
    required this.isExpanded,
    required this.onExpand,
    this.isImageTab = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPaddings.padding_32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColor.colorGreyDark.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              splashColor: AppColor.colorGreyLight.withValues(alpha: 0.5),
              onTap: onExpand,
              title: CommonText(
                maxLines: 1,
                text: '$folderName (${items.length})',
                textColor: Get.theme.colorScheme.secondary,
                fontWeight: FontWeight.w400,
                fontSize: AppFontSize.size_14,
              ),
              trailing: SvgPicture.asset(
                isExpanded
                    ? Assets.iconsIcCheckboxActive
                    : Assets.iconsIcCheckboxInactive,
              ),
            ),
          ),
          if (isExpanded)
            GridView.builder(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemBuilder: (context, index) {
                // Lazy loading trigger
                if (index == items.length - 1) {
                  final logic = Get.find<SendFileLogic>();
                  logic.fetchMoreAssets(folderName, isImageTab);
                }

                return FileGridItem(
                  file: items[index],
                  key: ValueKey(items[index].id),
                );
              },
            ),
        ],
      ),
    );
  }
}

class FileGridItem extends StatefulWidget {
  final AssetEntity file;

  const FileGridItem({super.key, required this.file});

  @override
  State<FileGridItem> createState() => _FileGridItemState();
}

class _FileGridItemState extends State<FileGridItem> {
  Uint8List? _thumbnailData;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {
    if (!mounted) return;

    try {
      final data = await widget.file.thumbnailDataWithSize(
        const ThumbnailSize(200, 200),
      );

      if (mounted) {
        setState(() {
          _thumbnailData = data;
          _isLoading = false;
          _hasError = data == null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  final logic = Get.find<SendFileLogic>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Thumbnail with shimmer effect
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildThumbnail(context),
        ),
        // Checkbox with Obx for real-time updates
        Positioned(
          top: 4,
          right: 4,
          child: Obx(() {
            final isSelected = logic.selectedFiles.contains(widget.file);
            return GestureDetector(
              onTap: () => logic.toggleFileSelection(widget.file),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? AppColor.primary : Colors.grey,
                  size: 24,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildThumbnail(BuildContext context) {
    if (_isLoading) {
      return _buildShimmerEffect();
    }

    if (_hasError || _thumbnailData == null) {
      return Container(
        width: MediaQuery.of(context).size.width / 4,
        height: MediaQuery.of(context).size.width / 4,
        color: Colors.grey[300],
        child: const Icon(Icons.image, color: Colors.grey, size: 40),
      );
    }

    return Image.memory(
      _thumbnailData!,
      width: MediaQuery.of(context).size.width / 4,
      height: MediaQuery.of(context).size.width / 4,
      fit: BoxFit.contain,
      gaplessPlayback: true,
      cacheWidth: 200,
      cacheHeight: 200,
    );
  }

  Widget _buildShimmerEffect() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Container(
          width: MediaQuery.of(context).size.width / 4,
          height: MediaQuery.of(context).size.width / 4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!.withValues(alpha: value),
                Colors.grey[300]!,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted && _isLoading) {
          setState(() {}); // Restart animation
        }
      },
    );
  }
}
