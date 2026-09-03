import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lim_crm/res/app_localization.dart';
import 'package:lim_crm/res/components/promotion_card.dart';
import 'package:lim_crm/utils/app_colors.dart';
import 'package:lim_crm/utils/promotion_display.dart';
import 'package:lim_crm/view_models/promotions_view_model/promotions_view_model.dart';
import 'package:provider/provider.dart';

class AllScreen extends StatefulWidget {
  const AllScreen({super.key});

  @override
  State<AllScreen> createState() => _AllScreenState();
}

class _AllScreenState extends State<AllScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<PromotionsViewModel>();
      vm.getCoupons(context);
      vm.getOffers(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<PromotionsViewModel>(
      builder: (context, vm, _) {
        if (vm.promotionsLoading && vm.coupons.isEmpty && vm.offers.isEmpty) {
          return Center(child: Text(l10n.translate('loadingOffers') ?? 'Loading offers...'));
        }

        final items = <PromotionItem>[
          ...vm.coupons.map(PromotionItem.fromCoupon),
          ...vm.offers.map(PromotionItem.fromOffer),
        ];
        items.sort((a, b) {
          final ad = DateTime.tryParse(a.expiryDate ?? '') ?? DateTime(9999);
          final bd = DateTime.tryParse(b.expiryDate ?? '') ?? DateTime(9999);
          return ad.compareTo(bd);
        });

        if (items.isEmpty) {
          return Center(
            child: Text(
              l10n.translate('noOffersAreAvailable') ?? 'No offers are available right now.',
              style: GoogleFonts.poppins(color: AppColors.textMuted),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: items.length,
          itemBuilder: (context, index) => PromotionCard(item: items[index]),
        );
      },
    );
  }
}
