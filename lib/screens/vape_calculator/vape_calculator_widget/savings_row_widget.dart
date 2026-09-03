import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lim_crm/models/vape_saving_model/vape_saving_model.dart';
import 'package:lim_crm/res/app_localization.dart';
import 'package:lim_crm/utils/app_colors.dart';

class SavingsRowWidget extends StatelessWidget {
  final VapeSavingModel? latest;

  const SavingsRowWidget({super.key, this.latest});

  static const _stackedBreakpoint = 480.0;
  static const _cardSpacing = 10.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tiles = [
      _SavingsTileData(
        label: l10n.translate('savingsPerDay') ?? 'Savings per day',
        value: '€${latest?.savingPerDay ?? '0.00'}',
        color: AppColors.accent,
        meta: l10n.translate('latestEstimate') ?? 'Latest estimate',
      ),
      _SavingsTileData(
        label: l10n.translate('savingsPerMonth') ?? 'Savings per month',
        value: '€${latest?.savingPerMonth ?? '0.00'}',
        color: AppColors.primary,
        meta: l10n.translate('approx30Days') ?? '~30 days',
      ),
      _SavingsTileData(
        label: l10n.translate('savingsPerYear') ?? 'Savings per year',
        value: '€${latest?.savingPerYear ?? '0.00'}',
        color: AppColors.accentPink,
        meta: l10n.translate('approx365Days') ?? '~365 days',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final useStacked = constraints.maxWidth < _stackedBreakpoint;

        if (useStacked) {
          return Column(
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                if (i > 0) const SizedBox(height: _cardSpacing),
                _SavingsTile(data: tiles[i], layout: _SavingsTileLayout.stacked),
              ],
            ],
          );
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                if (i > 0) const SizedBox(width: _cardSpacing),
                Expanded(
                  child: _SavingsTile(
                    data: tiles[i],
                    layout: _SavingsTileLayout.compact,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

enum _SavingsTileLayout { compact, stacked }

class _SavingsTileData {
  final String label;
  final String value;
  final Color color;
  final String? meta;

  const _SavingsTileData({
    required this.label,
    required this.value,
    required this.color,
    this.meta,
  });
}

class _SavingsTile extends StatelessWidget {
  final _SavingsTileData data;
  final _SavingsTileLayout layout;

  const _SavingsTile({
    required this.data,
    required this.layout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: layout == _SavingsTileLayout.stacked ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: data.color.withValues(alpha: 0.25)),
      ),
      child: layout == _SavingsTileLayout.stacked ? _buildStacked() : _buildCompact(),
    );
  }

  Widget _buildStacked() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: data.color.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            data.label,
            style: GoogleFonts.poppins(
              color: data.color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
        if (data.meta != null) ...[
          const SizedBox(width: 8),
          Text(
            data.meta!,
            style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted),
          ),
        ],
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            data.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompact() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          data.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(color: data.color, fontSize: 12),
        ),
        if (data.meta != null)
          Text(
            data.meta!,
            style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted),
          ),
        const SizedBox(height: 8),
        SizedBox(
          height: 22,
          width: double.infinity,
          child: Align(
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                data.value,
                maxLines: 1,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
