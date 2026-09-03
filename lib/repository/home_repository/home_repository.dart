import 'package:flutter/foundation.dart';
import 'package:lim_crm/models/ad_model/ad_model.dart';
import 'package:lim_crm/models/dashboard_model/dashboard_model.dart';
import 'package:lim_crm/models/get_news_letter_model/get_news_letter_model.dart';
import 'package:lim_crm/models/redeem_points_history_model/redeem_points_history_model.dart';

import '../../data/network/base_api_service.dart';
import '../../data/network/network_api_service.dart';
import '../../res/app_url.dart';

class HomeRepository {
  BaseApiServices baseApiServices = NetworkApiService();

  Future<DashboardModel> dashboardRepo() async {
    final response = await baseApiServices.getRequest(AppUrl.dashboardEndPoint);
    return DashboardModel.fromJson(response);
  }

  Future<AdModel> adsRepo() async {
    final response = await baseApiServices.getRequest(AppUrl.adsEndPoint);
    return AdModel.fromJson(response);
  }

  Future<RedeemPointsHistoryModel> redeemPointsHistoryRepo() async {
    try {
      dynamic response = await baseApiServices.getRequest(
        AppUrl.redeemPointsHistoryEndPoint,
      );
      return RedeemPointsHistoryModel.fromJson(response);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<dynamic> redeemNow(dynamic data) async {
    try {
      return await baseApiServices.postRequest(AppUrl.redeemNowEndPoint, data);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<GetNewsLetterModel> getNewsLetterRepo() async {
    try {
      dynamic response = await baseApiServices.getRequest(
        AppUrl.getNewsLetterEndPoint,
      );
      return GetNewsLetterModel.fromJson(response);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<dynamic> updateLanguage(String locale) async {
    return baseApiServices.postRequest(AppUrl.languageEndPoint, {
      'locale': locale,
    });
  }
}
