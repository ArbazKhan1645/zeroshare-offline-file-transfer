import 'package:get/get.dart';
import 'package:zero_share/ui/connect_page/connect_page_logic.dart';

class SendFileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ConnectPageLogic());
  }
}
