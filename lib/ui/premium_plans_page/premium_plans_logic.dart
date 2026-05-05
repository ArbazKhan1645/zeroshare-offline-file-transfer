import 'package:get/get.dart';

import 'package:zero_share/models/plans_model.dart';

class PremiumPlansLogic extends GetxController {
  List<PlansModel> myPlans = [];
  int savePercentage = 5;

  @override
  void onInit() {
    myPlans = demoPlans;
    super.onInit();
  }
}
