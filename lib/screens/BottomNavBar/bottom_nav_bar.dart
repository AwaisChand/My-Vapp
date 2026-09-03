import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../res/app_localization.dart';
import '../../res/components/customer_shell.dart';
import '../../res/components/customer_sidebar.dart';
import '../../view_models/bottom_nav_view_model/bottom_nav_view_model.dart';
import '../../utils/app_colors.dart';
import '../cashback/cashback_screen.dart';
import '../vape_calculator/vape_calculator_screens/vape_calculator_dashboard_screen.dart';
import '../vape_calculator/vape_calculator_screens/vapofumeur_history_screen.dart';
import 'bottom_nav_bar_screens/home_screen.dart';
import 'bottom_nav_bar_screens/offers_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = const [
    CashbackScreen(),
    OffersScreen(initialTabIndex: 0, embedded: true),
    HomeScreen(),
    VapeCalculatorDashboardScreen(embedded: true),
    VapofumeurHistoryScreen(embedded: true),
  ];

  static const _iconColors = [
    AppColors.navCashback,
    AppColors.navOffers,
    AppColors.navHome,
    AppColors.navVape,
    AppColors.warning,
  ];

  static const _icons = [
    Icons.account_balance_wallet_rounded,
    Icons.card_giftcard_rounded,
    Icons.home_rounded,
    Icons.calculate_rounded,
    Icons.smoking_rooms_rounded,
  ];

  static const _labelKeys = [
    'cash',
    'offer',
    'home',
    'economy',
    'vapofumeur',
  ];

  static const _labelFallbacks = [
    'Cashback',
    'Offers',
    'Dashboard',
    'Vape Calculator',
    'Vapofumeur',
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<BottomNavViewModel>();
    final selectedIndex = nav.selectedIndex;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.scaffoldBg,
      drawer: const CustomerSidebar(),
      body: CustomerShell(
        openDrawer: () => _scaffoldKey.currentState?.openDrawer(),
        child: IndexedStack(index: selectedIndex, children: _screens),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          border: Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_labelKeys.length, (index) {
                final selected = selectedIndex == index;
                final label = l10n.translate(_labelKeys[index]) ?? _labelFallbacks[index];

                return Expanded(
                  child: GestureDetector(
                    onTap: () => context.read<BottomNavViewModel>().selectTab(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                      decoration: BoxDecoration(
                        gradient: selected ? AppColors.primaryGradient : null,
                        color: selected ? null : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: selected ? AppColors.navActiveShadow : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _icons[index],
                            color: selected ? Colors.white : _iconColors[index],
                            size: 22,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: selected ? Colors.white : AppColors.textMuted,
                              fontSize: 9.5,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

