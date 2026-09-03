import 'package:flutter/material.dart';
import 'package:lim_crm/screens/BottomNavBar/bottom_nav_bar_screens/tab_screens/all_screen.dart';
import 'package:lim_crm/screens/BottomNavBar/bottom_nav_bar_screens/tab_screens/coupons_screen.dart';
import 'package:lim_crm/screens/BottomNavBar/bottom_nav_bar_screens/tab_screens/offer_screen.dart';

import '../../../res/app_localization.dart';
import '../../../res/portal_ui.dart';
import '../../../utils/app_colors.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key, this.initialTabIndex = 0, this.embedded = false});
  final int initialTabIndex;
  final bool embedded;

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = [
      l10n.translate('all') ?? 'All',
      l10n.translate('coupons') ?? 'Coupons',
      l10n.translate('offers') ?? 'Offers',
    ];

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PortalUi.pageHeader(
              context: context,
              title: l10n.translate('offers') ?? 'Offers',
              subtitle: l10n.translate('offersSubtitle') ??
                  'Discover amazing deals and exclusive offers',
              icon: Icons.card_giftcard_rounded,
              showBack: !widget.embedded,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: PortalUi.pillTabs(controller: _tabController, labels: tabs),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  AllScreen(),
                  CouponsScreen(),
                  OfferScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
