import 'package:get/get.dart';

import 'package:zero_share/ui/splash_page/splash_logic.dart';

class SplashScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SplashScreenLogic());
  }
}
