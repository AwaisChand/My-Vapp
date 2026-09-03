import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lim_crm/models/order_history_model/order_history_model.dart';
import 'package:lim_crm/repository/order_history_repository/order_history_repository.dart';

import '../../utils/utils.dart';

class OrderHistoryViewModel extends ChangeNotifier{

  final OrderHistoryRepository authRepository = OrderHistoryRepository();

  List<Orders> _orders = [];
  List<Orders> get orders => _orders;



  bool _orderHistoryLoading = false;
  bool get orderHistoryLoading => _orderHistoryLoading;

  set orderHistory(bool setLoading) {
    _orderHistoryLoading = setLoading;
    notifyListeners();
  }


  Future<void> getOrderHistory(BuildContext context, {int? days}) async {
    orderHistory = true;
    try {
      final response = await authRepository.getAllOrderHistoryRepo(days: days);

      if (response.status == 1) {
        _orders = response.orders!;
        Utils.toastMessage(response.success ?? '');
      } else {
        Utils.toastMessage(response.success ?? '');
      }

      if (kDebugMode) {
        debugPrint("Get Orders history Data API Response: $response");
      }
    } catch (e,stackTrace) {
      debugPrint("Orders history data error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      orderHistory = false;
    }
  }

}