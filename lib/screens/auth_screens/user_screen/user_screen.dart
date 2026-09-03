import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lim_crm/res/app_localization.dart';
import 'package:lim_crm/res/components/profile_avatar_editor.dart';
import 'package:lim_crm/utils/app_colors.dart';
import 'package:provider/provider.dart';

import '../../../res/components/app_button.dart';
import '../../../res/components/app_text_field.dart';
import '../../../utils/utils.dart';
import '../../../view_models/auth_view_model/auth_view_model.dart';
import '../../../view_models/home_view_model/home_view_model.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final companyController = TextEditingController();
  final countryController = TextEditingController();
  final codeController = TextEditingController();
  final descriptionController = TextEditingController();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  DateTime? _dob;
  File? _selectedAvatar;
  bool _filled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_filled) return;
    _filled = true;

    final auth = Provider.of<AuthViewModel>(context, listen: false);
    final user = auth.user;

    firstNameController.text = user?.firstName ?? _firstNameFromName(user?.name);
    lastNameController.text = user?.lastName ?? _lastNameFromName(user?.name);
    emailController.text = user?.email ?? '';
    phoneController.text = user?.phone ?? '';
    companyController.text = user?.companyName ?? '';
    countryController.text = user?.country ?? '';
    codeController.text = user?.code ?? '';
    descriptionController.text = user?.description ?? '';

    if (user?.dob != null && user!.dob!.isNotEmpty) {
      _dob = DateTime.tryParse(user.dob!);
    }
  }

  String _firstNameFromName(String? name) {
    if (name == null || name.isEmpty) return '';
    final parts = name.trim().split(' ');
    return parts.first;
  }

  String _lastNameFromName(String? name) {
    if (name == null || name.isEmpty) return '';
    final parts = name.trim().split(' ');
    if (parts.length <= 1) return '';
    return parts.sublist(1).join(' ');
  }

  String _displayDob(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _pickAvatar() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      setState(() => _selectedAvatar = File(picked.path));
    } catch (e) {
      Utils.toastMessage('Could not pick image');
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    companyController.dispose();
    countryController.dispose();
    codeController.dispose();
    descriptionController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
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
            title: Text(l10n.translate('profile') ?? 'Profile'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _incompleteAlert(context, l10n),
                ProfileAvatarEditor(
                  user: auth.user,
                  localImage: _selectedAvatar,
                  onTap: _pickAvatar,
                ),
                profileAvatarHint(
                  context,
                  l10n.translate('tapToChangePhoto') ?? 'Tap to change profile photo',
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.translate('profileDetails') ?? 'Profile Details',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.translate('customerRole') ?? 'customer',
                  style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: firstNameController,
                  hintText: l10n.translate('firstName') ?? 'First Name',
                  textInputType: TextInputType.name,
                ),
                const SizedBox(height: 15),
                AppTextField(
                  controller: lastNameController,
                  hintText: l10n.translate('lastName') ?? 'Last Name',
                  textInputType: TextInputType.name,
                ),
                const SizedBox(height: 15),
                AppTextField(
                  controller: emailController,
                  hintText: 'Email',
                  textInputType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),
                AppTextField(
                  controller: phoneController,
                  hintText: l10n.translate('phone') ?? 'Phone',
                  textInputType: TextInputType.phone,
                ),
                const SizedBox(height: 15),
                _dobField(l10n),
                const SizedBox(height: 15),
                AppTextField(
                  controller: companyController,
                  hintText: l10n.translate('companyName') ?? 'Company Name',
                  textInputType: TextInputType.name,
                ),
                const SizedBox(height: 15),
                AppTextField(
                  controller: countryController,
                  hintText: l10n.translate('country') ?? 'Country',
                  textInputType: TextInputType.name,
                ),
                const SizedBox(height: 15),
                AppTextField(
                  controller: codeController,
                  hintText: l10n.translate('code') ?? 'Code',
                  textInputType: TextInputType.text,
                ),
                const SizedBox(height: 15),
                AppTextField(
                  controller: descriptionController,
                  hintText: l10n.translate('description') ?? 'Description',
                  textInputType: TextInputType.text,
                  maxLines: 4,
                ),
                const SizedBox(height: 24),
                Text(
                  '${l10n.translate('changePassword') ?? 'Change Password'} (${l10n.translate('optional') ?? 'optional'})',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: currentPasswordController,
                  hintText: l10n.translate('currentPassword') ?? 'Current Password',
                  textInputType: TextInputType.visiblePassword,
                  isPassword: true,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: newPasswordController,
                  hintText: l10n.translate('newPassword') ?? 'New Password',
                  textInputType: TextInputType.visiblePassword,
                  isPassword: true,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: confirmPasswordController,
                  hintText: l10n.translate('confirmNewPassword') ?? 'Confirm New Password',
                  textInputType: TextInputType.visiblePassword,
                  isPassword: true,
                ),
                const SizedBox(height: 25),
                AppButton(
                  btnText: l10n.translate('saveChanges') ?? 'Save Changes',
                  isLoading: auth.isLoading,
                  onPressed: () => _save(context, auth, l10n),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _incompleteAlert(BuildContext context, AppLocalizations l10n) {
    final snapshot = context.watch<HomeViewModel>().dashboard?.snapshot;
    if (snapshot == null || snapshot.profileComplete) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFCD34D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.translate('incompleteProfile') ?? 'Incomplete Profile',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            (l10n.translate('accountPercentComplete') ??
                    'Your account is :percent% complete. Please fill in the remaining details.')
                .replaceAll(':percent', '${snapshot.profileCompletionPercent}'),
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          if (snapshot.missingProfileFields.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '${l10n.translate('missingFields') ?? 'Missing fields'}: ${snapshot.missingProfileFields.join(', ')}',
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _save(BuildContext context, AuthViewModel auth, AppLocalizations l10n) async {
    if (firstNameController.text.trim().isEmpty || lastNameController.text.trim().isEmpty) {
      Utils.toastMessage(l10n.translate('nameRequired') ?? 'First and last name are required');
      return;
    }

    final currentPwd = currentPasswordController.text.trim();
    final newPwd = newPasswordController.text.trim();
    final confirmPwd = confirmPasswordController.text.trim();
    final wantsPassword = currentPwd.isNotEmpty || newPwd.isNotEmpty || confirmPwd.isNotEmpty;

    if (wantsPassword) {
      if (currentPwd.isEmpty) {
        Utils.toastMessage(l10n.translate('pleaseEnterCurrentPassword') ?? 'Please enter your current password.');
        return;
      }
      if (newPwd.isEmpty) {
        Utils.toastMessage(l10n.translate('pleaseEnterNewPassword') ?? 'Please enter a new password.');
        return;
      }
      if (newPwd.length < 8) {
        Utils.toastMessage(l10n.translate('newPasswordMin8') ?? 'New password must be at least 8 characters.');
        return;
      }
      if (newPwd != confirmPwd) {
        Utils.toastMessage(l10n.translate('newPasswordMismatch') ?? 'New password and confirmation do not match.');
        return;
      }
    }

    final data = {
      'first_name': firstNameController.text.trim(),
      'last_name': lastNameController.text.trim(),
      'email': emailController.text.trim(),
      'phone': phoneController.text.trim(),
      'company_name': companyController.text.trim(),
      'country': countryController.text.trim(),
      'code': codeController.text.trim(),
      'description': descriptionController.text.trim(),
    };

    final ok = await auth.updateProfile(
      context,
      data,
      avatarFile: _selectedAvatar,
      popOnSuccess: !wantsPassword,
    );
    if (!ok || !mounted) return;

    if (wantsPassword) {
      final pwdOk = await auth.updatePassword(
        context,
        currentPassword: currentPwd,
        newPassword: newPwd,
        confirmPassword: confirmPwd,
      );
      if (pwdOk && mounted) {
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
        Navigator.of(context).pop();
      }
    }
  }

  Widget _dobField(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('dateOfBirth') ?? 'Date of Birth',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.inputBg.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.cake_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _dob != null
                      ? _displayDob(_dob!)
                      : (l10n.translate('notSet') ?? 'Not set'),
                  style: GoogleFonts.poppins(
                    color: _dob != null ? AppColors.textPrimary : AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.lock_outline, color: AppColors.textMuted.withValues(alpha: 0.7), size: 18),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.translate('dobReadOnlyHint') ??
              'Used for birthday rewards and promotions. Contact an administrator to change your date of birth.',
          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    );
  }
}
