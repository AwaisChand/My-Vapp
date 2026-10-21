import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../res/app_localization.dart';
import '../../../res/portal_ui.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/utils.dart';

class VapeWebLinkTab extends StatelessWidget {
  const VapeWebLinkTab({
    super.key,
    required this.titleKey,
    required this.titleFallback,
    required this.subtitleKey,
    required this.subtitleFallback,
    required this.buttonKey,
    required this.buttonFallback,
    required this.pageUrl,
    required this.icon,
  });

  final String titleKey;
  final String titleFallback;
  final String subtitleKey;
  final String subtitleFallback;
  final String buttonKey;
  final String buttonFallback;
  final String pageUrl;
  final IconData icon;

  Future<void> _openWebPage() async {
    final uri = Uri.parse(pageUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    Utils.toastMessage('Unable to open link');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = l10n.translate(titleKey) ?? titleFallback;
    final subtitle = l10n.translate(subtitleKey) ?? subtitleFallback;
    final buttonLabel = l10n.translate(buttonKey) ?? buttonFallback;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PortalUi.pageHeader(
              context: context,
              title: title,
              subtitle: subtitle,
              icon: icon,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: PortalUi.cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(icon, color: AppColors.primary),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            height: 1.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 20),
                        PortalUi.gradientButton(
                          label: buttonLabel,
                          onPressed: _openWebPage,
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
