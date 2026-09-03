import '../../utils/json_cast.dart';

class OrderHistoryModel {
  String? success;
  int? status;
  List<Orders>? orders;

  OrderHistoryModel({this.success, this.status, this.orders});

  OrderHistoryModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    status = JsonCast.asInt(json['status']);
    if (json['orders'] != null) {
      orders = <Orders>[];
      json['orders'].forEach((v) {
        orders!.add(Orders.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['status'] = status;
    if (orders != null) {
      data['orders'] = orders!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Orders {
  int? id;
  String? orderNumber;
  String? date;
  String? customer;
  String? totalAmount;
  int? totalPoints;

  Orders(
      {this.id,
        this.orderNumber,
        this.date,
        this.customer,
        this.totalAmount,
        this.totalPoints});

  Orders.fromJson(Map<String, dynamic> json) {
    id = JsonCast.asInt(json['id']);
    orderNumber = json['order_number']?.toString();
    date = json['date']?.toString();
    customer = json['customer']?.toString();
    totalAmount = json['total_amount']?.toString();
    totalPoints = JsonCast.asInt(json['total_points']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_number'] = orderNumber;
    data['date'] = date;
    data['customer'] = customer;
    data['total_amount'] = totalAmount;
    data['total_points'] = totalPoints;
    return data;
  }
}
