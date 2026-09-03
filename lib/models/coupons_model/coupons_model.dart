import '../../utils/json_cast.dart';

class CouponsModel {
  int? status;
  String? message;
  List<Coupons>? coupons;

  CouponsModel({this.status, this.message, this.coupons});

  CouponsModel.fromJson(Map<String, dynamic> json) {
    status = JsonCast.asInt(json['status']);
    message = json['message']?.toString();
    if (json['coupons'] != null) {
      coupons = <Coupons>[];
      json['coupons'].forEach((v) {
        coupons!.add(Coupons.fromJson(Map<String, dynamic>.from(v)));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (coupons != null) {
      data['coupons'] = coupons!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Coupons {
  int? id;
  String? name;
  String? code;
  String? discountType;
  String? amount;
  String? minimumCartAmount;
  String? startDate;
  String? expiryDate;
  String? description;
  bool neverExpires;
  bool availableNow;

  Coupons({
    this.id,
    this.name,
    this.code,
    this.discountType,
    this.amount,
    this.minimumCartAmount,
    this.startDate,
    this.expiryDate,
    this.description,
    this.neverExpires = false,
    this.availableNow = true,
  });

  Coupons.fromJson(Map<String, dynamic> json)
      : neverExpires = json['never_expires'] == true,
        availableNow = json['available_now'] != false {
    id = JsonCast.asInt(json['id']);
    name = json['name']?.toString();
    code = json['code']?.toString();
    discountType = json['discount_type']?.toString();
    amount = json['amount']?.toString();
    minimumCartAmount = json['minimum_cart_amount']?.toString();
    startDate = json['start_date']?.toString();
    expiryDate = json['expiry_date']?.toString();
    description = json['description']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['code'] = code;
    data['discount_type'] = discountType;
    data['amount'] = amount;
    data['minimum_cart_amount'] = minimumCartAmount;
    data['start_date'] = startDate;
    data['expiry_date'] = expiryDate;
    data['description'] = description;
    data['never_expires'] = neverExpires;
    data['available_now'] = availableNow;
    return data;
  }
}
