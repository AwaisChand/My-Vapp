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
                _row(
                  l10n.translate('lastSavedDate') ?? 'Last saved date',
                  _formatDate(latest!.createdAt),
                ),
                _row(
                  l10n.translate('monthlyEquivalent') ?? 'Monthly equivalent',
                  '€${latest!.savingPerMonth ?? '0.00'}',
                ),
                _row(
                  l10n.translate('dailyEquivalent') ?? 'Daily equivalent',
                  '€${latest!.savingPerDay ?? '0.00'}',
                ),
              ],
            ),
    );
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    final local = parsed.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min';
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(color: AppColors.textMuted),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
