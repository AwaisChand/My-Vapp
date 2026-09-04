import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lim_crm/res/app_localization.dart';
import 'package:lim_crm/res/components/promotion_card.dart';
import 'package:lim_crm/utils/app_colors.dart';
import 'package:lim_crm/utils/promotion_display.dart';
import 'package:lim_crm/view_models/promotions_view_model/promotions_view_model.dart';
import 'package:provider/provider.dart';

class BirthdayScreen extends StatefulWidget {
  const BirthdayScreen({super.key});

  @override
  State<BirthdayScreen> createState() => _BirthdayScreenState();
}

class _BirthdayScreenState extends State<BirthdayScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PromotionsViewModel>();
      provider.getBirthday(context);
      provider.checkBirthday(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<PromotionsViewModel>(
      builder: (context, vm, _) {
        final isBirthday = vm.checkBirthdayModel?.daysRemaining == 0;
        if (!isBirthday) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                '🎁 ${l10n.translate('tellBirthday') ?? 'Birthday offers appear on your birthday!'}',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          );
        }
        if (vm.promotionsLoading && vm.birthday.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (vm.birthday.isEmpty) {
          return Center(
            child: Text(
              l10n.translate('noPromotionsRightNow') ??
                  'No birthday rewards available right now.',
              style: GoogleFonts.poppins(color: AppColors.textMuted),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: vm.birthday.length,
          itemBuilder: (context, index) {
            return PromotionCard(
              item: PromotionItem.fromBirthday(vm.birthday[index]),
            );
          },
        );
      },
    );
  }
}
