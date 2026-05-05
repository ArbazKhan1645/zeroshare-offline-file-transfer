import 'package:get/get.dart';
import 'package:zero_share/ui/scanner_page/scanner_logic.dart';

class ScannerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ScannerLogic());
  }
}
