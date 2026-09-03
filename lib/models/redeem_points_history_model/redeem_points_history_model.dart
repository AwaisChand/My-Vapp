import '../../utils/json_cast.dart';

class RedeemPointsHistoryModel {
  double totalEarnedPoints;
  double totalRedeemedPoints;
  double currentBalance;
  int? status;
  String? message;
  List<History>? history;

  RedeemPointsHistoryModel({
    this.totalEarnedPoints = 0,
    this.totalRedeemedPoints = 0,
    this.currentBalance = 0,
    this.status,
    this.message,
    this.history,
  });

  RedeemPointsHistoryModel.fromJson(Map<String, dynamic> json)
      : totalEarnedPoints = _num(json['total_earned_points'] ?? json['total_earned_cashback']),
        totalRedeemedPoints = _num(json['total_redeemed_points'] ?? json['total_redeemed_cashback']),
        currentBalance = _num(json['current_balance']),
        message = json['message'],
        status = JsonCast.asInt(json['status']),
        history = json['history'] != null
            ? (json['history'] as List).map((v) => History.fromJson(v)).toList()
            : null;

  static double _num(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_earned_points'] = totalEarnedPoints;
    data['total_redeemed_points'] = totalRedeemedPoints;
    data['current_balance'] = currentBalance;
    data['status'] = status;
    data['message'] = message;
    if (history != null) {
      data['history'] = history!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class History {
  String? type;
  String? points;
  String? cashback;
  String? notes;
  String? date;
  String? rawDate;
  String? displayDate;
  String? status;
  int? redemptionId;
  int? orderId;
  List<Products>? products;

  History({
    this.type,
    this.points,
    this.cashback,
    this.notes,
    this.date,
    this.rawDate,
    this.displayDate,
    this.status,
    this.redemptionId,
    this.orderId,
    this.products,
  });

  History.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    points = json['points']?.toString();
    cashback = json['cashback']?.toString();
    notes = _formatTransactionNotes(json['notes']);
    date = json['date']?.toString();
    rawDate = json['raw_date'];
    displayDate = json['display_date'];
    status = json['status'];

    redemptionId = json['redemption_id'] != null
        ? int.tryParse(json['redemption_id'].toString())
        : null;

    orderId = json['order_id'] != null
        ? int.tryParse(json['order_id'].toString())
        : null;

    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));
      });
    }
  }


  static String? _formatTransactionNotes(dynamic value) {
    if (value == null) return null;
    return value
        .toString()
        .replaceAll(RegExp(r'(Order|Commande)\s*#\s*', caseSensitive: false), r'$1 ');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['points'] = points;
    data['notes'] = notes;
    data['date'] = date;
    data['raw_date'] = rawDate;
    data['display_date'] = displayDate;
    data['redemption_id'] = redemptionId;
    data['order_id'] = orderId;
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Products {
  String? name;
  int? qty;
  int? points;

  Products({this.name, this.qty, this.points});

  Products.fromJson(Map<String, dynamic> json) {
    name = json['name']?.toString();
    qty = JsonCast.asInt(json['qty']);
    points = JsonCast.asInt(json['points']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['qty'] = qty;
    data['points'] = points;
    return data;
  }
}
