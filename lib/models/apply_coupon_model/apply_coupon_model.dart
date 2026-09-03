import '../coupons_model/coupons_model.dart';

class ApplyCouponModel {
  int? status;
  String? message;
  double? discountAmount;
  String? discountType;
  Coupons? coupon;

  ApplyCouponModel({
    this.status,
    this.message,
    this.discountAmount,
    this.discountType,
    this.coupon,
  });

  ApplyCouponModel.fromJson(Map<String, dynamic> json) {
    status = json['status'] is int
        ? json['status']
        : int.tryParse('${json['status']}');
    message = json['message']?.toString();
    final rawDiscount = json['discountAmount'] ?? json['discount_amount'];
    if (rawDiscount is num) {
      discountAmount = rawDiscount.toDouble();
    } else {
      discountAmount = double.tryParse('$rawDiscount');
    }
    discountType = json['discount_type']?.toString();
    if (json['coupon'] != null) {
      coupon = Coupons.fromJson(Map<String, dynamic>.from(json['coupon']));
    }
  }
}
