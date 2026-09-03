import '../../utils/json_cast.dart';

class VapeSavingModel {
  int? id;
  String? firstDate;
  String? todayDate;
  String? packPrice;
  int? cigsPerPack;
  int? cigsPerDay;
  String? vapeUnitPrice;
  int? bottlesCount;
  int? freeBottles;
  int? daysPerBottle;
  String? fidelityPercent;
  int? totalDays;
  String? cigUnitPrice;
  String? totalCigCost;
  String? vapeCostBeforeFidelity;
  String? fidelityDiscountValue;
  String? totalVapeCostAfterFidelity;
  String? freeBottleValue;
  String? effectiveTotalVapeValueIncludingFree;
  String? finalEffectiveUnitPrice;
  String? eurosSavedVsCig;
  String? eurosSavedVsCigIncludingFreeValue;
  String? savingPerDay;
  String? savingPerMonth;
  String? savingPerYear;
  String? createdAt;

  VapeSavingModel({
    this.id,
    this.firstDate,
    this.todayDate,
    this.packPrice,
    this.cigsPerPack,
    this.cigsPerDay,
    this.vapeUnitPrice,
    this.bottlesCount,
    this.freeBottles,
    this.daysPerBottle,
    this.fidelityPercent,
    this.totalDays,
    this.cigUnitPrice,
    this.totalCigCost,
    this.vapeCostBeforeFidelity,
    this.fidelityDiscountValue,
    this.totalVapeCostAfterFidelity,
    this.freeBottleValue,
    this.effectiveTotalVapeValueIncludingFree,
    this.finalEffectiveUnitPrice,
    this.eurosSavedVsCig,
    this.eurosSavedVsCigIncludingFreeValue,
    this.savingPerDay,
    this.savingPerMonth,
    this.savingPerYear,
    this.createdAt,
  });

  VapeSavingModel.fromJson(Map<String, dynamic> json)
      : id = JsonCast.asInt(json['id']),
        firstDate = json['first_date'],
        todayDate = json['today_date'],
        packPrice = json['pack_price']?.toString(),
        cigsPerPack = JsonCast.asInt(json['cigs_per_pack']),
        cigsPerDay = JsonCast.asInt(json['cigs_per_day']),
        vapeUnitPrice = json['vape_unit_price']?.toString(),
        bottlesCount = JsonCast.asInt(json['bottles_count']),
        freeBottles = JsonCast.asInt(json['free_bottles']),
        daysPerBottle = JsonCast.asInt(json['days_per_bottle']),
        fidelityPercent = json['fidelity_percent']?.toString(),
        totalDays = JsonCast.asInt(json['total_days']),
        cigUnitPrice = json['cig_unit_price']?.toString(),
        totalCigCost = json['total_cig_cost']?.toString(),
        vapeCostBeforeFidelity = json['vape_cost_before_fidelity']?.toString(),
        fidelityDiscountValue = json['fidelity_discount_value']?.toString(),
        totalVapeCostAfterFidelity =
            json['total_vape_cost_after_fidelity']?.toString(),
        freeBottleValue = json['free_bottle_value']?.toString(),
        effectiveTotalVapeValueIncludingFree =
            json['effective_total_vape_value_including_free']?.toString(),
        finalEffectiveUnitPrice = json['final_effective_unit_price']?.toString(),
        eurosSavedVsCig = json['euros_saved_vs_cig']?.toString(),
        eurosSavedVsCigIncludingFreeValue =
            json['euros_saved_vs_cig_including_free_value']?.toString(),
        savingPerDay = json['saving_per_day']?.toString(),
        savingPerMonth = json['saving_per_month']?.toString(),
        savingPerYear = json['saving_per_year']?.toString(),
        createdAt = json['created_at'];
}

class VapeSavingListModel {
  int? status;
  String? message;
  List<VapeSavingModel> items;

  VapeSavingListModel({this.status, this.message, this.items = const []});

  VapeSavingListModel.fromJson(Map<String, dynamic> json)
      : status = JsonCast.asInt(json['status']),
        message = json['message'],
        items = json['items'] != null
            ? (json['items'] as List)
                .map((e) => VapeSavingModel.fromJson(e))
                .toList()
            : [];
}

class SlipItem {
  int? id;
  String? occurredAt;
  String? slipDate;
  String? slipTime;
  int? cigarettesCount;
  String? totalAmount;

  SlipItem({
    this.id,
    this.occurredAt,
    this.slipDate,
    this.slipTime,
    this.cigarettesCount,
    this.totalAmount,
  });

  SlipItem.fromJson(Map<String, dynamic> json)
      : id = JsonCast.asInt(json['id']),
        occurredAt = json['occurred_at'],
        slipDate = json['slip_date'],
        slipTime = json['slip_time'],
        cigarettesCount = JsonCast.asInt(json['cigarettes_count']),
        totalAmount = json['total_amount']?.toString();
}

class SlipHistoryModel {
  int? status;
  String? message;
  WasteStats? wasteStats;
  List<SlipItem> items;

  SlipHistoryModel({
    this.status,
    this.message,
    this.wasteStats,
    this.items = const [],
  });

  SlipHistoryModel.fromJson(Map<String, dynamic> json)
      : status = JsonCast.asInt(json['status']),
        message = json['message'],
        wasteStats = json['waste_stats'] != null
            ? WasteStats.fromJson(json['waste_stats'])
            : null,
        items = json['items'] != null
            ? (json['items'] as List).map((e) => SlipItem.fromJson(e)).toList()
            : [];
}

class WasteStats {
  double day;
  double month;
  double year;
  int dayCount;
  int monthCount;
  int yearCount;

  WasteStats({
    this.day = 0,
    this.month = 0,
    this.year = 0,
    this.dayCount = 0,
    this.monthCount = 0,
    this.yearCount = 0,
  });

  WasteStats.fromJson(Map<String, dynamic> json)
      : day = _num(json['day']),
        month = _num(json['month']),
        year = _num(json['year']),
        dayCount = JsonCast.intOr(json['day_count']),
        monthCount = JsonCast.intOr(json['month_count']),
        yearCount = JsonCast.intOr(json['year_count']);

  static double _num(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}
