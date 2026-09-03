import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lim_crm/res/app_localization.dart';
import 'package:lim_crm/res/components/promotion_card.dart';
import 'package:lim_crm/utils/app_colors.dart';
import 'package:lim_crm/utils/promotion_display.dart';
import 'package:lim_crm/view_models/promotions_view_model/promotions_view_model.dart';
import 'package:provider/provider.dart';

class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PromotionsViewModel>().getCoupons(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<PromotionsViewModel>(
      builder: (context, vm, _) {
        if (vm.promotionsLoading && vm.coupons.isEmpty) {
          return Center(child: Text(l10n.translate('loadingCoupons') ?? 'Loading coupons...'));
        }
        if (vm.coupons.isEmpty) {
          return Center(
            child: Text(
              l10n.translate('noCoupons') ?? 'No coupons available right now.',
              style: GoogleFonts.poppins(color: AppColors.textMuted),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: vm.coupons.length,
          itemBuilder: (context, index) {
            final item = PromotionItem.fromCoupon(vm.coupons[index]);
            return PromotionCard(item: item);
          },
        );
      },
    );
  }
}
