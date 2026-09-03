import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lim_crm/res/app_assets.dart';
import 'package:lim_crm/res/app_localization.dart';
import 'package:lim_crm/screens/account/language_screen.dart';
import 'package:lim_crm/screens/auth_screens/user_screen/user_screen.dart';
import 'package:lim_crm/utils/app_colors.dart';
import 'package:lim_crm/view_models/bottom_nav_view_model/bottom_nav_view_model.dart';
import 'package:provider/provider.dart';

class CustomerSidebar extends StatelessWidget {
  const CustomerSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selected = context.watch<BottomNavViewModel>().selectedIndex;

    return Drawer(
      backgroundColor: const Color(0xFFF7F8FC),
      width: 300,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  AppAssets.appLogo,
                  width: 72,
                  height: 72,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            _GroupLabel(l10n.translate('overview') ?? 'Overview'),
            _NavTile(
              selected: selected == BottomNavIndex.home,
              icon: Icons.home_rounded,
              iconColor: const Color(0xFFF9A8D4),
              label: l10n.translate('home') ?? 'Dashboard',
              onTap: () => _selectTab(context, BottomNavIndex.home),
            ),
            _NavTile(
              selected: selected == BottomNavIndex.cash,
              icon: Icons.credit_card_rounded,
              iconColor: AppColors.navCashback,
              label: l10n.translate('cash') ?? 'Cashback',
              onTap: () => _selectTab(context, BottomNavIndex.cash),
            ),
            const SizedBox(height: 16),
            _GroupLabel(l10n.translate('activity') ?? 'Activity'),
            _NavTile(
              selected: selected == BottomNavIndex.offer,
              icon: Icons.card_giftcard_rounded,
              iconColor: AppColors.navOffers,
              label: l10n.translate('offer') ?? 'Offers',
              onTap: () => _selectTab(context, BottomNavIndex.offer),
            ),
            _NavTile(
              selected: selected == BottomNavIndex.economy,
              icon: Icons.calculate_rounded,
              iconColor: AppColors.navVape,
              label: l10n.translate('economy') ?? 'Vape Calculator',
              onTap: () => _selectTab(context, BottomNavIndex.economy),
            ),
            _NavTile(
              selected: selected == BottomNavIndex.vapofumeur,
              icon: Icons.smoking_rooms_rounded,
              iconColor: AppColors.navVape,
              label: l10n.translate('vapofumeur') ?? 'Vapofumeur',
              onTap: () => _selectTab(context, BottomNavIndex.vapofumeur),
            ),
            const SizedBox(height: 16),
            _GroupLabel(l10n.translate('account') ?? 'Account'),
            _NavTile(
              selected: false,
              icon: Icons.person_rounded,
              iconColor: AppColors.navProfile,
              label: l10n.translate('profile') ?? 'Profile',
              onTap: () => _push(context, const UserScreen()),
            ),
            _NavTile(
              selected: false,
              icon: Icons.public_rounded,
              iconColor: AppColors.info,
              label: l10n.translate('language') ?? 'Language',
              onTap: () => _push(context, const LanguageScreen()),
            ),
          ],
        ),
      ),
    );
  }

  void _selectTab(BuildContext context, int index) {
    Navigator.of(context).pop();
    context.read<BottomNavViewModel>().selectTab(index);
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}

class _GroupLabel extends StatelessWidget {
  final String text;
  const _GroupLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.1,
          color: const Color(0xFF94A3B8),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const _NavTile({
    required this.selected,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              gradient: selected ? AppColors.primaryGradient : null,
              borderRadius: BorderRadius.circular(14),
              boxShadow: selected ? AppColors.navActiveShadow : null,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 22,
                    color: selected ? Colors.white : iconColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                        color: selected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
