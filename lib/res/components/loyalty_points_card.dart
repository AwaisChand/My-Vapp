import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../res/portal_ui.dart';
import '../../utils/app_colors.dart';
import '../../utils/utils.dart';
import '../../view_models/home_view_model/home_view_model.dart';
import '../app_localization.dart';

class LoyaltyPointsCard extends StatelessWidget {
  const LoyaltyPointsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, home, _) {
        final balance = home.redeemPointsHistoryModel?.currentBalance ?? 0;
        final earned = home.redeemPointsHistoryModel?.totalEarnedPoints ?? 0;
        final progress = earned == 0 ? 0.0 : (balance / earned).clamp(0.0, 1.0);

        return Container(
          padding: const EdgeInsets.all(22),
          decoration: PortalUi.heroDecoration(radius: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.stars_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)!.translate('loyaltyPts') ?? '',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                '€${balance.toStringAsFixed(2)}',
                style: PortalUi.heroBalance(context),
              ),
              const SizedBox(height: 6),
              Text(
                '${AppLocalizations.of(context)!.translate('ofEarned') ?? 'of'} €${earned.toStringAsFixed(2)} ${AppLocalizations.of(context)!.translate('earned') ?? 'earned'}',
                style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.82), fontSize: 13),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.22),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Utils.redeemDialog(context),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.translate('redeem') ?? '',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
