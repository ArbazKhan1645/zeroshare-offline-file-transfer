import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zero_share/ui/send_file_page/send_file_logic.dart';
import 'dart:io';
import 'package:zero_share/utils/color.dart';
import 'package:zero_share/Widgets/common_text.dart';
import 'package:zero_share/utils/sizer_utils.dart';

class TabDocuments extends StatelessWidget {
  const TabDocuments({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<SendFileLogic>();

    return Column(
      children: [
        // Filter chips
        Obx(
          () => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildFilterChip(
                  'All',
                  DocumentType.all,
                  logic.selectedType.value == DocumentType.all,
                  () => logic.filterDocuments(DocumentType.all),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'PDF',
                  DocumentType.pdf,
                  logic.selectedType.value == DocumentType.pdf,
                  () => logic.filterDocuments(DocumentType.pdf),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Excel',
                  DocumentType.excel,
                  logic.selectedType.value == DocumentType.excel,
                  () => logic.filterDocuments(DocumentType.excel),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'PPT',
                  DocumentType.ppt,
                  logic.selectedType.value == DocumentType.ppt,
                  () => logic.filterDocuments(DocumentType.ppt),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Word',
                  DocumentType.doc,
                  logic.selectedType.value == DocumentType.doc,
                  () => logic.filterDocuments(DocumentType.doc),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Text',
                  DocumentType.txt,
                  logic.selectedType.value == DocumentType.txt,
                  () => logic.filterDocuments(DocumentType.txt),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Other',
                  DocumentType.other,
                  logic.selectedType.value == DocumentType.other,
                  () => logic.filterDocuments(DocumentType.other),
                ),
              ],
            ),
          ),
        ),

        // Selected count indicator
        Obx(() {
          if (logic.selectedDocumentFiles.isEmpty) {
            return const SizedBox.shrink();
          }

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColor.primary.withValues(alpha: 0.1),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColor.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                CommonText(
                  text:
                      '${logic.selectedDocumentFiles.length} file(s) selected',
                  textColor: AppColor.primary,
                  fontSize: AppFontSize.size_14,
                  fontWeight: FontWeight.w600,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => logic.clearSelections(),
                  child: CommonText(
                    text: 'Clear',
                    textColor: AppColor.primary,
                    fontSize: AppFontSize.size_14,
                  ),
                ),
              ],
            ),
          );
        }),

        // Document list
        Expanded(
          child: Obx(() {
            if (!logic.hasStoragePermission.value) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    CommonText(
                      text: 'Storage Permission Required',
                      fontSize: AppFontSize.size_16,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: CommonText(
                        text:
                            'Please grant storage permission to access and share documents',
                        textColor: AppColor.colorTextGreyLight,
                        fontSize: AppFontSize.size_14,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => logic.baseDirectory(),
                      icon: const Icon(Icons.lock_open),
                      label: const Text('Grant Permission'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            if (logic.isLoadingDocuments.value) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    CommonText(
                      text: 'Scanning device for files...',
                      textColor: AppColor.colorTextGreyLight,
                      fontSize: AppFontSize.size_14,
                    ),
                  ],
                ),
              );
            }

            if (logic.filteredFiles.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.folder_open,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    CommonText(
                      text: _getEmptyMessage(logic.selectedType.value),
                      textColor: AppColor.colorTextGreyLight,
                      fontSize: AppFontSize.size_14,
                    ),
                    // const SizedBox(height: 8),
                    // TextButton.icon(
                    //   onPressed: () => logic.refreshDocuments(),
                    //   icon: const Icon(Icons.refresh),
                    //   label: const Text('Refresh'),
                    // ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppPaddings.padding_16,
              ),
              itemCount: logic.filteredFiles.length,
              itemBuilder: (context, index) {
                final file = logic.filteredFiles[index];

                return Obx(() {
                  final isSelected = logic.selectedDocumentFiles.contains(file);

                  return ListTile(
                    onTap: () => logic.toggleDocumentFileSelection(file),
                    leading: Icon(
                      _getFileIcon(file),
                      size: 40,
                      color: _getFileColor(file),
                    ),
                    title: CommonText(
                      text: file.path.split('/').last,
                      fontSize: AppFontSize.size_14,
                      maxLines: 1,
                    ),
                    subtitle: CommonText(
                      text: logic.getFileSize(file),
                      textColor: AppColor.colorTextGreyLight,
                      fontSize: AppFontSize.size_12,
                    ),
                    trailing: Checkbox(
                      value: isSelected,
                      onChanged: (_) => logic.toggleDocumentFileSelection(file),
                      activeColor: AppColor.primary,
                    ),
                  );
                });
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    String label,
    DocumentType type,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColor.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  String _getEmptyMessage(DocumentType type) {
    switch (type) {
      case DocumentType.pdf:
        return 'No PDF files found';
      case DocumentType.excel:
        return 'No Excel files found';
      case DocumentType.ppt:
        return 'No PowerPoint files found';
      case DocumentType.doc:
        return 'No Word documents found';
      case DocumentType.txt:
        return 'No text files found';
      case DocumentType.other:
        return 'No other files found';
      default:
        return 'No documents found';
    }
  }

  IconData _getFileIcon(File file) {
    final ext = file.path.toLowerCase();

    // PDF
    if (ext.endsWith('.pdf')) return Icons.picture_as_pdf;

    // Excel
    if (ext.endsWith('.xlsx') ||
        ext.endsWith('.xls') ||
        ext.endsWith('.xlsm') ||
        ext.endsWith('.csv')) {
      return Icons.table_chart;
    }

    // PowerPoint
    if (ext.endsWith('.ppt') ||
        ext.endsWith('.pptx') ||
        ext.endsWith('.pptm') ||
        ext.endsWith('.ppsx')) {
      return Icons.slideshow;
    }

    // Word
    if (ext.endsWith('.doc') ||
        ext.endsWith('.docx') ||
        ext.endsWith('.docm')) {
      return Icons.article;
    }

    // Text
    if (ext.endsWith('.txt') || ext.endsWith('.rtf') || ext.endsWith('.log')) {
      return Icons.description;
    }

    // Archives
    if (ext.endsWith('.zip') || ext.endsWith('.rar') || ext.endsWith('.7z')) {
      return Icons.folder_zip;
    }

    // Code files
    if (ext.endsWith('.json') ||
        ext.endsWith('.xml') ||
        ext.endsWith('.html') ||
        ext.endsWith('.css') ||
        ext.endsWith('.js') ||
        ext.endsWith('.java') ||
        ext.endsWith('.py') ||
        ext.endsWith('.cpp')) {
      return Icons.code;
    }

    return Icons.insert_drive_file;
  }

  Color _getFileColor(File file) {
    final ext = file.path.toLowerCase();

    // PDF - Red
    if (ext.endsWith('.pdf')) return Colors.red;

    // Excel - Green
    if (ext.endsWith('.xlsx') ||
        ext.endsWith('.xls') ||
        ext.endsWith('.xlsm') ||
        ext.endsWith('.csv')) {
      return Colors.green;
    }

    // PowerPoint - Orange
    if (ext.endsWith('.ppt') ||
        ext.endsWith('.pptx') ||
        ext.endsWith('.pptm') ||
        ext.endsWith('.ppsx')) {
      return Colors.orange;
    }

    // Word - Blue
    if (ext.endsWith('.doc') ||
        ext.endsWith('.docx') ||
        ext.endsWith('.docm')) {
      return Colors.blue;
    }

    // Text - Indigo
    if (ext.endsWith('.txt') || ext.endsWith('.rtf') || ext.endsWith('.log')) {
      return Colors.indigo;
    }

    // Archives - Brown
    if (ext.endsWith('.zip') || ext.endsWith('.rar') || ext.endsWith('.7z')) {
      return Colors.brown;
    }

    // Code - Purple
    if (ext.endsWith('.json') ||
        ext.endsWith('.xml') ||
        ext.endsWith('.html') ||
        ext.endsWith('.css') ||
        ext.endsWith('.js') ||
        ext.endsWith('.java') ||
        ext.endsWith('.py') ||
        ext.endsWith('.cpp')) {
      return Colors.purple;
    }

    return Colors.grey;
  }
}
