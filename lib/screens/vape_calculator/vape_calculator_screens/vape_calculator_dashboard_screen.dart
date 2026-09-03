import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lim_crm/screens/vape_calculator/vape_calculator_screens/new_calculation_screen.dart';
import 'package:lim_crm/screens/vape_calculator/vape_calculator_screens/vapofumeur_record_screen.dart';
import 'package:lim_crm/view_models/bottom_nav_view_model/bottom_nav_view_model.dart';
import 'package:lim_crm/screens/vape_calculator/vape_calculator_screens/view_history_screen.dart';
import 'package:lim_crm/screens/vape_calculator/vape_calculator_widget/savings_row_widget.dart';
import 'package:lim_crm/screens/vape_calculator/vape_calculator_widget/snaphot_card_widget.dart';
import 'package:lim_crm/utils/app_colors.dart';
import 'package:lim_crm/view_models/vape_savings_view_model/vape_savings_view_model.dart';
import 'package:provider/provider.dart';

import '../../../res/app_localization.dart';
import '../../../res/components/customer_shell.dart';

class VapeCalculatorDashboardScreen extends StatefulWidget {
  final bool embedded;

  const VapeCalculatorDashboardScreen({super.key, this.embedded = false});

  @override
  State<VapeCalculatorDashboardScreen> createState() =>
      _VapeCalculatorDashboardScreenState();
}

class _VapeCalculatorDashboardScreenState
    extends State<VapeCalculatorDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VapeSavingsViewModel>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<VapeSavingsViewModel>(
      builder: (context, vm, _) {
        final yearly = vm.latest?.savingPerYear ?? '0.00';
        return Scaffold(
          backgroundColor: AppColors.scaffoldBg,
          appBar: widget.embedded
              ? null
              : AppBar(title: Text(l10n.translate('vapeCalc') ?? 'Vape Calculator')),
          body: vm.loading && vm.history.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  bottom: false,
                  child: RefreshIndicator(
                  onRefresh: vm.loadHistory,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(20, widget.embedded ? 12 : 20, 20, 32),
                    child: Column(
                      children: [
                        if (widget.embedded && CustomerShell.menuButton(context) != null)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: CustomerShell.menuButton(context)!,
                          ),
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.translate('vapeCalc') ?? 'Vape Calculator',
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.translate('vapeSavingsOverview') ??
                                    'Vape savings overview',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.translate('fromLatestCalc') ??
                                    'From your latest saved calculation',
                                style: GoogleFonts.poppins(color: Colors.white70),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '€$yearly',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                l10n.translate('projectedYearlyValue') ??
                                    'Projected value over roughly 365 days based on your latest calculation.',
                                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                              ),
                              const SizedBox(height: 18),
                              _actionBtn(
                                l10n.translate('recordSlip') ?? 'If I slip, I click here',
                                Icons.warning_amber_rounded,
                                AppColors.accentPink,
                                () async {
                                  final saved = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const VapofumeurRecordScreen(),
                                    ),
                                  );
                                  if (saved == true && context.mounted) {
                                    context
                                        .read<BottomNavViewModel>()
                                        .selectTab(BottomNavIndex.vapofumeur);
                                  }
                                },
                              ),
                              const SizedBox(height: 8),
                              _actionBtn(
                                l10n.translate('newCalculation') ?? 'Start new calculation',
                                Icons.add_circle_outline,
                                AppColors.accent,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const NewCalculationScreen(),
                                  ),
                                ).then((_) => vm.loadHistory()),
                              ),
                              const SizedBox(height: 8),
                              _actionBtn(
                                l10n.translate('historiqueSimulations') ?? 'Historique de mes simulations',
                                Icons.history,
                                Colors.white.withValues(alpha: 0.2),
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ViewHistoryScreen(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SnapshotCardWidget(latest: vm.latest),
                        const SizedBox(height: 12),
                        SavingsRowWidget(latest: vm.latest),
                      ],
                    ),
                  ),
                ),
              ),
        );
      },
    );
  }

  Widget _actionBtn(String text, IconData icon, Color bg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
