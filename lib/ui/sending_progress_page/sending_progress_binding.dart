import 'package:get/get.dart';

import 'package:zero_share/ui/connect_page/connect_page_logic.dart';
import 'package:zero_share/ui/sending_progress_page/sending_progress_logic.dart';

class SendingProgressBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ConnectPageLogic());
    Get.lazyPut(() => SendingProgressLogic());
  }
}
