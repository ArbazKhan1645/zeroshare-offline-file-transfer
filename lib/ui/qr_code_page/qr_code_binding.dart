import 'package:get/get.dart';
import 'package:zero_share/ui/qr_code_page/qr_code_logic.dart';

class QrCodeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => QrCodeLogic());
  }
}
