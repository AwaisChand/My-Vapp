import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lim_crm/models/dashboard_model/dashboard_model.dart';
import 'package:lim_crm/res/components/customer_shell.dart';
import 'package:lim_crm/res/components/dashboard_cashback_hero.dart';
import 'package:lim_crm/res/components/dashboard_chart_filters.dart';
import 'package:lim_crm/res/components/dashboard_line_chart.dart';
import 'package:lim_crm/res/components/dashboard_savings_row.dart';
import 'package:lim_crm/res/components/user_avatar.dart';
import 'package:lim_crm/screens/BottomNavBar/bottom_nav_bar_screens/offers_screen.dart';
import 'package:lim_crm/screens/auth_screens/user_screen/user_screen.dart';
import 'package:lim_crm/view_models/auth_view_model/auth_view_model.dart';
import 'package:lim_crm/view_models/home_view_model/home_view_model.dart';
import 'package:lim_crm/view_models/promotions_view_model/promotions_view_model.dart';
import 'package:provider/provider.dart';
import '../../../res/app_localization.dart';
import 'package:lim_crm/screens/get_single_newsletter/get_single_newsletter_screen.dart';
import '../../../res/components/birthday_coupon_popup.dart';
import '../../../res/components/promotion_card.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/media_url.dart';
import '../../../utils/promotion_display.dart';
import '../../../utils/utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final home = context.read<HomeViewModel>();
      final promo = context.read<PromotionsViewModel>();
      await home.loadHomeData(context);
      await promo.checkBirthday(context);
      if (mounted && promo.checkBirthdayModel?.daysRemaining == 0) {
        await BirthdayCouponPopup.show(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final promo = context.watch<PromotionsViewModel>();
    final userName = auth.user?.name?.split(' ').first ?? '';
    final l10n = AppLocalizations.of(context)!;
    final greeting =
        (l10n.translate('greeting') ?? 'Hi, {name}').replaceAll('{name}', userName);

    return Consumer<HomeViewModel>(
      builder: (context, home, _) {
        final snapshot = home.dashboard?.snapshot;
        final promotions = home.dashboard?.dashboardPromotions ?? [];
        final passportChart = home.filteredPassportChart;
        final ordersChart = home.filteredOrdersChart;

        return Scaffold(
          backgroundColor: AppColors.scaffoldBg,
          body: home.redeemLoading && snapshot == null
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => home.loadHomeData(context),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      SliverToBoxAdapter(
                        child: _header(context, auth, home, greeting, l10n),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const DashboardCashbackHero(),
                              const SizedBox(height: 20),
                              const DashboardSavingsRow(),
                              const SizedBox(height: 20),
                              DashboardPanel(
                                title: l10n.translate('progressPassport') ?? 'Progress passport',
                                icon: Icons.compass_calibration_outlined,
                                trailing: DashboardChartFilters(
                                  years: home.passportYears,
                                  selectedYear: home.passportChartYear,
                                  selectedMonth: home.passportChartMonth,
                                  onYearChanged: home.setPassportChartYear,
                                  onMonthChanged: home.setPassportChartMonth,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.translate('nicotineMg') ?? 'Nicotine (mg)',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    DashboardLineChart(
                                      categories: passportChart.categories,
                                      values: passportChart.values,
                                      emptyMessage: l10n.translate('noNicotineData') ??
                                          'No nicotine data available for this month.',
                                      emptyExtra: l10n.translate('noEntriesForPeriod') ??
                                          'No entries for this period',
                                      tooltipValueLabel:
                                          l10n.translate('nicotineValue') ?? 'Nicotine value',
                                      tooltipDateLabel: l10n.translate('date') ?? 'Date',
                                      tooltipTimeLabel: l10n.translate('time') ?? 'Time',
                                      tooltipAverageLabel:
                                          l10n.translate('monthlyAverage') ?? 'Monthly average',
                                      showMonthlyAverage: home.passportChartMonth == 0,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              DashboardPanel(
                                title: l10n.translate('offers') ?? 'Offers',
                                icon: Icons.card_giftcard_outlined,
                                trailing: TextButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const OffersScreen(initialTabIndex: 0),
                                    ),
                                  ),
                                  child: Text(
                                    l10n.translate('viewAll') ?? 'View All',
                                    style: GoogleFonts.poppins(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                child: promotions.isEmpty
                                    ? Text(
                                        home.redeemLoading
                                            ? (l10n.translate('loadingPromotions') ??
                                                'Loading promotions...')
                                            : (l10n.translate('noPromotionsRightNow') ??
                                                'No promotions available right now.'),
                                        style: GoogleFonts.poppins(color: AppColors.textMuted),
                                      )
                                    : Column(
                                        children: promotions
                                            .take(5)
                                            .map((offer) => _offerTile(context, offer, l10n))
                                            .toList(),
                                      ),
                              ),
                              const SizedBox(height: 16),
                              DashboardPanel(
                                title: l10n.translate('myPurchases') ?? 'My Purchases',
                                icon: Icons.show_chart_rounded,
                                trailing: DashboardChartFilters(
                                  years: home.orderYears,
                                  selectedYear: home.ordersChartYear,
                                  selectedMonth: home.ordersChartMonth,
                                  onYearChanged: home.setOrdersChartYear,
                                  onMonthChanged: home.setOrdersChartMonth,
                                ),
                                child: DashboardLineChart(
                                  categories: ordersChart.categories,
                                  values: ordersChart.values,
                                  emptyMessage: l10n.translate('noPurchaseData') ??
                                      'No purchase data for this period.',
                                  emptyExtra: l10n.translate('noEntriesForPeriod') ??
                                      'No entries for this period',
                                  lineColor: AppColors.primary,
                                  valueSuffix: '€',
                                  asLineChart: true,
                                  yAxisTitle: l10n.translate('chartSales') ?? 'Sales',
                                  tooltipValueLabel: l10n.translate('chartSales') ?? 'Sales',
                                  tooltipDateLabel: l10n.translate('date') ?? 'Date',
                                ),
                              ),
                              if (promo.checkBirthdayModel?.daysRemaining == 0) ...[
                                const SizedBox(height: 16),
                                _birthdayCard(promo, l10n),
                              ],
                              const SizedBox(height: 20),
                              Text(
                                l10n.translate('newsLetter') ?? 'Newsletter',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                      if (home.newsLetter.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              home.redeemLoading
                                  ? (l10n.translate('fetchingNewsletters') ??
                                      'Fetching newsletters...')
                                  : (l10n.translate('noNewsLetter') ??
                                      'No newsletters at the moment.'),
                              style: GoogleFonts.poppins(color: AppColors.textMuted),
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final item = home.newsLetter[index];
                                return GestureDetector(
                                  onTap: () {
                                    final attachment = (item.attachmentUrl ?? '').trim();
                                    if (attachment.isEmpty) {
                                      Utils.toastMessage(
                                        l10n.translate('attachmentNotAvailable') ??
                                            'Attachment not available.',
                                      );
                                      return;
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => GetSingleNewsletterScreen(
                                          title: item.title ?? '',
                                          url: attachment,
                                          imageUrl: item.imageUrl,
                                          mediaType: item.mediaType,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: AppColors.cardBg,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        if ((item.imageUrl ?? '').isNotEmpty)
                                          CachedNetworkImage(
                                            imageUrl: MediaUrl.resolve(item.imageUrl),
                                            height: 140,
                                            fit: BoxFit.cover,
                                          ),
                                        Padding(
                                          padding: const EdgeInsets.all(14),
                                          child: Text(
                                            item.title ?? '',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              childCount: home.newsLetter.length,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _header(
    BuildContext context,
    AuthViewModel auth,
    HomeViewModel home,
    String greeting,
    AppLocalizations l10n,
  ) {
    final dashboardUser = home.dashboard?.user;
    final avatarUrl = dashboardUser?.avatarUrl ?? auth.user?.avatarUrl;
    final menuButton = CustomerShell.menuButton(context, color: Colors.white);

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: AppColors.brandShadow,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 12, 12),
          child: Row(
            children: [
              if (menuButton != null) menuButton,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      l10n.translate('dashboardSubtitle') ?? 'Your vape loyalty hub',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      l10n.translate('customerRole') ?? 'Customer',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              UserAvatar(
                user: auth.user,
                imageUrl: avatarUrl,
                name: dashboardUser?.name ?? auth.user?.name,
                size: 42,
                borderWidth: 2,
                backgroundColor: Colors.transparent,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserScreen()),
                ),
              ),
              IconButton(
                tooltip: l10n.translate('logout') ?? 'Logout',
                onPressed: () => auth.logoutApi(context),
                icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _offerTile(
    BuildContext context,
    DashboardPromotion offer,
    AppLocalizations l10n,
  ) {
    final icon = offer.isBirthday
        ? Icons.cake_outlined
        : offer.isCoupon
            ? Icons.local_offer_outlined
            : Icons.card_giftcard_outlined;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              offer.isBirthday
                  ? (l10n.translate('birthday') ?? 'Birthday')
                  : (offer.name ?? ''),
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () => PromotionDetailDialog.show(
              context,
              PromotionItem.fromDashboard(offer),
            ),
            child: Text(
              l10n.translate('viewOffer') ?? 'View Offer',
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _birthdayCard(PromotionsViewModel promo, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.cake_rounded, color: AppColors.accent, size: 36),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.translate('birthdayReward') ?? 'Birthday Reward',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w800),
                ),
                Text(
                  promo.birthday.map((b) => b.code).join(', '),
                  style: GoogleFonts.poppins(color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
