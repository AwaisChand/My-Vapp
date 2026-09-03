import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lim_crm/screens/vape_calculator/vape_calculator_screens/view_history_screen.dart';
import 'package:lim_crm/utils/app_colors.dart';
import 'package:lim_crm/utils/vape_calculator_engine.dart';
import 'package:lim_crm/view_models/vape_savings_view_model/vape_savings_view_model.dart';
import 'package:provider/provider.dart';

import '../../../res/app_localization.dart';

class NewCalculationScreen extends StatefulWidget {
  const NewCalculationScreen({super.key});

  @override
  State<NewCalculationScreen> createState() => _NewCalculationScreenState();
}

class _NewCalculationScreenState extends State<NewCalculationScreen> {
  int _step = 0;
  DateTime? _firstDate;
  DateTime _todayDate = DateTime.now();

  final _packPrice = TextEditingController(text: '11.00');
  final _cigsPerPack = TextEditingController(text: '20');
  final _cigsPerDay = TextEditingController(text: '10');
  final _vapeUnitPrice = TextEditingController(text: '6.00');
  final _bottlesCount = TextEditingController(text: '1');
  final _freeBottles = TextEditingController(text: '0');
  final _daysPerBottle = TextEditingController(text: '30');
  final _fidelityPercent = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    for (final c in [
      _packPrice, _cigsPerPack, _cigsPerDay, _vapeUnitPrice,
      _bottlesCount, _freeBottles, _daysPerBottle, _fidelityPercent,
    ]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _packPrice.dispose();
    _cigsPerPack.dispose();
    _cigsPerDay.dispose();
    _vapeUnitPrice.dispose();
    _bottlesCount.dispose();
    _freeBottles.dispose();
    _daysPerBottle.dispose();
    _fidelityPercent.dispose();
    super.dispose();
  }

  VapeCalcResult get _result => VapeCalculatorEngine.calculate(
        firstDate: _firstDate,
        todayDate: _todayDate,
        packPrice: double.tryParse(_packPrice.text) ?? 0,
        cigsPerPack: int.tryParse(_cigsPerPack.text) ?? 1,
        cigsPerDay: int.tryParse(_cigsPerDay.text) ?? 0,
        vapeUnitPrice: double.tryParse(_vapeUnitPrice.text) ?? 0,
        bottlesCount: int.tryParse(_bottlesCount.text) ?? 0,
        freeBottles: int.tryParse(_freeBottles.text) ?? 0,
        daysPerBottle: int.tryParse(_daysPerBottle.text) ?? 0,
        fidelityPercent: double.tryParse(_fidelityPercent.text) ?? 0,
      );

