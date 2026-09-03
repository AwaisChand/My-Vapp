import '../../utils/json_cast.dart';

class DashboardModel {
  int? status;
  String? message;
  DashboardUser? user;
  DashboardSnapshot? snapshot;
  LatestVapeSaving? latestVapeSaving;
  List<TierInfo> tierConfig;
  TierProgress? tierProgress;
  ChartSeries? nicotineMonthlyChart;
  ChartSeries? monthlyOrdersChart;
  List<DashboardPromotion> dashboardPromotions;
  List<OrderRawRow> ordersRaw;
  List<PassportRawRow> passportRaw;
  List<PassportEntryRow> passportEntries;
  List<int> availableOrderYears;
  List<int> availablePassportYears;
  String? savingsUpdatedAt;

  DashboardModel({
    this.status,
    this.message,
    this.user,
    this.snapshot,
    this.latestVapeSaving,
    this.tierConfig = const [],
    this.tierProgress,
    this.nicotineMonthlyChart,
    this.monthlyOrdersChart,
    this.dashboardPromotions = const [],
    this.ordersRaw = const [],
    this.passportRaw = const [],
    this.passportEntries = const [],
    this.availableOrderYears = const [],
    this.availablePassportYears = const [],
    this.savingsUpdatedAt,
  });

  List<DashboardPromotion> get featuredOffers => dashboardPromotions;

  DashboardModel.fromJson(Map<String, dynamic> json)
      : status = JsonCast.asInt(json['status']),
        message = json['message'],
        user = json['user'] != null ? DashboardUser.fromJson(json['user']) : null,
        snapshot = json['snapshot'] != null
            ? DashboardSnapshot.fromJson(json['snapshot'])
            : null,
        latestVapeSaving = json['latest_vape_saving'] != null
            ? LatestVapeSaving.fromJson(json['latest_vape_saving'])
            : null,
        tierConfig = json['tier_config'] != null
            ? (json['tier_config'] as List)
                .map((e) => TierInfo.fromJson(Map<String, dynamic>.from(e)))
                .toList()
            : [],
        tierProgress = json['tier_progress'] != null
            ? TierProgress.fromJson(json['tier_progress'])
            : null,
        nicotineMonthlyChart = json['nicotine_monthly_chart'] != null
            ? ChartSeries.fromJson(
                json['nicotine_monthly_chart'],
                valueKey: 'nicotine_mg',
              )
            : null,
        monthlyOrdersChart = json['monthly_orders_chart'] != null
            ? ChartSeries.fromJson(
                json['monthly_orders_chart'],
                valueKey: 'spend_euros',
              )
            : null,
        dashboardPromotions = _parsePromotions(json),
        ordersRaw = json['orders_raw'] != null
            ? (json['orders_raw'] as List)
                .map((e) => OrderRawRow.fromJson(Map<String, dynamic>.from(e)))
                .toList()
            : [],
        passportRaw = json['passport_raw'] != null
            ? (json['passport_raw'] as List)
                .map((e) => PassportRawRow.fromJson(Map<String, dynamic>.from(e)))
                .toList()
            : [],
        passportEntries = json['passport_entries'] != null
            ? (json['passport_entries'] as List)
                .map((e) => PassportEntryRow.fromJson(Map<String, dynamic>.from(e)))
                .toList()
            : [],
        availableOrderYears = JsonCast.asIntList(json['available_order_years']),
        availablePassportYears = JsonCast.asIntList(json['available_passport_years']),
        savingsUpdatedAt = json['savings_updated_at'];

