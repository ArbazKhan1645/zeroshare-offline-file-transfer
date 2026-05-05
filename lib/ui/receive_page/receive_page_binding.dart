import 'package:get/get.dart';
import 'package:zero_share/ui/connect_page/connect_page_logic.dart';
import 'package:zero_share/ui/receive_page/receive_page_logic.dart';

class ReceivePageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ConnectPageLogic());
    Get.lazyPut(() => ReceivePageLogic());
  }
}