  Future<void> _pickDate(bool isFirst) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFirst ? (_firstDate ?? DateTime.now()) : _todayDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isFirst) {
          _firstDate = picked;
        } else {
          _todayDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_firstDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('firstTimeVapostore') ?? 'Please select your first vapostore visit date')),
      );
      return;
    }

    final data = {
      'first_date':
          '${_firstDate!.year}-${_firstDate!.month.toString().padLeft(2, '0')}-${_firstDate!.day.toString().padLeft(2, '0')}',
      'today_date':
          '${_todayDate.year}-${_todayDate.month.toString().padLeft(2, '0')}-${_todayDate.day.toString().padLeft(2, '0')}',
      'pack_price': double.tryParse(_packPrice.text) ?? 0,
      'cigs_per_pack': int.tryParse(_cigsPerPack.text) ?? 1,
      'cigs_per_day': int.tryParse(_cigsPerDay.text) ?? 0,
      'vape_unit_price': double.tryParse(_vapeUnitPrice.text) ?? 0,
      'bottles_count': int.tryParse(_bottlesCount.text) ?? 0,
      'free_bottles': int.tryParse(_freeBottles.text) ?? 0,
      'days_per_bottle': int.tryParse(_daysPerBottle.text),
      'fidelity_percent': double.tryParse(_fidelityPercent.text) ?? 0,
    };

    final ok = await context.read<VapeSavingsViewModel>().saveCalculation(context, data);
    if (ok && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final steps = [
      l10n.translate('dates') ?? 'Dates',
      l10n.translate('cigarettes') ?? 'Cigarettes',
      l10n.translate('vape') ?? 'Vape',
    ];
    final french = Localizations.localeOf(context).languageCode == 'fr';
    final result = _result;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: Text(l10n.translate('myDailySavings') ?? 'My daily savings'),
        actions: [
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ViewHistoryScreen()),
            ),
            child: Text(l10n.translate('viewHistory') ?? 'View history'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Text(
              l10n.translate('compareCostsSubtitle') ??
                  'Compare costs - see how much you save with vape',
              style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 13),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: List.generate(steps.length, (i) {
                final active = i == _step;
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primarySoft : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: active ? AppColors.primary : AppColors.border),
                    ),
                    child: Text(
                      '${i + 1} ${steps[i]}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: active ? AppColors.primary : AppColors.textMuted,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                if (_step == 0) _datesStep(l10n, french, result),
                if (_step == 1) _cigarettesStep(l10n, result),
                if (_step == 2) _vapeStep(l10n, result),
                const SizedBox(height: 16),
                _livePanel(l10n, result),
                const SizedBox(height: 24),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (_step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _step--),
                      child: Text('‹ ${l10n.translate('previous') ?? 'Previous'}'),
                    ),
                  ),
                if (_step > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_step < 2) {
                        setState(() => _step++);
                      } else {
                        _save();
                      }
                    },
                    child: Text(
                      _step < 2
                          ? '${l10n.translate('next') ?? 'Next'} ›'
                          : (l10n.translate('finished') ?? 'Finished'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_step == 2)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(l10n.translate('saveCalculation') ?? 'Save calculation'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _datesStep(AppLocalizations l10n, bool french, VapeCalcResult result) {
    return _card(
      title: l10n.translate('dates') ?? 'Dates',
      icon: Icons.calendar_month,
      children: [
        _dateField(l10n.translate('firstTimeVapostore') ?? 'First time in vapostore cigarettes', _firstDate, () => _pickDate(true)),
        const SizedBox(height: 12),
        _dateField(l10n.translate('todayDate') ?? 'Today date', _todayDate, () => _pickDate(false)),
        const SizedBox(height: 16),
        Text(
          '${l10n.translate('totalDays') ?? 'Total Days'}: ${result.totalDays} ${l10n.translate('todayMinusFirstDate') ?? '(today - first date)'}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.primary),
        ),
        Text(
          '${l10n.translate('todayIs') ?? 'Today is:'} ${VapeCalculatorEngine.weekdayName(_todayDate, french: french)}',
          style: GoogleFonts.poppins(color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _cigarettesStep(AppLocalizations l10n, VapeCalcResult result) {
    return _card(
      title: l10n.translate('cigaretteSection') ?? 'CIGARETTE',
      icon: Icons.smoke_free,
      children: [
        _numField(l10n.translate('averagePackPrice') ?? 'Average price of a cigarette pack (€)', _packPrice),
        _numField(l10n.translate('cigarettesPerPack') ?? 'Number of cigarettes / pack', _cigsPerPack, isInt: true),
        _numField(l10n.translate('cigarettesPerDay') ?? 'Cigarettes smoked per day', _cigsPerDay, isInt: true),
        _readonly(l10n.translate('totalEurosSpentOnCigarettes') ?? 'Total euros spent on cigarettes', result.euro(result.totalCigCost)),
      ],
    );
  }

  Widget _vapeStep(AppLocalizations l10n, VapeCalcResult result) {
    return _card(
      title: l10n.translate('vape') ?? 'Vape',
      icon: Icons.eco,
      children: [
        _numField(l10n.translate('unitPricePerBottle') ?? 'Unit price per bottle (€)', _vapeUnitPrice),
        _numField(l10n.translate('numberOf10mlBottles') ?? 'Number of 10ml bottles', _bottlesCount, isInt: true),
        _numField(l10n.translate('numberOfFreeBottles') ?? 'Number of free bottles', _freeBottles, isInt: true),
        _numField(l10n.translate('dayDurationPerBottle') ?? 'Day duration per bottle', _daysPerBottle, isInt: true),
        _numField(l10n.translate('fidelityPercent') ?? 'Fidelity %', _fidelityPercent),
        _readonly(l10n.translate('unitPriceFinal') ?? 'Unit price final (fidelity + free)', result.euro(result.pricePerBottleInclFree)),
        _readonly(l10n.translate('totalPriceWithDiscount') ?? 'Total price with discount', result.euro(result.totalVapeCostAfterFidelity)),
        _readonly(l10n.translate('totalPriceVapeWithoutSave') ?? 'Total price vape without save', result.euro(result.totalRetailAllBottles)),
        _readonly(l10n.translate('freeBottleValue') ?? 'Free bottle value (€)', result.euro(result.freeBottleValue)),
      ],
    );
  }

  Widget _livePanel(AppLocalizations l10n, VapeCalcResult result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.translate('totalEconomies') ?? 'Total economies', style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 6),
          Text(
            '${result.savingPercent.toStringAsFixed(0)}% ${l10n.translate('savedVsCigarette') ?? 'saved vs cigarette'}',
            style: GoogleFonts.poppins(color: AppColors.primary, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.translate('savingSwitchMessage') ??
                'This is the saving you make by switching from cigarettes to vape.',
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          Text(l10n.translate('costs') ?? 'Costs', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          _mini(l10n.translate('cigaretteCost') ?? 'Cigarette cost', result.euro(result.totalCigCost)),
          _mini(l10n.translate('vapeCost') ?? 'Vape cost', result.euro(result.totalVapeCostAfterFidelity)),
          const SizedBox(height: 8),
          Text(l10n.translate('savingsDetails') ?? 'Savings details', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          _mini(l10n.translate('savingsPerDay') ?? 'Savings per day', result.euro(result.savingPerDay)),
          _mini(l10n.translate('savingsPerMonth30j') ?? 'Savings per month (~30j)', result.euro(result.savingPerMonth)),
          _mini(l10n.translate('savingsPerYear365j') ?? 'Savings per year (~365j)', result.euro(result.savingPerYear)),
        ],
      ),
    );
  }

  Widget _mini(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted)),
          Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _readonly(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.inputBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _card({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 18))),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _dateField(String label, DateTime? date, VoidCallback onTap) {
    final text = date == null
        ? 'jj/mm/aaaa'
        : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.inputBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(text, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _numField(String label, TextEditingController controller, {bool isInt = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: !isInt),
            decoration: const InputDecoration(),
          ),
        ],
      ),
    );
  }
}
