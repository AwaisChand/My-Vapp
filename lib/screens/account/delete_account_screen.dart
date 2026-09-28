import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lim_crm/res/app_localization.dart';
import 'package:lim_crm/res/app_url.dart';
import 'package:lim_crm/res/components/app_button.dart';
import 'package:lim_crm/res/components/app_text_field.dart';
import 'package:lim_crm/utils/app_colors.dart';
import 'package:lim_crm/utils/utils.dart';
import 'package:lim_crm/view_models/auth_view_model/auth_view_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final otpController = TextEditingController();
  bool _otpSent = false;
  bool _confirmed = false;

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  Future<void> _openGuide() async {
    final uri = Uri.parse(AppUrl.deleteAccountPageUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _sendOtp(AuthViewModel auth, String email, AppLocalizations l10n) async {
    if (!_confirmed) {
      Utils.toastMessage(
        l10n.translate('confirmDeleteWarning') ??
            'Please confirm that you understand this action is permanent.',
      );
      return;
    }
    if (email.isEmpty) {
      Utils.toastMessage(l10n.translate('pleaseEnterEmail') ?? 'Please Enter Email');
      return;
    }
    final ok = await auth.requestAccountDeletion(email);
    if (ok && mounted) setState(() => _otpSent = true);
  }

  Future<void> _verify(AuthViewModel auth, String email, AppLocalizations l10n) async {
    final otp = otpController.text.trim();
    if (otp.length != 4) {
      Utils.toastMessage(
        l10n.translate('enter4DigitOtp') ?? 'Please enter the 4-digit code from your email.',
      );
      return;
    }
    await auth.verifyAndDeleteAccount(context, email: email, otp: otp);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<AuthViewModel>(
      builder: (context, auth, _) {
        final email = auth.user?.email ?? '';

        return Scaffold(
          backgroundColor: AppColors.scaffoldBg,
          appBar: AppBar(
            title: Text(l10n.translate('deleteAccount') ?? 'Delete Account'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.translate('deleteAccountWarningTitle') ??
                          'This action is permanent',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w800,
                        color: AppColors.danger,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.translate('deleteAccountWarningBody') ??
                          'Deleting your account permanently removes your profile, cashback history, offers, and saved calculations. This cannot be undone.',
                      style: GoogleFonts.poppins(fontSize: 13, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.translate('accountEmail') ?? 'Account email',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Text(
                email.isEmpty ? '—' : email,
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _confirmed,
                activeColor: AppColors.danger,
                onChanged: (v) => setState(() => _confirmed = v ?? false),
                title: Text(
                  l10n.translate('deleteAccountConfirmCheck') ??
                      'I understand that deleting my account is permanent and irreversible.',
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 12),
              if (!_otpSent)
                AppButton(
                  btnText: l10n.translate('sendDeletionCode') ?? 'Send deletion code',
                  isLoading: auth.isLoading,
                  onPressed: () => _sendOtp(auth, email, l10n),
                )
              else ...[
                Text(
                  l10n.translate('deletionCodeSent') ??
                      'We sent a 4-digit code to your email. Enter it below to confirm deletion.',
                  style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMuted),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: otpController,
                  hintText: l10n.translate('enterOtp') ?? 'Enter OTP',
                  textInputType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                AppButton(
                  btnText: l10n.translate('confirmDeleteAccount') ?? 'Confirm delete account',
                  isLoading: auth.isLoading,
                  onPressed: () => _verify(auth, email, l10n),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: auth.resendLoading
                      ? null
                      : () => auth.resendAccountDeletionOtp(email),
                  child: Text(
                    l10n.translate('resendCode') ?? 'Resend code',
                    style: GoogleFonts.poppins(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              TextButton(
                onPressed: _openGuide,
                child: Text(
                  l10n.translate('readDeletionGuide') ?? 'Read full deletion guide',
                  style: GoogleFonts.poppins(
                    color: AppColors.textMuted,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
