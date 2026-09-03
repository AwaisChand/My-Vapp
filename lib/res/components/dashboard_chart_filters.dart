import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/app_colors.dart';
import '../../utils/locale_format_utils.dart';
import '../app_localization.dart';

class DashboardChartFilters extends StatelessWidget {
  final List<int> years;
  final int selectedYear;
  final int selectedMonth;
  final ValueChanged<int> onYearChanged;
  final ValueChanged<int> onMonthChanged;

  const DashboardChartFilters({
    super.key,
    required this.years,
    required this.selectedYear,
    required this.selectedMonth,
    required this.onYearChanged,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (years.isEmpty) return const SizedBox.shrink();

    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 8,
      runSpacing: 8,
      children: [
        _dropdown(
          maxWidth: 168,
          value: selectedMonth,
          items: [
            DropdownMenuItem(
              value: 0,
              child: Text(
                LocaleFormatUtils.allMonthsLabel(l10n),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ...List.generate(12, (i) {
              final month = i + 1;
              return DropdownMenuItem(
                value: month,
                child: Text(
                  LocaleFormatUtils.monthFullName(l10n, month),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
          ],
          onChanged: (value) {
            if (value != null) onMonthChanged(value);
          },
        ),
        _dropdown(
          maxWidth: 92,
          value: years.contains(selectedYear) ? selectedYear : years.first,
          items: years
              .map(
                (year) => DropdownMenuItem(
                  value: year,
                  child: Text('$year'),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) onYearChanged(value);
          },
        ),
      ],
    );
  }

  Widget _dropdown({
    required double maxWidth,
    required int value,
    required List<DropdownMenuItem<int>> items,
    required ValueChanged<int?> onChanged,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.scaffoldBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: value,
            isDense: true,
            isExpanded: true,
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textPrimary),
            items: items,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

class DashboardOfferDialog {
  static void show(BuildContext context, dynamic offer) {
    final name = offer.name?.toString() ?? 'Offer';
    final code = offer.code?.toString();
    final type = offer.type?.toString() ?? 'offer';
    final description = offer.description?.toString();
    final isUnavailable = offer.availableNow == false;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              type == 'birthday'
                  ? 'Birthday reward'
                  : type == 'coupon'
                      ? 'Coupon'
                      : 'Offer',
              style: GoogleFonts.poppins(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
            if (isUnavailable) ...[
              const SizedBox(height: 8),
              Text(
                'This reward is not available at the moment.',
                style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 13),
              ),
            ] else if (description != null && description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(description, style: GoogleFonts.poppins(color: AppColors.textMuted)),
            ],
            if (code != null && code.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Code: $code',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }
}
