import 'package:get/get.dart';
import 'package:zero_share/ui/profile_page/profile_page_logic.dart';

class ProfilePageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfilePageLogic());
  }
}
