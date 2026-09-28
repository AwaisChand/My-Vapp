import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lim_crm/models/check_birthday_model/check_birthday_model.dart';
import 'package:lim_crm/models/coupons_model/coupons_model.dart';
import 'package:lim_crm/models/get_birthday_model/get_birthday_model.dart';
import 'package:lim_crm/models/offers_model/offers_model.dart';
import 'package:lim_crm/repository/promotions_repository/promotions_repository.dart';
import 'package:lim_crm/res/app_localization.dart';

import '../../data/network/network_api_service.dart';
import '../../utils/utils.dart';

class PromotionsViewModel extends ChangeNotifier {
  final PromotionsRepository authRepository = PromotionsRepository();

  List<Coupons> _coupons = [];
  List<Coupons> get coupons => _coupons;

  List<Offers> _offers = [];
  List<Offers> get offers => _offers;

  List<Birthdays> _birthday = [];
  List<Birthdays> get birthday => _birthday;

  CheckBirthdayModel? _checkBirthdayModel;
  CheckBirthdayModel? get checkBirthdayModel => _checkBirthdayModel;

  bool _promotionsLoading = false;
  bool get promotionsLoading => _promotionsLoading;

  bool _applyingCoupon = false;
  bool get applyingCoupon => _applyingCoupon;

  set promotions(bool setLoading) {
    _promotionsLoading = setLoading;
    notifyListeners();
  }

  Future<void> loadAllPromotions(BuildContext context) async {
    promotions = true;
    try {
      await Future.wait([
        _fetchCoupons(silent: true),
        _fetchOffers(silent: true),
      ]);
    } finally {
      promotions = false;
    }
  }

  Future<void> getCoupons(BuildContext context) async {
    promotions = true;
    try {
      await _fetchCoupons();
    } catch (e) {
      debugPrint('Get Coupons data error: $e');
      _showError(context, e);
    } finally {
      promotions = false;
    }
  }

  Future<void> getOffers(BuildContext context) async {
    promotions = true;
    try {
      await _fetchOffers();
    } catch (e) {
      debugPrint('Get Offers data error: $e');
      _showError(context, e);
    } finally {
      promotions = false;
    }
  }

  Future<void> getBirthday(BuildContext context) async {
    promotions = true;
    try {
      await _fetchBirthday();
    } catch (e) {
      debugPrint('Get Birthday data error: $e');
      _showError(context, e);
    } finally {
      promotions = false;
    }
  }

  Future<void> getBirthdayHome(BuildContext context) async {
    promotions = true;
    try {
      await _fetchBirthday(silent: true);
    } catch (e) {
      debugPrint('Get Birthday data error: $e');
    } finally {
      promotions = false;
    }
  }

  Future<bool> applyCoupon(BuildContext context, String couponCode) async {
    if (_applyingCoupon) return false;
    _applyingCoupon = true;
    notifyListeners();
    final l10n = AppLocalizations.of(context);

    try {
      final response = await authRepository.applyCouponRepo(couponCode);
      final message = response.message ??
          (l10n?.translate('couponApplied') ?? 'Coupon applied successfully.');

      if (response.status == 1) {
        Utils.toastMessage(message);
        if (response.coupon != null) {
          final index = _coupons.indexWhere((c) => c.code == couponCode);
          if (index >= 0) {
            _coupons[index] = response.coupon!;
            notifyListeners();
          }
        }
        return true;
      }

      Utils.toastMessage(message);
      return false;
    } catch (e) {
      debugPrint('Apply coupon error: $e');
      Utils.toastMessage(
        l10n?.translate('couldNotLoadSection') ??
            'We could not load this section right now.',
      );
      return false;
    } finally {
      _applyingCoupon = false;
      notifyListeners();
    }
  }

  Future<void> checkBirthday(BuildContext context) async {
    promotions = true;
    try {
      final token = await NetworkApiService().getToken();

      if (token == null || token.isEmpty) {
        debugPrint('Token is missing, skipping checkBirthday API');
        return;
      }

      final response = await authRepository.checkBirthdayRepo();

      if (response.status == 1) {
        _checkBirthdayModel = response;
      }
      if (kDebugMode) {
        debugPrint('Check Birthday Data API Response: $response');
      }
    } catch (e) {
      debugPrint('Check Birthday data error: $e');
    } finally {
      promotions = false;
      notifyListeners();
    }
  }

  Future<void> _fetchCoupons({bool silent = false}) async {
    final response = await authRepository.getCouponsRepo();
    if (response.status == 1) {
      _coupons = response.coupons ?? [];
      notifyListeners();
    } else if (!silent && (response.message ?? '').isNotEmpty) {
      Utils.toastMessage(response.message!);
    }
  }

  Future<void> _fetchOffers({bool silent = false}) async {
    final response = await authRepository.getOffersRepo();
    if (response.status == 1) {
      _offers = response.offers ?? [];
      notifyListeners();
    } else if (!silent && (response.message ?? '').isNotEmpty) {
      Utils.toastMessage(response.message!);
    }
  }

  Future<void> _fetchBirthday({bool silent = false}) async {
    final response = await authRepository.getBirthdayRepo();
    if (response.status == 1) {
      _birthday = response.birthdays ?? [];
      notifyListeners();
    } else if (!silent && (response.message ?? '').isNotEmpty) {
      Utils.toastMessage(response.message!);
    }
  }

  void _showError(BuildContext context, Object error) {
    final l10n = AppLocalizations.of(context);
    Utils.toastMessage(
      l10n?.translate('couldNotLoadSection') ??
          'We could not load this section right now.',
    );
  }
}
