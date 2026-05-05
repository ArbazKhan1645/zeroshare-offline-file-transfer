import 'package:get/get.dart';
import 'package:zero_share/ui/received_app_gallery/files_gallery_logic.dart';
import 'package:zero_share/ui/profile_page/profile_page_logic.dart';
import 'package:zero_share/ui/dashboard/dashboard_logic.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut(() => HomeLogic());
    Get.lazyPut(() => FilesLogic());

    // Get.lazyPut(
    //   () => SendFileLogic(),
    // );
    Get.lazyPut(() => ProfilePageLogic());
    Get.lazyPut(() => DashboardLogic());
  }
}
