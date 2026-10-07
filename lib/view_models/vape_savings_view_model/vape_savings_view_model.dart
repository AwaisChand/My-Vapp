import 'package:flutter/material.dart';
import 'package:lim_crm/models/vape_saving_model/vape_saving_model.dart';

import '../../repository/vape_savings_repository/vape_savings_repository.dart';
import '../../utils/utils.dart';

class VapeSavingsViewModel extends ChangeNotifier {
  final VapeSavingsRepository _repository = VapeSavingsRepository();

  bool _loading = false;
  bool get loading => _loading;

  List<VapeSavingModel> _history = [];
  List<VapeSavingModel> get history => _history;

  VapeSavingModel? _latest;
  VapeSavingModel? get latest => _latest;

  SlipHistoryModel? _slipHistory;
  SlipHistoryModel? get slipHistory => _slipHistory;

  double get yearlySavings {
    if (_latest?.savingPerYear != null) {
      return double.tryParse(_latest!.savingPerYear!) ?? 0;
    }
    return 0;
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> loadHistory() async {
    _setLoading(true);
    try {
      final response = await _repository.historyRepo();
      if (response.status == 1) {
        _history = response.items;
        _latest = _history.isNotEmpty ? _history.first : null;
      }
    } catch (e) {
      debugPrint('Vape history error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> saveCalculation(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    _setLoading(true);
    try {
      final response = await _repository.saveCalculation(data);
      Utils.toastMessage(response['message'] ?? '');
      if (response['status'].toString() == '1') {
        await loadHistory();
        return true;
      }
      return false;
    } catch (e) {
      Utils.toastMessage('Error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteCalculation(BuildContext context, int id) async {
    _setLoading(true);
    try {
      final response = await _repository.deleteCalculation(id);
      Utils.toastMessage(response['message'] ?? '');
      if (response['status'].toString() == '1') {
        await loadHistory();
      }
    } catch (e) {
      Utils.toastMessage('Error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadSlipHistory() async {
    _setLoading(true);
    try {
      _slipHistory = await _repository.slipHistoryRepo();
    } catch (e) {
      debugPrint('Slip history error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> saveSlip(BuildContext context, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final response = await _repository.saveSlip(data);
      Utils.toastMessage(response['message'] ?? '');
      if (response['status'].toString() == '1') {
        await loadSlipHistory();
        return true;
      }
      return false;
    } catch (e) {
      Utils.toastMessage('Error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
