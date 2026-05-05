import 'package:get/get.dart';
import 'package:zero_share/ui/received_app_gallery/files_gallery_logic.dart';
import 'package:zero_share/ui/home/home_logic.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FilesLogic());
    Get.lazyPut(() => HomeLogic());
  }
}
