import 'package:lim_crm/models/vape_saving_model/vape_saving_model.dart';

import '../../data/network/base_api_service.dart';
import '../../data/network/network_api_service.dart';
import '../../res/app_url.dart';

class VapeSavingsRepository {
  BaseApiServices baseApiServices = NetworkApiService();

  Future<VapeSavingListModel> historyRepo() async {
    final response = await baseApiServices.getRequest(
      AppUrl.vapeSavingsEndPoint,
    );
    return VapeSavingListModel.fromJson(response);
  }

  Future<dynamic> saveCalculation(Map<String, dynamic> data) async {
    return baseApiServices.postRequest(AppUrl.vapeSavingsEndPoint, data);
  }

  Future<dynamic> deleteCalculation(int id) async {
    return baseApiServices.deleteRequest(AppUrl.vapeSavingDeleteEndPoint(id));
  }

  Future<SlipHistoryModel> slipHistoryRepo() async {
    final response = await baseApiServices.getRequest(
      AppUrl.vapeSlipsHistoryEndPoint,
    );
    return SlipHistoryModel.fromJson(response);
  }

  Future<dynamic> saveSlip(Map<String, dynamic> data) async {
    return baseApiServices.postRequest(AppUrl.vapeSlipsEndPoint, data);
  }
}
