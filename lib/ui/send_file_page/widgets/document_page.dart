// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:zero_share/ui/send_file_page/send_file_logic.dart';

// import '../tabs/tab_documents.dart';

// class DocumentTypePage extends StatelessWidget {
//   final DocumentType documentType;

//   const DocumentTypePage({Key? key, required this.documentType})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final logic = Get.find<SendFileLogic>();
//     // Filter files based on the selected document type
//     logic.filterDocuments(documentType);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(documentType.toString().split('.').last.toUpperCase()),
//       ),
//       body: GetBuilder<SendFileLogic>(
//         builder: (logic) {
//           return ListView.builder(
//             itemCount: logic.filteredFiles.length,
//             itemBuilder: (context, index) {
//               final file = logic.filteredFiles[index];
//               return DocumentListItem(
//                 isSelected: logic.selectedDocumentFiles.contains(file),
//                 file: file,
//                 onTap: () {
//                   // Handle file selection logic here
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
