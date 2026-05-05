import 'package:get/get.dart';
import 'package:zero_share/ui/premium_plans_page/premium_plans_logic.dart';

class PremiumPlansBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PremiumPlansLogic());
  }
}
