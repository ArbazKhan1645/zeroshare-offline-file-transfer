import 'package:get/get.dart';
import 'package:zero_share/routes/app_routes.dart';

class WelcomeScreenLogic extends GetxController {
  void navigateToPlans() {
    Get.toNamed(AppRoutes.plans);
  }
}
