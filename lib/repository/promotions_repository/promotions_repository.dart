import 'package:flutter/foundation.dart';
import 'package:lim_crm/models/apply_coupon_model/apply_coupon_model.dart';
import 'package:lim_crm/models/check_birthday_model/check_birthday_model.dart';
import 'package:lim_crm/models/coupons_model/coupons_model.dart';
import 'package:lim_crm/models/get_birthday_model/get_birthday_model.dart';
import 'package:lim_crm/models/offers_model/offers_model.dart';

import '../../data/network/base_api_service.dart';
import '../../data/network/network_api_service.dart';
import '../../res/app_url.dart';

class PromotionsRepository {
  BaseApiServices baseApiServices = NetworkApiService();

  Future<CouponsModel> getCouponsRepo() async {
    try {
      dynamic response = await baseApiServices.getRequest(
        AppUrl.couponsEndPoint,
      );
      debugPrint("Raw API response JSON: $response");
      debugPrint("Api url: ${AppUrl.couponsEndPoint}");

      return CouponsModel.fromJson(response);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<OffersModel> getOffersRepo() async {
    try {
      dynamic response = await baseApiServices.getRequest(
        AppUrl.offersEndPoint,
      );
      debugPrint("Raw API response JSON: $response");
      debugPrint("Api url: ${AppUrl.offersEndPoint}");

      return OffersModel.fromJson(response);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<GetBirthdayModel> getBirthdayRepo() async {
    try {
      dynamic response = await baseApiServices.getRequest(
        AppUrl.birthdayEndPoint,
      );
      debugPrint("Raw API response JSON: $response");
      debugPrint("Api url: ${AppUrl.birthdayEndPoint}");

      return GetBirthdayModel.fromJson(response);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<ApplyCouponModel> applyCouponRepo(String couponCode, {double cartAmount = 0}) async {
    try {
      final response = await baseApiServices.postJsonRequest(
        AppUrl.applyCouponEndPoint,
        {
          'coupon_code': couponCode,
          'cart_amount': cartAmount,
        },
      );
      debugPrint('Apply coupon response: $response');
      return ApplyCouponModel.fromJson(response);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<CheckBirthdayModel> checkBirthdayRepo() async {
    try {
      dynamic response = await baseApiServices.getRequest(
        AppUrl.checkBirthdayEndPoint,
      );
      debugPrint("Raw API response JSON: $response");
      debugPrint("Api url: ${AppUrl.checkBirthdayEndPoint}");

      return CheckBirthdayModel.fromJson(response);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
