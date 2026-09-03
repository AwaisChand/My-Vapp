import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../res/components/app_button.dart';
import '../../../res/components/app_text_field.dart';
import '../../../res/components/brand_logo.dart';
import '../../../res/portal_ui.dart';
import '../../../screens/auth_screens/verify_email_screen/verify_email_screen.dart';
import '../../../utils/app_colors.dart';
import '../../../view_models/auth_view_model/auth_view_model.dart';
import '../../../res/app_localization.dart';
import '../../../res/components/language_switcher.dart';
import '../../../utils/utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRemembered();
  }

  Future<void> _loadRemembered() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool('remember_me') ?? false;
    final email = prefs.getString('remembered_email') ?? '';
    if (!mounted) return;
    setState(() {
      _rememberMe = remember;
      if (remember && email.isNotEmpty) {
        emailController.text = email;
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<AuthViewModel>(
      builder: (context, auth, _) {
        return Scaffold(
          backgroundColor: AuthScreenBackground.bottomColor,
          body: AuthScreenBackground(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.language, color: AppColors.primary, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                l10n.translate('language') ?? 'Language',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              const LanguageSwitcher(),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const BrandLogo(size: 120, showAura: false),
                          const SizedBox(height: 20),
                          Text(
                            'MY Vapp',
                            style: GoogleFonts.poppins(
                              color: AppColors.primary,
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.translate('discoverMyVapp') ??
                                'Discover MyVapp The Unique Application',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _bullet(l10n.translate('exclusiveMemberBenefits') ?? 'Exclusive member benefits'),
                          _bullet(l10n.translate('trackYourSavings') ?? 'Track your savings'),
                          _bullet(l10n.translate('exclusiveTips') ?? 'Exclusive tips'),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: PortalUi.cardDecoration(radius: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.translate('welcomeBack') ?? 'Welcome Back',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 22,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.translate('signInToAccount') ?? 'Sign in to your account',
                                  style: PortalUi.pageSubtitle(context),
                                ),
                                const SizedBox(height: 20),
                                AppTextField(
                                  controller: emailController,
                                  hintText: l10n.translate('emailAddress') ?? 'Email Address',
                                  textInputType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 14),
                                AppTextField(
                                  controller: passwordController,
                                  hintText: l10n.translate('password') ?? 'Password',
                                  textInputType: TextInputType.visiblePassword,
                                  isPassword: true,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      activeColor: AppColors.primary,
                                      onChanged: (v) => setState(() => _rememberMe = v ?? false),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => _rememberMe = !_rememberMe),
                                        child: Text(
                                          l10n.translate('rememberMe') ?? 'Remember me',
                                          style: GoogleFonts.poppins(fontSize: 13),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                AppButton(
                                  btnText: l10n.translate('login') ?? 'Sign in to MY Vapp',
                                  isLoading: auth.isLoading,
                                  onPressed: () {
                                    if (emailController.text.isEmpty) {
                                      Utils.toastMessage(
                                        l10n.translate('pleaseEnterEmail') ?? 'Please Enter Email',
                                      );
                                    } else if (passwordController.text.length < 8) {
                                      Utils.toastMessage(
                                        l10n.translate('pleaseEnter8DigitPassword') ??
                                            'Please Enter 8 digit password',
                                      );
                                    } else {
                                      auth.loginApi(
                                        context,
                                        {
                                          'email': emailController.text.trim(),
                                          'password': passwordController.text,
                                        },
                                        rememberMe: _rememberMe,
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => VerifyEmailScreen()),
                                  ),
                                  child: Text(
                                    l10n.translate('forgotYourPassword') ?? 'Forgot your password?',
                                    style: GoogleFonts.poppins(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              5,
                              (_) => const Icon(Icons.star, color: Color(0xFFFBBF24), size: 16),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.translate('trustedByThousands') ??
                                'Trusted by thousands of vape customers',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
