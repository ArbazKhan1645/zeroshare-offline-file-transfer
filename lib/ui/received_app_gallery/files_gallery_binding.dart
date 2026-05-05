import 'package:get/get.dart';
import 'package:zero_share/ui/received_app_gallery/files_gallery_logic.dart';

class FilesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FilesLogic());
  }
}
