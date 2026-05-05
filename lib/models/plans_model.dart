class PlansModel {
  int? id;
  String? duration;
  double? price;
  double? discountedPrice;
  bool? isSaving;

  PlansModel({
    this.id,
    this.duration,
    this.price,
    this.discountedPrice,
    this.isSaving,
  });
}

List<PlansModel> demoPlans = [];
