import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lim_crm/res/app_localization.dart';
import 'package:lim_crm/res/portal_ui.dart';
import 'package:lim_crm/utils/app_colors.dart';
import 'package:lim_crm/utils/promotion_display.dart';
import 'package:provider/provider.dart';
import 'package:lim_crm/view_models/promotions_view_model/promotions_view_model.dart';

class PromotionCard extends StatelessWidget {
  final PromotionItem item;
  final VoidCallback? onApply;

  const PromotionCard({super.key, required this.item, this.onApply});

  Future<void> _handleApply(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final vm = context.read<PromotionsViewModel>();

    if (item.hasCode) {
      await PromotionItem.copyCode(item.code!, l10n);
    }

    if (item.isCoupon && item.hasCode) {
      await vm.applyCoupon(context, item.code!.trim());
      return;
    }

    onApply?.call();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final minSpend = item.minSpendText(l10n);
    final vm = context.watch<PromotionsViewModel>();
    final applying = vm.applyingCoupon && item.isCoupon;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: PortalUi.cardDecoration(radius: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    item.badgeText(l10n),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    item.expiryText(l10n),
                    textAlign: TextAlign.right,
                    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.displayTitle(l10n),
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              item.resolvedDescription(l10n),
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMuted),
            ),
            if (minSpend != null) ...[
              const SizedBox(height: 8),
              Text(minSpend, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted)),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  item.hasCode
                      ? (l10n.translate('codeLabel') ?? 'Code:')
                      : (l10n.translate('typeLabel') ?? 'Type:'),
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.hasCode
                        ? item.code!
                        : (l10n.translate('autoApplied') ?? 'Auto applied'),
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                  ),
                ),
                if (item.hasCode)
                  IconButton(
                    tooltip: l10n.translate('copyCode') ?? 'Copy code',
                    onPressed: () => PromotionItem.copyCode(item.code!, l10n),
                    icon: const Icon(Icons.copy_rounded, size: 18),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: item.availableNow && !applying ? () => _handleApply(context) : null,
                child: applying
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(item.applyLabel(l10n)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PromotionDetailDialog {
  static void show(BuildContext context, PromotionItem item) {
    final l10n = AppLocalizations.of(context)!;
    final minSpend = item.minSpendText(l10n);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.translate('offerDetails') ?? 'Offer details',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item.displayTitle(l10n), style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(
                item.typeLabel(l10n),
                style: GoogleFonts.poppins(color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
              if (item.isBirthday) ...[
                const SizedBox(height: 6),
                Text(
                  l10n.translate('exclusiveBirthdayBonus') ?? 'Exclusive birthday bonus',
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
              ],
              const SizedBox(height: 8),
              Text(item.badgeText(l10n), style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              if (!item.availableNow)
                Text(
                  item.expiryText(l10n),
                  style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 13),
                )
              else
                Text(item.resolvedDescription(l10n), style: GoogleFonts.poppins(fontSize: 13)),
              if (minSpend != null) ...[
                const SizedBox(height: 8),
                Text(minSpend, style: GoogleFonts.poppins(fontSize: 13)),
              ],
              const SizedBox(height: 8),
              Text(
                item.neverExpires
                    ? (l10n.translate('neverExpires') ?? 'Never expires')
                    : '${l10n.translate('validUntil') ?? 'Valid until'} ${item.expiryDate ?? '—'}',
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(l10n.translate('codeLabel') ?? 'Code:', style: GoogleFonts.poppins()),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.hasCode
                          ? item.code!
                          : (l10n.translate('autoAppliedHyphen') ?? 'Auto-applied'),
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (item.hasCode)
                    IconButton(
                      tooltip: l10n.translate('copyCode') ?? 'Copy code',
                      onPressed: () => PromotionItem.copyCode(item.code!, l10n),
                      icon: const Icon(Icons.copy_rounded, size: 18),
                    ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.translate('close') ?? 'Close'),
          ),
        ],
      ),
    );
  }
}
