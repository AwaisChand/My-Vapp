import 'package:flutter/material.dart';
import 'package:lim_crm/models/ad_model/ad_model.dart';
import 'package:lim_crm/models/dashboard_model/dashboard_model.dart';
import 'package:lim_crm/models/get_news_letter_model/get_news_letter_model.dart';
import 'package:lim_crm/models/redeem_points_history_model/redeem_points_history_model.dart';
import 'package:provider/provider.dart';

import '../../repository/home_repository/home_repository.dart';
import '../../res/app_localization.dart';
import '../../utils/dashboard_chart_utils.dart';
import '../../utils/locale_format_utils.dart';
import '../../utils/utils.dart';
import '../auth_view_model/auth_view_model.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeRepository homeRepository = HomeRepository();

  DashboardModel? _dashboard;
  DashboardModel? get dashboard => _dashboard;

  List<AdItem> _ads = [];
  List<AdItem> get ads => _ads;

  List<History> _history = [];
  List<History> get history => _history;

  RedeemPointsHistoryModel? _redeemPointsHistoryModel;
  RedeemPointsHistoryModel? get redeemPointsHistoryModel =>
      _redeemPointsHistoryModel;

  List<Data> _newsData = [];
  List<Data> get newsLetter => _newsData;

  bool _redeemLoading = false;
  bool get redeemLoading => _redeemLoading;

  bool _historyLoadFailed = false;
  bool get historyLoadFailed => _historyLoadFailed;

  int _ordersChartYear = DateTime.now().year;
  int _ordersChartMonth = 0;
  int _passportChartYear = DateTime.now().year;
  int _passportChartMonth = 0;
  List<String> _chartMonthLabels = DashboardChartUtils.monthLabelsEn;

  int get ordersChartYear => _ordersChartYear;
  int get ordersChartMonth => _ordersChartMonth;
  int get passportChartYear => _passportChartYear;
  int get passportChartMonth => _passportChartMonth;

  FilteredChartData get filteredOrdersChart {
    final dashboard = _dashboard;
    if (dashboard == null) {
      return const FilteredChartData();
    }
    return DashboardChartUtils.buildOrdersChart(
      rows: dashboard.ordersRaw,
      year: _ordersChartYear,
      month: _ordersChartMonth,
      monthLabels: _chartMonthLabels,
    );
  }

  FilteredChartData get filteredPassportChart {
    final dashboard = _dashboard;
    if (dashboard == null) {
      return const FilteredChartData();
    }
    return DashboardChartUtils.buildPassportChart(
      entries: dashboard.passportEntries,
      raw: dashboard.passportRaw,
      year: _passportChartYear,
      month: _passportChartMonth,
      monthLabels: _chartMonthLabels,
    );
  }

  List<int> get orderYears =>
      DashboardChartUtils.yearsWithFallback(_dashboard?.availableOrderYears ?? []);

  List<int> get passportYears => DashboardChartUtils.yearsWithFallback(
        _dashboard?.availablePassportYears ?? [],
      );

  set redeemPointsLoading(bool setLoading) {
    _redeemLoading = setLoading;
    notifyListeners();
  }

  void setOrdersChartYear(int year) {
    _ordersChartYear = year;
    notifyListeners();
  }

  void setOrdersChartMonth(int month) {
    _ordersChartMonth = month;
    notifyListeners();
  }

  void setPassportChartYear(int year) {
    _passportChartYear = year;
    notifyListeners();
  }

  void setPassportChartMonth(int month) {
    _passportChartMonth = month;
    notifyListeners();
  }

  void _syncChartFiltersFromDashboard() {
    if (_dashboard == null) return;
    final availableOrderYears = orderYears;
    final availablePassportYears = passportYears;
    if (!availableOrderYears.contains(_ordersChartYear)) {
      _ordersChartYear = availableOrderYears.first;
    }
    if (!availablePassportYears.contains(_passportChartYear)) {
      _passportChartYear = availablePassportYears.first;
    }
  }

  Future<void> loadDashboard({bool silent = false}) async {
    if (!silent) redeemPointsLoading = true;
    try {
      final response = await homeRepository.dashboardRepo();
      if (response.status == 1) {
        _dashboard = response;
        _syncChartFiltersFromDashboard();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Dashboard error: $e');
    } finally {
      if (!silent) redeemPointsLoading = false;
    }
  }

  Future<void> loadAds() async {
    try {
      final response = await homeRepository.adsRepo();
      if (response.status == 1) {
        _ads = response.data;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Ads error: $e');
    }
  }

  Future<void> loadHomeData(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    if (l10n != null) {
      _chartMonthLabels = LocaleFormatUtils.monthAbbreviations(l10n);
    }
    redeemPointsLoading = true;
    try {
      await Future.wait([
        loadDashboard(silent: true),
        getRedeemPointsHistoryHome(context),
        getNewsLetterApi(context, silent: true),
        loadAds(),
      ]);
      if (_dashboard?.user != null && context.mounted) {
        final auth = context.read<AuthViewModel>();
        auth.mergeDashboardUser({
          'id': _dashboard!.user!.id,
          'name': _dashboard!.user!.name,
          'first_name': _dashboard!.user!.firstName,
          'last_name': _dashboard!.user!.lastName,
          'email': _dashboard!.user!.email,
          'avatar': _dashboard!.user!.avatar,
          'avatar_url': _dashboard!.user!.avatarUrl,
        });
      }
    } finally {
      redeemPointsLoading = false;
    }
  }

  Future<void> getRedeemPointsHistory(BuildContext context) async {
    redeemPointsLoading = true;
    _historyLoadFailed = false;
    try {
      final response = await homeRepository.redeemPointsHistoryRepo();
      if (response.status == 1) {
        _redeemPointsHistoryModel = response;
        _history = response.history ?? [];
        notifyListeners();
      } else {
        _historyLoadFailed = true;
        Utils.toastMessage(
          response.message ??
              (AppLocalizations.of(context)?.translate('unableToLoadTransactionHistory') ??
                  'Unable to load transaction history.'),
        );
      }
    } catch (e) {
      debugPrint('Cashback history error: $e');
      _historyLoadFailed = true;
      Utils.toastMessage(
        AppLocalizations.of(context)?.translate('unableToLoadTransactionHistory') ??
            'Unable to load transaction history.',
      );
    } finally {
      redeemPointsLoading = false;
    }
  }

  Future<void> getRedeemPointsHistoryHome(BuildContext context) async {
    try {
      final response = await homeRepository.redeemPointsHistoryRepo();
      if (response.status == 1) {
        _historyLoadFailed = false;
        _redeemPointsHistoryModel = response;
        _history = response.history ?? [];
        notifyListeners();
      } else {
        _historyLoadFailed = true;
      }
    } catch (e) {
      debugPrint('Dashboard data error: $e');
      _historyLoadFailed = true;
    }
  }

  Future<void> redeemNowApi(BuildContext context, dynamic data) async {
    redeemPointsLoading = true;
    try {
      final response = await homeRepository.redeemNow(data);
      Utils.toastMessage(response['message'] ?? '');
      if (response['status'].toString() == '1') {
        await getRedeemPointsHistoryHome(context);
        await loadDashboard(silent: true);
        if (context.mounted) Navigator.of(context).pop();
      } else if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Redeem Now API error: $e');
      Utils.toastMessage('Error: ${e.toString()}');
    } finally {
      redeemPointsLoading = false;
    }
  }

  Future<void> getNewsLetterApi(BuildContext context, {bool silent = false}) async {
    if (!silent) redeemPointsLoading = true;
    try {
      final response = await homeRepository.getNewsLetterRepo();
      if (response.status == 1) {
        _newsData = response.data ?? [];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('NewsLetter data error: $e');
    } finally {
      if (!silent) redeemPointsLoading = false;
    }
  }

  Future<void> syncLanguage(String locale) async {
    try {
      await homeRepository.updateLanguage(locale);
    } catch (e) {
      debugPrint('Language sync error: $e');
    }
  }
}
