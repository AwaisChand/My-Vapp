import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/ad_model/ad_model.dart';
import '../../utils/app_colors.dart';
import '../../view_models/home_view_model/home_view_model.dart';
import '../app_localization.dart';
import 'ad_carousel.dart';
import 'savings_animation.dart';

class DashboardSavingsRow extends StatelessWidget {
  final List<AdItem>? ads;

  const DashboardSavingsRow({super.key, this.ads});

  static const _stackedBreakpoint = 480.0;
  static const _cardSpacing = 10.0;
  static const _compactCardMinHeight = 118.0;

  String? _formatUpdatedAt(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    final date = DateTime.tryParse(iso);
    if (date == null) return null;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final home = context.watch<HomeViewModel>();
    final snapshot = home.dashboard?.snapshot;
    final updated = _formatUpdatedAt(home.dashboard?.savingsUpdatedAt);
    final adItems = ads ?? home.ads;
    final hasAds = adItems.isNotEmpty;

    final hasSavings = (snapshot?.savingPerDay ?? 0) > 0 ||
        (snapshot?.savingPerMonth ?? 0) > 0 ||
        (snapshot?.savingPerYear ?? 0) > 0;
    final updatedMeta = updated != null
        ? '${l10n.translate('latestEstimate') ?? 'Latest estimate'} • $updated'
        : (hasSavings
            ? (l10n.translate('latestEstimate') ?? 'Latest estimate')
            : (l10n.translate('noSavingsDataYet') ?? 'No savings data available yet.'));

    final cards = [
      _SavingsCardData(
        label: l10n.translate('perDay') ?? 'Per day',
        value: snapshot?.savingPerDay ?? 0,
        icon: Icons.wb_sunny_outlined,
        tint: const Color(0xFFFFF7ED),
        iconColor: const Color(0xFFEA580C),
        meta: l10n.translate('latestEstimate') ?? 'Latest estimate',
      ),
      _SavingsCardData(
        label: l10n.translate('perMonth') ?? 'Per month',
        value: snapshot?.savingPerMonth ?? 0,
        icon: Icons.calendar_month_outlined,
        tint: const Color(0xFFEFF6FF),
        iconColor: AppColors.info,
        meta: l10n.translate('approx30Days') ?? '~30 days',
      ),
      _SavingsCardData(
        label: l10n.translate('perYear') ?? 'Per year',
        value: snapshot?.savingPerYear ?? 0,
        icon: Icons.show_chart_rounded,
        tint: AppColors.primarySoft,
        iconColor: AppColors.primary,
        meta: l10n.translate('approx365Days') ?? '~365 days',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(Icons.trending_up_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.translate('latestSavings') ?? 'Latest savings',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
            if (updatedMeta.isNotEmpty)
              Flexible(
                child: Text(
                  updatedMeta,
                  style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted),
                  textAlign: TextAlign.right,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final useStacked = constraints.maxWidth < _stackedBreakpoint;

            Widget cardsRow;
            if (useStacked) {
              cardsRow = Column(
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(height: _cardSpacing),
                    _SavingsCard(data: cards[i], layout: _SavingsCardLayout.stacked),
                  ],
                ],
              );
            } else {
              cardsRow = IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < cards.length; i++) ...[
                      if (i > 0) const SizedBox(width: _cardSpacing),
                      Expanded(
                        child: _SavingsCard(
                          data: cards[i],
                          layout: _SavingsCardLayout.compact,
                          minHeight: _compactCardMinHeight,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }

            final chart = SavingsAnimation(
              dayValue: snapshot?.savingPerDay ?? 0,
              monthValue: snapshot?.savingPerMonth ?? 0,
              yearValue: snapshot?.savingPerYear ?? 0,
            );

            if (!hasAds) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  cardsRow,
                  const SizedBox(height: 12),
                  chart,
                ],
              );
            }

            if (useStacked) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  cardsRow,
                  const SizedBox(height: 12),
                  chart,
                  const SizedBox(height: 12),
                  AdCarousel(ads: adItems),
                ],
              );
            }

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        cardsRow,
                        const SizedBox(height: 12),
                        chart,
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: AdCarousel(ads: adItems),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

enum _SavingsCardLayout { compact, stacked }

class _SavingsCardData {
  final String label;
  final double value;
  final IconData icon;
  final Color iconColor;
  final Color tint;
  final String? meta;

  const _SavingsCardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.tint,
    this.meta,
  });
}

class _SavingsCard extends StatelessWidget {
  final _SavingsCardData data;
  final _SavingsCardLayout layout;
  final double? minHeight;

  const _SavingsCard({
    required this.data,
    required this.layout,
    this.minHeight,
  });

  String get _formattedValue => '€${data.value.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: minHeight != null ? BoxConstraints(minHeight: minHeight!) : null,
      width: layout == _SavingsCardLayout.stacked ? double.infinity : null,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: data.tint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: layout == _SavingsCardLayout.stacked ? _buildStacked() : _buildCompact(),
    );
  }

  Widget _buildStacked() {
    return Row(
      children: [
        _iconBadge(),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formattedValue,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: AppColors.textPrimary,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                data.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
              ),
              if (data.meta != null)
                Text(
                  data.meta!,
                  style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompact() {
    return Row(
      children: [
        _iconBadge(),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                data.label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  letterSpacing: 0.04,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formattedValue,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  height: 1.1,
                ),
              ),
              if (data.meta != null)
                Text(
                  data.meta!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _iconBadge() {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: AppColors.softShadow,
      ),
      child: Icon(data.icon, color: data.iconColor, size: 17),
    );
  }
}
