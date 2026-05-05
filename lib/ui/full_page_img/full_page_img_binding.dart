import 'package:get/get.dart';

import 'package:zero_share/ui/privacy_policy/privacy_policy_logic.dart';

class FullPageImgBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PrivacyPolicyLogic());
  }
}
