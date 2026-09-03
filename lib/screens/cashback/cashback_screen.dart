import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lim_crm/models/redeem_points_history_model/redeem_points_history_model.dart';
import 'package:lim_crm/res/app_localization.dart';
import 'package:lim_crm/res/components/customer_shell.dart';
import 'package:lim_crm/res/components/loyalty_banner.dart';
import 'package:lim_crm/res/portal_ui.dart';
import 'package:lim_crm/screens/BottomNavBar/bottom_nav_bar_screens/history_screen.dart';
import 'package:lim_crm/utils/app_colors.dart';
import 'package:lim_crm/view_models/home_view_model/home_view_model.dart';
import 'package:provider/provider.dart';

class CashbackScreen extends StatefulWidget {
  const CashbackScreen({super.key});

  @override
  State<CashbackScreen> createState() => _CashbackScreenState();
}

class _CashbackScreenState extends State<CashbackScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _historyFilter = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadHomeData(context);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<History> _filteredHistory(List<History> history) {
    if (_historyFilter == 0) return history;
    final days = _historyFilter == 1 ? 7 : 30;
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return history.where((item) {
      final raw = item.rawDate ?? item.displayDate;
      if (raw == null || raw.isEmpty) return false;
      final date = DateTime.tryParse(raw);
      return date != null && !date.isBefore(cutoff);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
              child: Row(
                children: [
                  if (CustomerShell.menuButton(context) != null)
                    CustomerShell.menuButton(context)!,
                  Icon(Icons.credit_card_rounded, color: AppColors.primary, size: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.translate('myCashback') ?? 'My Cashback',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: PortalUi.pillTabs(
                controller: _tabController,
                labels: [
                  l10n.translate('transactions') ?? 'Transactions',
                  l10n.translate('purchaseHistory') ?? 'Orders',
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Consumer<HomeViewModel>(
                builder: (context, vm, _) {
                  if (vm.redeemLoading && vm.history.isEmpty && vm.dashboard == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _TransactionsPage(
                        vm: vm,
                        historyFilter: _historyFilter,
                        onFilterChanged: (value) => setState(() => _historyFilter = value),
                        filteredHistory: _filteredHistory(vm.history),
                      ),
                      const HistoryScreen(embedded: true),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionsPage extends StatelessWidget {
  final HomeViewModel vm;
  final int historyFilter;
  final ValueChanged<int> onFilterChanged;
  final List<History> filteredHistory;

  const _TransactionsPage({
    required this.vm,
    required this.historyFilter,
    required this.onFilterChanged,
    required this.filteredHistory,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final model = vm.redeemPointsHistoryModel;
    final earned = model?.totalEarnedPoints ?? vm.dashboard?.snapshot?.totalEarnedCashback ?? 0;
    final redeemed = model?.totalRedeemedPoints ?? vm.dashboard?.snapshot?.totalRedeemedCashback ?? 0;
    final balance = model?.currentBalance ?? vm.dashboard?.snapshot?.currentBalance ?? 0;

    return RefreshIndicator(
      onRefresh: () => vm.loadHomeData(context),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const LoyaltyBanner(mode: LoyaltyBannerMode.cashback),
          const SizedBox(height: 24),
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                l10n.translate('transactionHistory') ?? 'Transaction History',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _HistoryFilterBar(selected: historyFilter, onChanged: onFilterChanged),
          const SizedBox(height: 16),
          _SummaryStatsGrid(
            earned: earned,
            redeemed: redeemed,
            balance: balance,
            transactions: filteredHistory.length,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.translate('transactionHistory') ?? 'Transaction History',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
              TextButton.icon(
                onPressed: () => vm.getRedeemPointsHistory(context),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(l10n.translate('refresh') ?? 'Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (vm.redeemLoading && filteredHistory.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  l10n.translate('loadingTransactionHistory') ?? 'Loading transaction history...',
                  style: GoogleFonts.poppins(color: AppColors.textMuted),
                ),
              ),
            )
          else if (vm.historyLoadFailed)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  l10n.translate('unableToLoadTransactionHistory') ??
                      'Unable to load transaction history.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: AppColors.textMuted),
                ),
              ),
            )
          else if (filteredHistory.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  historyFilter == 1
                      ? (l10n.translate('noTransactionsLast7') ??
                          'No transactions found for last 7 days.')
                      : historyFilter == 2
                          ? (l10n.translate('noTransactionsLast30') ??
                              'No transactions found for last 30 days.')
                          : (l10n.translate('noTransactionsFoundYet') ??
                              'No transactions found yet.'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: AppColors.textMuted),
                ),
              ),
            )
          else
            ...filteredHistory.map((item) {
              final isEarned = (item.type ?? '').toLowerCase() == 'earned';
              final typeLabel = isEarned
                  ? (l10n.translate('earned') ?? 'Earned')
                  : (l10n.translate('redeemed') ?? 'Redeemed');
              final description = (item.notes ?? '').trim().isNotEmpty
                  ? item.notes!
                  : (isEarned
                      ? (l10n.translate('cashbackEarned') ?? 'Cashback Earned')
                      : (l10n.translate('cashbackRedeemed') ?? 'Cashback Redeemed'));
              final statusRaw = (item.status ?? 'completed').toLowerCase();
              final statusLabel = statusRaw == 'pending'
                  ? (l10n.translate('pending') ?? 'Pending')
                  : (l10n.translate('completed') ?? 'Completed');
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: PortalUi.cardDecoration(radius: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l10n.translate('dateAndTime') ?? 'Date & Time'}: ${item.displayDate ?? item.rawDate ?? item.date ?? ''}',
                        style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${l10n.translate('type') ?? 'Type'}: $typeLabel',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          color: isEarned ? AppColors.success : AppColors.danger,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.translate('description') ?? 'Description'}: $description',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${l10n.translate('cashback') ?? 'Cashback'}: ${item.cashback ?? item.points ?? '0.00'}',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.translate('statusLabel') ?? 'Status'}: $statusLabel',
                        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              );
            }),
          if (filteredHistory.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                (l10n.translate('showingTransactions') ?? 'Showing :count transaction(s)')
                    .replaceAll(':count', '${filteredHistory.length}'),
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => onFilterChanged(0),
              child: Text(l10n.translate('clearFilters') ?? 'Clear Filters'),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryFilterBar extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _HistoryFilterBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = [
      l10n.translate('all') ?? 'All',
      l10n.translate('last7Days') ?? 'Last 7 Days',
      l10n.translate('last30Days') ?? 'Last 30 Days',
    ];

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: PortalUi.cardDecoration(radius: 14),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  onTap: () => onChanged(i),
                  borderRadius: BorderRadius.circular(999),
                  child: Ink(
                    decoration: selected == i
                        ? BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(999),
                          )
                        : null,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    child: Text(
                      labels[i],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected == i ? Colors.white : AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryStatsGrid extends StatelessWidget {
  final double earned;
  final double redeemed;
  final double balance;
  final int transactions;

  const _SummaryStatsGrid({
    required this.earned,
    required this.redeemed,
    required this.balance,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth >= 560 ? 4 : 2;
        final items = [
          _StatCardData(
            label: l10n.translate('totalEarned') ?? 'Total Earned',
            value: '€${earned.toStringAsFixed(2)}',
            icon: Icons.trending_up_rounded,
            bg: const Color(0xFFDCFCE7),
            fg: const Color(0xFF16A34A),
          ),
          _StatCardData(
            label: l10n.translate('totalRedeemed') ?? 'Total Redeemed',
            value: '€${redeemed.toStringAsFixed(2)}',
            icon: Icons.card_giftcard_rounded,
            bg: const Color(0xFFFCE7F3),
            fg: const Color(0xFFDB2777),
          ),
          _StatCardData(
            label: l10n.translate('currentBalance') ?? 'Current Balance',
            value: '€${balance.toStringAsFixed(2)}',
            icon: Icons.star_rounded,
            bg: const Color(0xFFFEF3C7),
            fg: const Color(0xFFD97706),
            meta: l10n.translate('updatedNow') ?? 'Updated now',
          ),
          _StatCardData(
            label: l10n.translate('transactions') ?? 'Transactions',
            value: '$transactions',
            icon: Icons.show_chart_rounded,
            bg: const Color(0xFFDBEAFE),
            fg: AppColors.info,
            meta: l10n.translate('totalRecorded') ?? 'Total recorded',
          ),
        ];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: crossCount == 4 ? 1.05 : 1.15,
          ),
          itemBuilder: (context, index) => _SummaryStatCard(data: items[index]),
        );
      },
    );
  }
}

class _StatCardData {
  final String label;
  final String value;
  final String? meta;
  final IconData icon;
  final Color bg;
  final Color fg;

  const _StatCardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.bg,
    required this.fg,
    this.meta,
  });
}

class _SummaryStatCard extends StatelessWidget {
  final _StatCardData data;

  const _SummaryStatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: PortalUi.cardDecoration(radius: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: data.bg, shape: BoxShape.circle),
            child: Icon(data.icon, color: data.fg, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            data.label.toUpperCase(),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            data.value,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          if (data.meta != null) ...[
            const SizedBox(height: 2),
            Text(
              data.meta!,
              style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}
