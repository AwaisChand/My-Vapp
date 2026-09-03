import '../../utils/json_cast.dart';

class OffersModel {
  int? status;
  String? message;
  List<Offers>? offers;

  OffersModel({this.status, this.message, this.offers});

  OffersModel.fromJson(Map<String, dynamic> json) {
    status = JsonCast.asInt(json['status']);
    message = json['message']?.toString();
    if (json['offers'] != null) {
      offers = <Offers>[];
      json['offers'].forEach((v) {
        offers!.add(Offers.fromJson(Map<String, dynamic>.from(v)));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (offers != null) {
      data['offers'] = offers!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Offers {
  dynamic id;
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

  Offers({
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

  Offers.fromJson(Map<String, dynamic> json)
      : neverExpires = json['never_expires'] == true,
        availableNow = json['available_now'] != false {
    id = json['id'];
    name = json['name']?.toString();
    code = json['code']?.toString();
    discountType = json['discount_type']?.toString();
    amount = json['amount']?.toString();
    minimumCartAmount = json['minimum_cart_amount']?.toString();
    startDate = json['start_date']?.toString();
    expiryDate = json['expiry_date']?.toString();
    description = json['description'] ?? json['message']?.toString();
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
