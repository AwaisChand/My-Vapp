import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lim_crm/res/app_localization.dart';
import 'package:lim_crm/screens/vape_calculator/vape_calculator_screens/vapofumeur_history_screen.dart';
import 'package:lim_crm/screens/vape_calculator/vape_calculator_screens/vape_calculator_dashboard_screen.dart';
import 'package:lim_crm/utils/app_colors.dart';
import 'package:lim_crm/view_models/home_view_model/home_view_model.dart';
import 'package:lim_crm/view_models/vape_savings_view_model/vape_savings_view_model.dart';
import 'package:provider/provider.dart';

class VapofumeurRecordScreen extends StatefulWidget {
  const VapofumeurRecordScreen({super.key});

  @override
  State<VapofumeurRecordScreen> createState() => _VapofumeurRecordScreenState();
}

class _VapofumeurRecordScreenState extends State<VapofumeurRecordScreen> {
  final _countController = TextEditingController(text: '1');
  DateTime _slipDate = DateTime.now();
  TimeOfDay _slipTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _countController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VapeSavingsViewModel>().loadHistory();
    });
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  double _unitPrice(VapeSavingsViewModel vm, HomeViewModel home) {
    final fromCalc = double.tryParse(vm.latest?.cigUnitPrice ?? '') ?? 0;
    if (fromCalc > 0) return fromCalc;
    return home.dashboard?.latestVapeSaving?.cigUnitPrice ?? 0;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _slipDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _slipDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _slipTime);
    if (picked != null) setState(() => _slipTime = picked);
  }

  Future<void> _submit(double unitPrice) async {
    final l10n = AppLocalizations.of(context)!;
    if (unitPrice <= 0) {
      UtilsToast.needCalculation(context, l10n);
      return;
    }
    final count = int.tryParse(_countController.text) ?? 0;
    if (count < 1) return;

    final time =
        '${_slipTime.hour.toString().padLeft(2, '0')}:${_slipTime.minute.toString().padLeft(2, '0')}';
    final date =
        '${_slipDate.year}-${_slipDate.month.toString().padLeft(2, '0')}-${_slipDate.day.toString().padLeft(2, '0')}';

    final ok = await context.read<VapeSavingsViewModel>().saveSlip(context, {
      'slip_date': date,
      'slip_time': time,
      'cigarettes_count': count,
    });

    if (ok && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: Text(l10n.translate('vapofumeur') ?? 'Vapofumeur'),
      ),
      body: Consumer2<VapeSavingsViewModel, HomeViewModel>(
        builder: (context, vm, home, _) {
          final unitPrice = _unitPrice(vm, home);
          final count = int.tryParse(_countController.text) ?? 0;
          final total = unitPrice * (count < 0 ? 0 : count);
          final hasCalc = unitPrice > 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.translate('vapofumeur') ?? 'Vapofumeur',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.translate('slipFormSubtitle') ??
                            'Record date, time, number of cigarettes and total amount for each slip.',
                        style: GoogleFonts.poppins(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VapofumeurHistoryScreen()),
                    ),
                    child: Text(l10n.translate('slipHistoryLink') ?? "Historique d'enregistrements"),
                  ),
                ),
                if (!hasCalc)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.translate('needVapeCalculationFirst') ??
                              'You need a saved vape calculation first. Total amount uses the cigarette unit price from your latest calculation.',
                          style: GoogleFonts.poppins(fontSize: 13),
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const VapeCalculatorDashboardScreen(),
                            ),
                          ),
                          child: Text(l10n.translate('vapeCalc') ?? 'Vape Calculator'),
                        ),
                      ],
                    ),
                  ),
                _field(
                  label: l10n.translate('numberOfCigarettes') ?? 'Number of cigarettes',
                  child: TextField(
                    controller: _countController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _field(
                        label: l10n.translate('date') ?? 'Date',
                        child: InkWell(
                          onTap: _pickDate,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              '${_slipDate.day.toString().padLeft(2, '0')}/${_slipDate.month.toString().padLeft(2, '0')}/${_slipDate.year}',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(
                        label: l10n.translate('time') ?? 'Time',
                        child: InkWell(
                          onTap: _pickTime,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              _slipTime.format(context),
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _field(
                  label: l10n.translate('totalAmount') ?? 'Total amount',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      hasCalc ? '€${total.toStringAsFixed(2)}' : '—',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${l10n.translate('unitPriceLatestCalc') ?? 'Unit price (latest calculation)'}: ${hasCalc ? '€${unitPrice.toStringAsFixed(4)}' : '—'} × ${l10n.translate('numberOfCigarettes') ?? 'Number of cigarettes'}.',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: vm.loading || !hasCalc ? null : () => _submit(unitPrice),
                    child: vm.loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(l10n.translate('save') ?? 'Save'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _field({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: child,
        ),
      ],
    );
  }
}

class UtilsToast {
  static void needCalculation(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.translate('needVapeCalculationFirst') ??
              'You need a saved vape calculation first. Total amount uses the cigarette unit price from your latest calculation.',
        ),
      ),
    );
  }
}
