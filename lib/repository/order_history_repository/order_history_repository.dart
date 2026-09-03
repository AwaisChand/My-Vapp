import 'package:flutter/foundation.dart';
import 'package:lim_crm/models/order_history_model/order_history_model.dart';

import '../../data/network/base_api_service.dart';
import '../../data/network/network_api_service.dart';
import '../../res/app_url.dart';

class OrderHistoryRepository {
  BaseApiServices baseApiServices = NetworkApiService();

  Future<OrderHistoryModel> getAllOrderHistoryRepo({int? days}) async {
    try {
      String url = AppUrl.orderHistoryEndPoint;
      if (days != null) {
        url += '?days=$days';
      }

      dynamic response = await baseApiServices.getRequest(url);
      debugPrint("Order History URL: $url");
      return OrderHistoryModel.fromJson(response);
    } catch (e) {
      debugPrint("Order History Error: $e");
      rethrow;
    }
  }
}
