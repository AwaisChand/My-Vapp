import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lim_crm/models/vape_saving_model/vape_saving_model.dart';
import 'package:lim_crm/res/app_localization.dart';
import 'package:lim_crm/res/portal_ui.dart';
import 'package:lim_crm/screens/vape_calculator/vape_calculator_screens/new_calculation_screen.dart';
import 'package:lim_crm/screens/vape_calculator/vape_calculator_screens/view_history_screen.dart';
import 'package:lim_crm/utils/app_colors.dart';

class VapeCalculationDetailScreen extends StatelessWidget {
  final VapeSavingModel saving;

  const VapeCalculationDetailScreen({super.key, required this.saving});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: Text(l10n.translate('vapeSavingsCalculationDetails') ?? 'Personal Savings Calculation Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '${l10n.translate('calculationId') ?? 'Calculation ID:'} ${saving.id ?? ''}',
            style: GoogleFonts.poppins(color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NewCalculationScreen()),
                  ),
                  child: Text(l10n.translate('newCalculation') ?? 'New calculation'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ViewHistoryScreen()),
                  ),
                  child: Text(l10n.translate('viewHistory') ?? 'View History'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _section(l10n.translate('smokeInputs') ?? 'Previous inputs', [
            _row(l10n.translate('startDateSmoke') ?? 'Start date', saving.firstDate ?? '—'),
            _row(l10n.translate('todayDate') ?? 'Today date', saving.todayDate ?? '—'),
            _row(l10n.translate('priceForCigarettesBox') ?? 'Pack price', '${saving.packPrice ?? '0.00'} €'),
            _row(l10n.translate('numberOfCigarsPerBox') ?? 'Units per pack', '${saving.cigsPerPack ?? 0}'),
            _row(l10n.translate('numberOfCigarsSmokedADay') ?? 'Units per day', '${saving.cigsPerDay ?? 0}'),
          ]),
          _section(l10n.translate('vapeInputs') ?? 'Personal Inputs', [
            _row(l10n.translate('priceForVapeBottle') ?? 'Price for a Personal bottle', '${saving.vapeUnitPrice ?? '0.00'} €'),
            _row(l10n.translate('howManyBottleSoFar') ?? 'How many bottle so far', '${saving.bottlesCount ?? 0}'),
            _row(l10n.translate('freeBottle') ?? 'Free bottle', '${saving.freeBottles ?? 0}'),
            _row(
              l10n.translate('numberOfDayPerBottle') ?? 'Number of day per bottle',
              saving.daysPerBottle == null ? (l10n.translate('na') ?? 'N/A') : '${saving.daysPerBottle}',
            ),
            _row(l10n.translate('fidelityDiscountPercent') ?? 'Fidelity / Discount %', '${saving.fidelityPercent ?? '0.00'}%'),
          ]),
          _section(l10n.translate('results') ?? 'Results', [
            _row(l10n.translate('totalDays') ?? 'Total Days', '${saving.totalDays ?? 0}'),
            _row(l10n.translate('cigaretteUnitPrice') ?? 'Unit Price', '${saving.cigUnitPrice ?? '0.00'} €'),
            _row(l10n.translate('totalCigaretteCost') ?? 'Total previous cost', '${saving.totalCigCost ?? '0.00'} €'),
            _row(l10n.translate('vapeCostBeforeFidelity') ?? 'Personal Cost Before Fidelity', '${saving.vapeCostBeforeFidelity ?? '0.00'} €'),
            _row(l10n.translate('fidelityDiscountValue') ?? 'Fidelity Discount Value', '${saving.fidelityDiscountValue ?? '0.00'} €'),
            _row(l10n.translate('totalVapeCostAfterFidelity') ?? 'Total Personal Cost After Fidelity', '${saving.totalVapeCostAfterFidelity ?? '0.00'} €'),
            _row(l10n.translate('freeBottleValueResult') ?? 'Free Bottle Value', '${saving.freeBottleValue ?? '0.00'} €'),
            _row(l10n.translate('effectiveTotalVapeValue') ?? 'Effective Total Personal Value (Including Free)', '${saving.effectiveTotalVapeValueIncludingFree ?? '0.00'} €'),
            _row(l10n.translate('finalEffectiveUnitPrice') ?? 'Final Effective Unit Price', '${saving.finalEffectiveUnitPrice ?? '0.00'} €'),
            _row(l10n.translate('eurosSavedVsCigarettes') ?? 'Euros saved vs previous', '${saving.eurosSavedVsCig ?? '0.00'} €'),
            _row(l10n.translate('eurosSavedIncludingFree') ?? 'Euros saved vs previous (including free value)', '${saving.eurosSavedVsCigIncludingFreeValue ?? '0.00'} €'),
            _row(l10n.translate('savingsPerDay') ?? 'Savings per day', '${saving.savingPerDay ?? '0.00'} €'),
            _row(l10n.translate('savingsPerMonth30days') ?? 'Savings per month (~30 days)', '${saving.savingPerMonth ?? '0.00'} €'),
            _row(l10n.translate('savingsPerYear365days') ?? 'Savings per year (~365 days)', '${saving.savingPerYear ?? '0.00'} €'),
          ]),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> rows) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: PortalUi.cardDecoration(radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primary)),
          const SizedBox(height: 10),
          ...rows,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted)),
          Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
