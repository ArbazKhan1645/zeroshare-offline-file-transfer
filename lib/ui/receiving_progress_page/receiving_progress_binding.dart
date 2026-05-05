import 'package:get/get.dart';

import 'package:zero_share/ui/connect_page/connect_page_logic.dart';
import 'package:zero_share/ui/receiving_progress_page/receiving_progress_logic.dart';

class ReceivingProgressBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ConnectPageLogic());
    Get.lazyPut(() => ReceivingProgressLogic());
  }
}
