import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/dashboard_model/dashboard_model.dart';
import '../../screens/vape_calculator/vape_calculator_screens/new_calculation_screen.dart';
import '../../screens/vape_calculator/vape_calculator_screens/vapofumeur_record_screen.dart';
import '../../utils/app_colors.dart';
import '../../utils/tier_ui_utils.dart';
import '../../view_models/bottom_nav_view_model/bottom_nav_view_model.dart';
import '../../view_models/home_view_model/home_view_model.dart';
import '../app_localization.dart';
import '../portal_ui.dart';

enum LoyaltyBannerMode { dashboard, cashback }

class LoyaltyBanner extends StatelessWidget {
  final LoyaltyBannerMode mode;

  const LoyaltyBanner({super.key, this.mode = LoyaltyBannerMode.dashboard});

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<HomeViewModel>().dashboard;
    final snapshot = dashboard?.snapshot;
    final tier = dashboard?.tierProgress;
    final balance = snapshot?.currentBalance ?? 0;
    final tierProgressAmount = snapshot?.totalEarnedCashback ?? balance;

    if (mode == LoyaltyBannerMode.cashback) {
      return _CashbackSummaryCard(
        balance: balance,
        tier: tier,
        tierProgressAmount: tierProgressAmount,
      );
    }

    return _DashboardHeroCard(balance: balance, tier: tier);
  }
}

class _DashboardHeroCard extends StatelessWidget {
  final double balance;
  final TierProgress? tier;

  const _DashboardHeroCard({required this.balance, this.tier});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentTierName = tier?.currentTier?.name ?? '—';
    final nextTierName = tier?.nextTier?.name;
    final isTop = tier?.isTopTier == true;
    final progress = (tier?.progressPercent ?? 0) / 100;
    final benefits = TierUiUtils.nextTierBenefitsText(tier?.nextTier?.benefits);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: PortalUi.heroDecoration(radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.military_tech_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${l10n.translate('level') ?? 'Level'} $currentTierName',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.translate('availableCashbackBalance') ?? 'Available cashback balance',
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text('€${balance.toStringAsFixed(2)}', style: PortalUi.heroBalance(context)),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.22),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  currentTierName,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
                ),
              ),
              if (!isTop && nextTierName != null)
                Expanded(
                  child: Text(
                    _nextTierLine(l10n, nextTierName, benefits),
                    textAlign: TextAlign.right,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                Text(
                  l10n.translate('maximumBenefitsUnlocked') ?? 'Maximum benefits unlocked',
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11),
                ),
            ],
          ),
          const SizedBox(height: 18),
          _DashboardActions(l10n: l10n),
        ],
      ),
    );
  }

  String _nextTierLine(AppLocalizations l10n, String nextTierName, String? benefits) {
    final template = l10n.translate('nextTierRateLabel') ?? 'Next tier (:tier)';
    var line = template.replaceAll(':tier', nextTierName);
    if (benefits != null && benefits.isNotEmpty) {
      line = '$line · $benefits';
    }
    return line;
  }
}

class _DashboardActions extends StatelessWidget {
  final AppLocalizations l10n;

  const _DashboardActions({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _actionButton(
          context,
          label: l10n.translate('newCalculation') ?? 'New calculation',
          icon: Icons.calculate_rounded,
          primary: true,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewCalculationScreen()),
          ),
        ),
        const SizedBox(height: 10),
        _actionButton(
          context,
          label: l10n.translate('ifISlip') ?? l10n.translate('recordSlip') ?? 'If I slip, I click here',
          icon: Icons.warning_amber_rounded,
          primary: false,
          onTap: () async {
            final saved = await Navigator.push<bool>(
              context,
              MaterialPageRoute(builder: (_) => const VapofumeurRecordScreen()),
            );
            if (saved == true && context.mounted) {
              context.read<BottomNavViewModel>().selectTab(BottomNavIndex.vapofumeur);
            }
          },
        ),
      ],
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool primary,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: primary ? Colors.white : Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 18, color: primary ? AppColors.primaryDark : Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    style: GoogleFonts.poppins(
                      color: primary ? AppColors.primaryDark : Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CashbackSummaryCard extends StatelessWidget {
  final double balance;
  final TierProgress? tier;
  final double tierProgressAmount;

  const _CashbackSummaryCard({
    required this.balance,
    required this.tier,
    required this.tierProgressAmount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final current = tier?.currentTier;
    final next = tier?.nextTier;
    final isTop = tier?.isTopTier == true;
    final currentName = current?.name ?? '—';
    final progress = (tier?.progressPercent ?? 0) / 100;
    final tierColor = TierUiUtils.tierForeground(currentName);

    String progressMessage;
    if (isTop) {
      progressMessage = l10n.translate('maximumBenefitsUnlocked') ?? 'Maximum benefits unlocked';
    } else {
      final template = l10n.translate('onlyLeftToReach') ?? 'Only :amount left to reach :tier';
      progressMessage = template
          .replaceAll(':amount', TierUiUtils.formatEuro(tier?.amountToNext ?? 0))
          .replaceAll(':tier', next?.name ?? '');
    }

    return Container(
      decoration: PortalUi.cardDecoration(radius: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 560;
          final balanceBlock = _balanceBlock(l10n);
          final tierBlock = _tierBlock(
            l10n,
            currentName,
            tierColor,
            progressMessage,
            progress,
            current,
            next,
            isTop,
            tierProgressAmount,
          );

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                balanceBlock,
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Divider(height: 1, color: AppColors.border),
                ),
                tierBlock,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: balanceBlock),
              Container(
                width: 1,
                height: 96,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: AppColors.border,
              ),
              Expanded(child: tierBlock),
            ],
          );
        },
      ),
    );
  }

  Widget _balanceBlock(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('availableCashback') ?? 'Available cashback',
          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 8),
        Text(
          '€${balance.toStringAsFixed(2)}',
          style: GoogleFonts.poppins(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF16A34A),
            height: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.translate('usableImmediately') ?? 'Usable immediately',
          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _tierBlock(
    AppLocalizations l10n,
    String currentName,
    Color tierColor,
    String progressMessage,
    double progress,
    TierInfo? current,
    TierInfo? next,
    bool isTop,
    double tierProgressAmount,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TierEmblem(tierName: currentName),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.translate('level') ?? 'Level'} $currentName',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: tierColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    progressMessage,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation(tierColor),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              TierUiUtils.formatEuro(tierProgressAmount),
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            Text(
              TierUiUtils.formatEuro(isTop ? tierProgressAmount : (next?.min ?? 0)),
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TierEmblem extends StatelessWidget {
  final String tierName;

  const _TierEmblem({required this.tierName});

  @override
  Widget build(BuildContext context) {
    final fg = TierUiUtils.tierForeground(tierName);
    final bg = TierUiUtils.tierBackground(tierName);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(Icons.shield_rounded, color: fg, size: 24),
    );
  }
}
