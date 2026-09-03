import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lim_crm/res/app_localization.dart';
import 'package:lim_crm/res/components/promotion_card.dart';
import 'package:lim_crm/utils/app_colors.dart';
import 'package:lim_crm/utils/promotion_display.dart';
import 'package:lim_crm/view_models/promotions_view_model/promotions_view_model.dart';
import 'package:provider/provider.dart';

class OfferScreen extends StatefulWidget {
  const OfferScreen({super.key});

  @override
  State<OfferScreen> createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PromotionsViewModel>().getOffers(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<PromotionsViewModel>(
      builder: (context, vm, _) {
        if (vm.promotionsLoading && vm.offers.isEmpty) {
          return Center(child: Text(l10n.translate('loadingOffers') ?? 'Loading offers...'));
        }
        if (vm.offers.isEmpty) {
          return Center(
            child: Text(
              l10n.translate('noOffersRightNow') ?? 'No offers available right now.',
              style: GoogleFonts.poppins(color: AppColors.textMuted),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: vm.offers.length,
          itemBuilder: (context, index) {
            final item = PromotionItem.fromOffer(vm.offers[index]);
            return PromotionCard(item: item);
          },
        );
      },
    );
  }
}
