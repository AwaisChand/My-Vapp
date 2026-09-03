import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lim_crm/models/vape_saving_model/vape_saving_model.dart';
import 'package:lim_crm/res/app_localization.dart';
import 'package:lim_crm/res/portal_ui.dart';
import 'package:lim_crm/utils/app_colors.dart';
import 'package:lim_crm/view_models/vape_savings_view_model/vape_savings_view_model.dart';
import 'package:provider/provider.dart';

import 'vapofumeur_record_screen.dart';

class VapofumeurHistoryScreen extends StatefulWidget {
  final bool embedded;

  const VapofumeurHistoryScreen({super.key, this.embedded = false});

  @override
  State<VapofumeurHistoryScreen> createState() => _VapofumeurHistoryScreenState();
}

class _VapofumeurHistoryScreenState extends State<VapofumeurHistoryScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHistory());
  }

  Future<void> _loadHistory() async {
    await context.read<VapeSavingsViewModel>().loadSlipHistory();
  }

  Future<void> _openRecordScreen() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const VapofumeurRecordScreen()),
    );
    if (saved == true && mounted) {
      await _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: widget.embedded
          ? null
          : AppBar(
              title: Text(l10n.translate('vapofumeur') ?? 'Vapofumeur'),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openRecordScreen,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          l10n.translate('newSlipRecord') ?? 'New slip',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.embedded)
              PortalUi.pageHeader(
                context: context,
                title: l10n.translate('vapofumeurHistoryTitle') ?? 'Vapofumeur — History',
                subtitle: l10n.translate('vapofumeurHistorySubtitle') ??
                    'Your saved slips appear below. Use the table to search and sort.',
                icon: Icons.smoking_rooms_rounded,
              ),
            Expanded(
              child: Consumer<VapeSavingsViewModel>(
                builder: (context, vm, _) {
                  final stats = vm.slipHistory?.wasteStats;
                  final items = vm.slipHistory?.items ?? [];
                  final filtered = _search.trim().isEmpty
                      ? items
                      : items.where((slip) {
                          final query = _search.toLowerCase();
                          return '${slip.slipDate} ${slip.slipTime} ${slip.cigarettesCount} ${slip.totalAmount}'
                              .toLowerCase()
                              .contains(query);
                        }).toList();

                  if (vm.loading && items.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return RefreshIndicator(
                    onRefresh: _loadHistory,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: EdgeInsets.fromLTRB(20, widget.embedded ? 8 : 20, 20, 100),
                      children: [
                        if (!widget.embedded) ...[
                          Text(
                            l10n.translate('vapofumeurHistoryTitle') ?? 'Vapofumeur — History',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 20),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.translate('vapofumeurHistorySubtitle') ??
                                'Your saved slips appear below. Use the table to search and sort.',
                            style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                        ],
                if (stats != null) ...[
                  _statCard(
                    l10n.translate('wasteByDay') ?? 'Waste by day',
                    '€${stats.day.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 10),
                  _statCard(
                    l10n.translate('wasteByMonth') ?? 'Waste by month',
                    '€${stats.month.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 10),
                  _statCard(
                    l10n.translate('wasteByYear') ?? 'Waste by year',
                    '€${stats.year.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 20),
                ],
                TextField(
                  onChanged: (value) => setState(() => _search = value),
                  decoration: InputDecoration(
                    hintText: l10n.translate('search') ?? 'Search',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: AppColors.cardBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.translate('slipHistory') ?? 'Slip history',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 18),
                ),
                const SizedBox(height: 12),
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      l10n.translate('noSlips') ?? 'No slip records yet.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: AppColors.textMuted),
                    ),
                  )
                else
                      ...filtered.asMap().entries.map(
                            (entry) => _slipTile(entry.key + 1, entry.value),
                          ),
                      if (filtered.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '1 - ${filtered.length} / ${filtered.length}',
                            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String amount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: PortalUi.cardDecoration(radius: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }

  Widget _slipTile(int index, SlipItem slip) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: PortalUi.cardDecoration(radius: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: GoogleFonts.poppins(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slip.slipDate ?? '—',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                ),
                Text(
                  slip.slipTime ?? '',
                  style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '${l10n.translate('numberOfCigarettes') ?? 'Number of cigarettes'}: ${slip.cigarettesCount ?? 0}',
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
                Text(
                  '${l10n.translate('totalAmount') ?? 'Total amount'}: €${slip.totalAmount ?? '0.00'}',
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Text(
            '€${slip.totalAmount ?? '0.00'}',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w800,
              color: AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}
