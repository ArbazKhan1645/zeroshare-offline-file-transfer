import 'dart:io';
import 'package:get/get.dart';

class FullPageImgLogic extends GetxController {
  late File imageFile;

  @override
  void onInit() {
    super.onInit();
    imageFile = Get.arguments as File;
  }
}