  static List<DashboardPromotion> _parsePromotions(Map<String, dynamic> json) {
    final source = json['dashboard_promotions'] ?? json['featured_offers'];
    if (source == null) return [];
    return (source as List)
        .map((e) => DashboardPromotion.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

class DashboardUser {
  int? id;
  String? name;
  String? firstName;
  String? lastName;
  String? email;
  String? avatar;
  String? avatarUrl;

  DashboardUser({
    this.id,
    this.name,
    this.firstName,
    this.lastName,
    this.email,
    this.avatar,
    this.avatarUrl,
  });

  DashboardUser.fromJson(Map<String, dynamic> json)
      : id = JsonCast.asInt(json['id']),
        name = json['name'],
        firstName = json['first_name'],
        lastName = json['last_name'],
        email = json['email'],
        avatar = json['avatar'],
        avatarUrl = json['avatar_url'];
}

class DashboardSnapshot {
  double totalEarnedCashback;
  double totalRedeemedCashback;
  double currentBalance;
  int activeOffersCount;
  int activeCouponsCount;
  int birthdayCount;
  bool profileComplete;
  int profileCompletionPercent;
  List<String> missingProfileFields;
  double savingPerDay;
  double savingPerMonth;
  double savingPerYear;

  DashboardSnapshot({
    this.totalEarnedCashback = 0,
    this.totalRedeemedCashback = 0,
    this.currentBalance = 0,
    this.activeOffersCount = 0,
    this.activeCouponsCount = 0,
    this.birthdayCount = 0,
    this.profileComplete = false,
    this.profileCompletionPercent = 0,
    this.missingProfileFields = const [],
    this.savingPerDay = 0,
    this.savingPerMonth = 0,
    this.savingPerYear = 0,
  });

  DashboardSnapshot.fromJson(Map<String, dynamic> json)
      : totalEarnedCashback = _toDouble(json['total_earned_cashback']),
        totalRedeemedCashback = _toDouble(json['total_redeemed_cashback']),
        currentBalance = _toDouble(json['current_balance']),
        activeOffersCount = JsonCast.intOr(json['active_offers_count']),
        activeCouponsCount = JsonCast.intOr(json['active_coupons_count']),
        birthdayCount = JsonCast.intOr(json['birthday_count']),
        profileComplete = json['profile_complete'] == true,
        profileCompletionPercent = JsonCast.intOr(json['profile_completion_percent']),
        missingProfileFields = json['missing_profile_fields'] != null
            ? List<String>.from(json['missing_profile_fields'])
            : [],
        savingPerDay = _toDouble(json['saving_per_day']),
        savingPerMonth = _toDouble(json['saving_per_month']),
        savingPerYear = _toDouble(json['saving_per_year']);

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}

class LatestVapeSaving {
  int? id;
  String? firstDate;
  String? todayDate;
  double cigUnitPrice;
  double savingPerDay;
  double savingPerMonth;
  double savingPerYear;

  LatestVapeSaving({
    this.id,
    this.firstDate,
    this.todayDate,
    this.cigUnitPrice = 0,
    this.savingPerDay = 0,
    this.savingPerMonth = 0,
    this.savingPerYear = 0,
  });

  LatestVapeSaving.fromJson(Map<String, dynamic> json)
      : id = JsonCast.asInt(json['id']),
        firstDate = json['first_date'],
        todayDate = json['today_date'],
        cigUnitPrice = DashboardSnapshot._toDouble(json['cig_unit_price']),
        savingPerDay = DashboardSnapshot._toDouble(json['saving_per_day']),
        savingPerMonth = DashboardSnapshot._toDouble(json['saving_per_month']),
        savingPerYear = DashboardSnapshot._toDouble(json['saving_per_year']);
}

class TierInfo {
  String? name;
  double min;
  double? max;
  String? benefits;

  TierInfo({this.name, this.min = 0, this.max, this.benefits});

  TierInfo.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        min = DashboardSnapshot._toDouble(json['min']),
        max = json['max'] != null ? DashboardSnapshot._toDouble(json['max']) : null,
        benefits = json['benefits'];
}

class TierProgress {
  TierInfo? currentTier;
  TierInfo? nextTier;
  double progressPercent;
  double amountToNext;
  bool isTopTier;

  TierProgress({
    this.currentTier,
    this.nextTier,
    this.progressPercent = 0,
    this.amountToNext = 0,
    this.isTopTier = false,
  });

  TierProgress.fromJson(Map<String, dynamic> json)
      : currentTier = json['current_tier'] != null
            ? TierInfo.fromJson(Map<String, dynamic>.from(json['current_tier']))
            : null,
        nextTier = json['next_tier'] != null
            ? TierInfo.fromJson(Map<String, dynamic>.from(json['next_tier']))
            : null,
        progressPercent = DashboardSnapshot._toDouble(json['progress_percent']),
        amountToNext = DashboardSnapshot._toDouble(json['amount_to_next']),
        isTopTier = json['is_top_tier'] == true;
}

class ChartSeries {
  List<String> categories;
  List<double> values;
  int? year;

  ChartSeries({
    this.categories = const [],
    this.values = const [],
    this.year,
  });

  ChartSeries.fromJson(Map<String, dynamic> json, {required String valueKey})
      : categories = json['categories'] != null
            ? List<String>.from(json['categories'])
            : [],
        values = json[valueKey] != null
            ? (json[valueKey] as List)
                .map((e) => DashboardSnapshot._toDouble(e))
                .toList()
            : [],
        year = JsonCast.asInt(json['year']);
}

class FilteredChartData {
  final List<String> categories;
  final List<double> values;

  const FilteredChartData({
    this.categories = const [],
    this.values = const [],
  });
}

class OrderRawRow {
  String? date;
  double totalAmount;

  OrderRawRow({this.date, this.totalAmount = 0});

  OrderRawRow.fromJson(Map<String, dynamic> json)
      : date = json['date'],
        totalAmount = DashboardSnapshot._toDouble(json['total_amount']);
}

class PassportRawRow {
  String? date;
  double mg;

  PassportRawRow({this.date, this.mg = 0});

  PassportRawRow.fromJson(Map<String, dynamic> json)
      : date = json['date'],
        mg = DashboardSnapshot._toDouble(json['mg']);
}

class PassportEntryRow {
  String? date;
  String? time;
  double mg;

  PassportEntryRow({this.date, this.time, this.mg = 0});

  PassportEntryRow.fromJson(Map<String, dynamic> json)
      : date = json['date'],
        time = json['time'],
        mg = DashboardSnapshot._toDouble(json['mg']);
}

class DashboardPromotion {
  dynamic id;
  String? name;
  String? code;
  String? type;
  String? description;
  String? expiryDate;
  String? startDate;
  String? discountType;
  String? amount;
  String? minimumCartAmount;
  bool neverExpires;
  bool availableNow;

  DashboardPromotion({
    this.id,
    this.name,
    this.code,
    this.type,
    this.description,
    this.expiryDate,
    this.startDate,
    this.discountType,
    this.amount,
    this.minimumCartAmount,
    this.neverExpires = false,
    this.availableNow = true,
  });

  DashboardPromotion.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        code = json['code'],
        type = json['type'],
        description = json['description'],
        expiryDate = json['expiry_date']?.toString(),
        startDate = json['start_date']?.toString(),
        discountType = json['discount_type'],
        amount = json['amount']?.toString(),
        minimumCartAmount = json['minimum_cart_amount']?.toString(),
        neverExpires = json['never_expires'] == true,
        availableNow = json['available_now'] != false;

  bool get isBirthday => type == 'birthday';
  bool get isCoupon => type == 'coupon';
}

// Keep alias for backwards compatibility in UI code.
typedef FeaturedOffer = DashboardPromotion;
