import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lim_crm/models/vape_saving_model/vape_saving_model.dart';
import 'package:lim_crm/res/app_localization.dart';
import 'package:lim_crm/utils/app_colors.dart';

class SnapshotCardWidget extends StatelessWidget {
  final VapeSavingModel? latest;

  const SnapshotCardWidget({super.key, this.latest});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: latest == null
          ? Text(
              l10n.translate('noRecordYet') ?? 'No record yet',
              style: GoogleFonts.poppins(color: AppColors.textMuted),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.translate('latestUpdate') ?? 'Latest update',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
                ),
                Text(
                  l10n.translate('yourSnapshot') ?? 'Your snapshot',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                _row(l10n.translate('lastSavedDate') ?? 'Last saved date', latest!.createdAt ?? '—'),
                _row(l10n.translate('monthlyEquivalent') ?? 'Monthly equivalent', '€${latest!.savingPerMonth ?? '0.00'}'),
                _row(l10n.translate('dailyEquivalent') ?? 'Daily equivalent', '€${latest!.savingPerDay ?? '0.00'}'),
              ],
            ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(color: AppColors.textMuted)),
          Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
