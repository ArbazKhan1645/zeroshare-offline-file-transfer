import 'package:get/get.dart';

import 'package:zero_share/ui/welcome_page/welcome_logic.dart';

class WelcomeScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WelcomeScreenLogic());
  }
}
