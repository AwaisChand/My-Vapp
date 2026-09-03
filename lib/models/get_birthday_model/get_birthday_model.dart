import '../../utils/json_cast.dart';

class GetBirthdayModel {
  int? status;
  String? message;
  bool? inBirthdayWeek;
  List<Birthdays>? birthdays;

  GetBirthdayModel({
    this.status,
    this.message,
    this.inBirthdayWeek,
    this.birthdays,
  });

  GetBirthdayModel.fromJson(Map<String, dynamic> json) {
    status = JsonCast.asInt(json['status']);
    message = json['message']?.toString();
    inBirthdayWeek = json['in_birthday_week'] == true;
    if (json['birthdays'] != null) {
      birthdays = <Birthdays>[];
      json['birthdays'].forEach((v) {
        birthdays!.add(Birthdays.fromJson(Map<String, dynamic>.from(v)));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['in_birthday_week'] = inBirthdayWeek;
    if (birthdays != null) {
      data['birthdays'] = birthdays!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Birthdays {
  int? id;
  String? name;
  String? code;
  String? discountType;
  String? amount;
  String? minimumCartAmount;
  String? startDate;
  String? expiryDate;
  String? description;
  bool availableNow;

  Birthdays({
    this.id,
    this.name,
    this.code,
    this.discountType,
    this.amount,
    this.minimumCartAmount,
    this.startDate,
    this.expiryDate,
    this.description,
    this.availableNow = true,
  });

  Birthdays.fromJson(Map<String, dynamic> json)
      : availableNow = json['available_now'] != false {
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
    data['available_now'] = availableNow;
    return data;
  }
}
