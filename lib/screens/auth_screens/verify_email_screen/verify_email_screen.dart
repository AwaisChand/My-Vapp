import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lim_crm/res/app_localization.dart';
import 'package:lim_crm/res/components/app_button.dart';
import 'package:lim_crm/res/components/app_text_field.dart';
import 'package:lim_crm/res/portal_ui.dart';
import 'package:lim_crm/utils/app_colors.dart';
import 'package:lim_crm/utils/utils.dart';
import 'package:provider/provider.dart';

import '../../../view_models/auth_view_model/auth_view_model.dart';

class VerifyEmailScreen extends StatelessWidget {
  VerifyEmailScreen({super.key});

  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<AuthViewModel>(
      builder: (context, auth, _) {
        return Scaffold(
          backgroundColor: AppColors.scaffoldBg,
          appBar: AppBar(
            title: Text(l10n.translate('resetPassword') ?? 'Reset Password'),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  l10n.translate('resetPassword') ?? 'Reset Password',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.translate('enterYourEmail') ?? 'Enter your email',
                  style: PortalUi.pageSubtitle(context),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  controller: emailController,
                  hintText: l10n.translate('emailAddress') ?? 'Email Address',
                  textInputType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                AppButton(
                  btnText: l10n.translate('sendPasswordResetLink') ?? 'Send Password Reset Link',
                  isLoading: auth.isLoading,
                  onPressed: () {
                    if (emailController.text.isEmpty) {
                      Utils.toastMessage(
                        l10n.translate('pleaseEnterEmail') ?? 'Please Enter Email',
                      );
                    } else {
                      auth.verifyEmailApi(context, {
                        'email': emailController.text.trim(),
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
