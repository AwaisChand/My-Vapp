import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lim_crm/res/app_localization.dart';
import 'package:lim_crm/res/components/app_button.dart';
import 'package:lim_crm/res/portal_ui.dart';
import 'package:provider/provider.dart';

import '../../../res/components/app_text_field.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/utils.dart';
import '../../../view_models/auth_view_model/auth_view_model.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, this.email});

  final String? email;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.email != null) {
      emailController.text = widget.email!;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: PortalUi.cardDecoration(radius: 14),
                  child: Text(
                    emailController.text,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: passwordController,
                  hintText: l10n.translate('password') ?? 'Password',
                  textInputType: TextInputType.visiblePassword,
                  isPassword: true,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: confirmPasswordController,
                  hintText: l10n.translate('confirmPassword') ?? 'Confirm Password',
                  textInputType: TextInputType.visiblePassword,
                  isPassword: true,
                ),
                const SizedBox(height: 24),
                AppButton(
                  btnText: l10n.translate('resetPassword') ?? 'Reset Password',
                  isLoading: auth.isLoading,
                  onPressed: () {
                    if (emailController.text.isEmpty) {
                      Utils.toastMessage(l10n.translate('pleaseEnterEmail') ?? 'Please Enter Email');
                    } else if (passwordController.text.isEmpty) {
                      Utils.toastMessage(l10n.translate('pleaseEnterNewPassword') ?? 'Please enter a new password.');
                    } else if (passwordController.text.length < 8) {
                      Utils.toastMessage(l10n.translate('newPasswordMin8') ?? 'New password must be at least 8 characters.');
                    } else if (passwordController.text != confirmPasswordController.text) {
                      Utils.toastMessage(l10n.translate('newPasswordMismatch') ?? 'New password and confirmation do not match.');
                    } else {
                      auth.resetPasswordApi(context, {
                        'email': emailController.text.trim(),
                        'password': passwordController.text,
                        'password_confirmation': confirmPasswordController.text,
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
