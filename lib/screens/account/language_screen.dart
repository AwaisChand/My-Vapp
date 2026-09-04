import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lim_crm/main.dart';
import 'package:lim_crm/res/app_localization.dart';
import 'package:lim_crm/res/portal_ui.dart';
import 'package:lim_crm/utils/app_colors.dart';
import 'package:lim_crm/utils/utils.dart';
import 'package:lim_crm/view_models/home_view_model/home_view_model.dart';
import 'package:provider/provider.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String? _selected;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selected ??= Localizations.localeOf(context).languageCode;
  }

  Future<void> _apply() async {
    final locale = _selected ?? 'en';
    final home = context.read<HomeViewModel>();
    MyApp.setLocale(context, Locale(locale));
    await home.syncLanguage(locale);
    if (!mounted) return;
    await home.loadHomeData(context);
    if (!mounted) return;
    Utils.toastMessage(
      AppLocalizations.of(context)!.translate('languageUpdated') ??
          'Language updated',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            PortalUi.pageHeader(
              context: context,
              title: l10n.translate('language') ?? 'Language',
              subtitle: l10n.translate('profileSubtitle') ??
                  'Manage your account settings and preferences',
              icon: Icons.language,
              showBack: true,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    decoration: PortalUi.cardDecoration(radius: 16),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.translate('languageAndRegion') ??
                              'Language & Region',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        RadioGroup<String>(
                          groupValue: _selected,
                          onChanged: (v) =>
                              setState(() => _selected = v ?? 'en'),
                          child: Column(
                            children: [
                              RadioListTile<String>(
                                value: 'en',
                                title: Text(
                                  l10n.translate('englishUS') ??
                                      'English (US)',
                                ),
                                subtitle: Text(
                                  l10n.translate('unitedStates') ??
                                      'United States',
                                ),
                                secondary: const Text(
                                  '🇺🇸',
                                  style: TextStyle(fontSize: 22),
                                ),
                              ),
                              RadioListTile<String>(
                                value: 'fr',
                                title: const Text('Français'),
                                subtitle: const Text('France'),
                                secondary: const Text(
                                  '🇫🇷',
                                  style: TextStyle(fontSize: 22),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: _apply,
                            child: Text(
                              l10n.translate('applyChanges') ??
                                  'Apply Changes',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
