import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lim_crm/res/app_localization.dart';
import 'package:lim_crm/res/components/user_avatar.dart';
import 'package:lim_crm/res/portal_ui.dart';
import 'package:lim_crm/screens/account/language_screen.dart';
import 'package:lim_crm/screens/auth_screens/settings_screen/settings_screen.dart';
import 'package:lim_crm/screens/auth_screens/user_screen/user_screen.dart';
import 'package:lim_crm/utils/app_colors.dart';
import 'package:lim_crm/view_models/auth_view_model/auth_view_model.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final l10n = AppLocalizations.of(context)!;
    final name = auth.user?.name ?? 'Member';
    final locale = Localizations.localeOf(context).languageCode;
    final languageSubtitle = locale == 'fr' ? 'Français' : 'English';

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PortalUi.pageHeader(
                context: context,
                title: l10n.translate('profile') ?? 'Profile',
                subtitle: l10n.translate('profileSubtitle') ??
                    'Manage your account settings and preferences',
                icon: Icons.person_rounded,
                showBack: Navigator.of(context).canPop(),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: PortalUi.heroDecoration(radius: 16),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const UserScreen()),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            UserAvatar(user: auth.user, size: 88, borderWidth: 3),
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        l10n.translate('customerRole') ?? 'Customer',
                        style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.85)),
                      ),
                      Text(
                        auth.user?.email ?? '',
                        style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.8)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _menuTile(
                      context,
                      icon: Icons.person_outline,
                      color: AppColors.navProfile,
                      title: l10n.translate('profile') ?? 'Profile',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const UserScreen()),
                      ),
                    ),
                    _menuTile(
                      context,
                      icon: Icons.settings_outlined,
                      color: AppColors.primary,
                      title: l10n.translate('settings') ?? 'Settings',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      ),
                    ),
                    _menuTile(
                      context,
                      icon: Icons.language,
                      color: AppColors.navCashback,
                      title: l10n.translate('language') ?? 'Language',
                      subtitle: languageSubtitle,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LanguageScreen()),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _menuTile(
                      context,
                      icon: Icons.logout,
                      color: AppColors.danger,
                      title: l10n.translate('logout') ?? 'Logout',
                      onTap: () => auth.logoutApi(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuTile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: PortalUi.cardDecoration(radius: 14),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        subtitle: subtitle != null
            ? Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted))
            : null,
        trailing: Icon(Icons.chevron_right, color: AppColors.textSubtle),
      ),
    );
  }
}
