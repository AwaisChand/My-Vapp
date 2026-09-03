import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../utils/app_colors.dart';
import '../../view_models/order_history_view_model/order_history_view_model.dart';
import '../app_localization.dart';

class TimeRangeDropdown extends StatefulWidget {
  const TimeRangeDropdown({super.key});

  @override
  State<TimeRangeDropdown> createState() => _TimeRangeDropdownState();
}

class _TimeRangeDropdownState extends State<TimeRangeDropdown> {
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        selectedValue = AppLocalizations.of(context)!.translate('all') ?? 'All';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderHistoryProvider = context.read<OrderHistoryViewModel>();
    final options = [
      AppLocalizations.of(context)!.translate('all') ?? 'All',
      AppLocalizations.of(context)!.translate('last7Days') ?? 'Last 7 Days',
      AppLocalizations.of(context)!.translate('last30Days') ?? 'Last 30 Days',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: AppColors.primary),
          borderRadius: BorderRadius.circular(12),
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary),
          dropdownColor: AppColors.cardBg,
          onChanged: (String? newValue) {
            if (newValue == null) return;
            setState(() => selectedValue = newValue);
            final all = AppLocalizations.of(context)!.translate('all');
            final d7 = AppLocalizations.of(context)!.translate('last7Days');
            final d30 = AppLocalizations.of(context)!.translate('last30Days');
            if (newValue == all) {
              orderHistoryProvider.getOrderHistory(context);
            } else if (newValue == d7) {
              orderHistoryProvider.getOrderHistory(context, days: 7);
            } else if (newValue == d30) {
              orderHistoryProvider.getOrderHistory(context, days: 30);
            }
          },
          items: options
              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
              .toList(),
        ),
      ),
    );
  }
}
