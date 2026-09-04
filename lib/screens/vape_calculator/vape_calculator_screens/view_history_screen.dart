import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lim_crm/screens/vape_calculator/vape_calculator_screens/new_calculation_screen.dart';
import 'package:lim_crm/screens/vape_calculator/vape_calculator_screens/vape_calculation_detail_screen.dart';
import 'package:lim_crm/utils/app_colors.dart';
import 'package:lim_crm/view_models/vape_savings_view_model/vape_savings_view_model.dart';
import 'package:provider/provider.dart';

import '../../../res/app_localization.dart';

class ViewHistoryScreen extends StatefulWidget {
  const ViewHistoryScreen({super.key});

  @override
  State<ViewHistoryScreen> createState() => _ViewHistoryScreenState();
}

class _ViewHistoryScreenState extends State<ViewHistoryScreen> {
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
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: Text(l10n.translate('vapeSavingsCalculationHistory') ?? 'Vape Savings Calculation History'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewCalculationScreen()),
          );
          if (!context.mounted) return;
          context.read<VapeSavingsViewModel>().loadHistory();
        },
        label: Text(l10n.translate('newCalculation') ?? 'New'),
        icon: const Icon(Icons.add),
      ),
      body: Consumer<VapeSavingsViewModel>(
        builder: (context, vm, _) {
          if (vm.loading && vm.history.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.history.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.translate('noCalculationsFound') ?? 'No calculations found.',
                      style: GoogleFonts.poppins(color: AppColors.textMuted),
                    ),
                    TextButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NewCalculationScreen(),
                          ),
                        );
                        if (!context.mounted) return;
                        context.read<VapeSavingsViewModel>().loadHistory();
                      },
                      child: Text(
                        l10n.translate('createFirstCalculation') ??
                            'Create your first calculation',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.translate('viewAllSavedCalculations') ??
                        'View all your saved calculations',
                    style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 13),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: vm.history.length + 1,
            itemBuilder: (context, index) {
              if (index == vm.history.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 24),
                  child: Text(
                    (l10n.translate('showingResults') ??
                            'Showing :from to :to of :total results')
                        .replaceAll(':from', '1')
                        .replaceAll(':to', '${vm.history.length}')
                        .replaceAll(':total', '${vm.history.length}'),
                    style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 12),
                  ),
                );
              }
              final item = vm.history[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '#${item.id}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(l10n.translate('deleteCalculationConfirm') ?? 'Are you sure you want to delete this calculation?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: Text(l10n.translate('cancel') ?? 'Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: Text(l10n.translate('delete') ?? 'Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true && item.id != null) {
                              if (!context.mounted) return;
                              await vm.deleteCalculation(context, item.id!);
                            }
                          },
                          icon: const Icon(Icons.delete_outline, color: Colors.white70),
                        ),
                      ],
                    ),
                    _line(l10n.translate('id') ?? 'ID', '#${item.id}'),
                    _line(l10n.translate('startDate') ?? 'Start Date', item.firstDate ?? '—'),
                    _line(l10n.translate('todayDateCol') ?? 'Today Date', item.todayDate ?? '—'),
                    _line(l10n.translate('totalDays') ?? 'Total Days', '${item.totalDays}'),
                    _line(l10n.translate('totalCigCost') ?? 'Total Cig Cost', '€${item.totalCigCost}'),
                    _line(l10n.translate('totalVapeCostAfterFidelity') ?? 'Total Vape Cost (After Fidelity)', '€${item.totalVapeCostAfterFidelity}'),
                    _line(l10n.translate('eurosSaved') ?? 'Euros Saved', '€${item.eurosSavedVsCig}'),
                    _line(l10n.translate('createdAt') ?? 'Created At', item.createdAt ?? '—'),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => VapeCalculationDetailScreen(saving: item)),
                        ),
                        child: Text(
                          l10n.translate('view') ?? 'View',
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
          Text(value, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
