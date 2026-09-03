import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lim_crm/main.dart';
import 'package:lim_crm/utils/app_colors.dart';
import 'package:lim_crm/view_models/home_view_model/home_view_model.dart';
import 'package:provider/provider.dart';

class LanguageSwitcher extends StatelessWidget {
  final bool lightOnDark;
  final bool syncToApi;

  const LanguageSwitcher({
    super.key,
    this.lightOnDark = false,
    this.syncToApi = false,
  });

  Future<void> _setLocale(BuildContext context, String code) async {
    if (Localizations.localeOf(context).languageCode == code) return;
    MyApp.setLocale(context, Locale(code));
    if (!syncToApi || !context.mounted) return;
    try {
      await context.read<HomeViewModel>().syncLanguage(code);
      if (context.mounted) {
        await context.read<HomeViewModel>().loadHomeData(context);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final current = Localizations.localeOf(context).languageCode;
    final border = lightOnDark ? Colors.white.withValues(alpha: 0.35) : AppColors.border;
    final bg = lightOnDark ? Colors.white.withValues(alpha: 0.12) : AppColors.cardBg;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _chip(context, 'EN', 'en', current == 'en'),
          _chip(context, 'FR', 'fr', current == 'fr'),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String label, String code, bool selected) {
    final selectedBg = lightOnDark ? Colors.white : AppColors.primary;
    final selectedFg = lightOnDark ? AppColors.primary : Colors.white;
    final idleFg = lightOnDark ? Colors.white : AppColors.textSecondary;

    return GestureDetector(
      onTap: () => _setLocale(context, code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? selectedBg : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? selectedFg : idleFg,
          ),
        ),
      ),
    );
  }
}
