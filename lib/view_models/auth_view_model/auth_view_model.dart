import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lim_crm/models/login_model/login_model.dart';
import 'package:lim_crm/screens/BottomNavBar/bottom_nav_bar.dart';
import 'package:lim_crm/screens/auth_screens/login/login_screen.dart';
import 'package:lim_crm/screens/auth_screens/reset_password_screen/reset_password_screen.dart';
import 'package:lim_crm/screens/auth_screens/verify_otp_screen/verify_otp_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/network/network_api_service.dart';
import '../../repository/auth_repository/auth_repository.dart';
import '../../res/app_localization.dart';
import '../../utils/utils.dart';
import '../home_view_model/home_view_model.dart';
import '../bottom_nav_view_model/bottom_nav_view_model.dart';
import '../promotions_view_model/promotions_view_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository authRepository = AuthRepository();
  User? _user;
  User? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _resendLoading = false;
  bool get resendLoading => _resendLoading;

  set loading(bool setLoading) {
    _isLoading = setLoading;
    notifyListeners();
  }

  set resend(bool setLoading) {
    _resendLoading = setLoading;
    notifyListeners();
  }

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  Future<void> saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
      'user',
      jsonEncode(user.toJson()),
    );
    _user = user;
    notifyListeners();
  }

  Future<void> refreshProfile({bool silent = false}) async {
    try {
      final response = await authRepository.getProfileRepo();
      if (response['status'].toString() == '1' && response['user'] != null) {
        final current = _user;
        final updated = Map<String, dynamic>.from(current?.toJson() ?? {});
        updated.addAll(Map<String, dynamic>.from(response['user']));
        if ((updated['name'] ?? '').toString().trim().isEmpty) {
          updated['name'] =
              '${updated['first_name'] ?? ''} ${updated['last_name'] ?? ''}'.trim();
        }
        await saveUserData(User.fromJson(updated));
      }
    } catch (e) {
      debugPrint('Profile refresh error: $e');
    }
  }

  void mergeDashboardUser(Map<String, dynamic>? userJson) {
    if (userJson == null) return;
    final current = _user;
    final updated = Map<String, dynamic>.from(current?.toJson() ?? {});
    updated.addAll(userJson);
    if ((updated['name'] ?? '').toString().trim().isEmpty) {
      updated['name'] =
          '${updated['first_name'] ?? ''} ${updated['last_name'] ?? ''}'.trim();
    }
    _user = User.fromJson(updated);
    saveUserData(_user!);
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');

    if (userData != null) {
      _user = User.fromJson(jsonDecode(userData));
      notifyListeners();
    }
  }

  Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("email");
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    _user = null;
    notifyListeners();
  }

  Future<void> _persistRememberedEmail(String email, bool remember) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', remember);
    if (remember) {
      await prefs.setString('remembered_email', email.trim());
    } else {
      await prefs.remove('remembered_email');
    }
  }

  ///Login Api
  Future<void> loginApi(
    BuildContext context,
    dynamic data, {
    bool rememberMe = false,
  }) async {
    loading = true;
    try {
      final response = await authRepository.login(data);

      final status = response["status"].toString();
      final message = response["message"] ?? "Login failed";

      if (status == "1") {
        Utils.toastMessage(message);
        await _persistRememberedEmail(data['email']?.toString() ?? '', rememberMe);

        _user = LoginModel.fromJson(response).user;
        if (_user != null) {
          await saveUserData(_user!);
          await refreshProfile(silent: true);
        }

        if (!context.mounted) return;
        final promoProvider = Provider.of<PromotionsViewModel>(
          context,
          listen: false,
        );
        await promoProvider.checkBirthday(context);
        if (!context.mounted) return;
        if (promoProvider.checkBirthdayModel?.daysRemaining == 0) {
          await promoProvider.getBirthday(context);
        }

        if (!context.mounted) return;
        context.read<BottomNavViewModel>().goHome();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BottomNavBar()),
        );
      } else {
        Utils.toastMessage(message);
      }
    } catch (e) {
      debugPrint("Login error: $e");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  ///Verify Email

  Future<void> verifyEmailApi(BuildContext context, dynamic data) async {
    loading = true;
    try {
      debugPrint("Send otp  data: $data");

      final response = await authRepository.verifyEmail(data);

      // Check API-level status (e.g., "status": "1" or "0")
      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["message"]);
        final String email = data['email'];
        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VerifyOtpScreen(email: email)),
        );
      } else {
        Utils.toastMessage(response["message"]);
      }

      if (kDebugMode) {
        debugPrint("Send Otp API Response: $response");
      }
    } catch (e) {
      debugPrint("Send Otp error: $e");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  ///verify otp

  Future<void> verifyOtpApi(BuildContext context, dynamic data) async {
    loading = true;
    try {
      debugPrint("Verify otp  data: $data");

      final response = await authRepository.verifyOtp(data);

      // Check API-level status (e.g., "status": "1" or "0")
      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["message"]);
        final String email = data['email'];
        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(email: email),
          ),
        );
      } else {
        Utils.toastMessage(response["message"]);
      }
      if (kDebugMode) {
        debugPrint("Verify Otp API Response: $response");
      }
    } catch (e) {
      debugPrint("Verify Otp error: $e");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  ///Resend Otp
  Future<void> resendOtpApi(BuildContext context, dynamic data) async {
    resend = true;
    try {
      debugPrint("resend otp  data: $data");

      final response = await authRepository.resendOtp(data);

      // Check API-level status (e.g., "status": "1" or "0")
      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["message"]);
        // Navigator.pushNamed(context, RoutesName.login);
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => ResetPasswordScreen()),
        // );
      } else {
        Utils.toastMessage(response["message"]);
      }
      if (kDebugMode) {
        debugPrint("Resend Otp API Response: $response");
      }
    } catch (e) {
      debugPrint("Resend Otp error: $e");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      resend = false;
    }
  }

  ///Reset Password

  Future<void> resetPasswordApi(BuildContext context, dynamic data) async {
    loading = true;
    try {
      debugPrint("Reset Password  data: $data");

      final response = await authRepository.resetPassword(data);

      // Check API-level status (e.g., "status": "1" or "0")
      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["message"]);
        if (!context.mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
              (route) => false,
        );

      } else {
        Utils.toastMessage(response["message"]);
      }
      if (kDebugMode) {
        debugPrint("Reset password  API Response: $response");
      }
    } catch (e) {
      debugPrint("Reset password Otp error: $e");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  ///Settings

  Future<void> settingsApi(BuildContext context, dynamic data) async {
    loading = true;
    try {
      debugPrint("Settings data: $data");

      final response = await authRepository.settingsRepo(data);

      // Check API-level status (e.g., "status": "1" or "0")
      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["message"]);
        if (!context.mounted) return;
        context.read<BottomNavViewModel>().goHome();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BottomNavBar()),
        );
      } else {
        Utils.toastMessage(response["message"]);
      }
      if (kDebugMode) {
        debugPrint("Settings  API Response: $response");
      }
    } catch (e) {
      debugPrint("Settings error: $e");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }


  ///User Profile
  Future<bool> updateProfile(
    BuildContext context,
    Map<String, dynamic> data, {
    File? avatarFile,
    bool popOnSuccess = true,
  }) async {
    loading = true;
    try {
      debugPrint('Update Profile data: $data');

      final response = await authRepository.updateProfileRepo(
        data,
        avatarFilePath: avatarFile?.path,
      );

      if (response['status'].toString() == '1') {
        Utils.toastMessage(response['message']);

        if (response['user'] != null) {
          final current = _user;
          final updated = Map<String, dynamic>.from(current?.toJson() ?? {});
          updated.addAll(Map<String, dynamic>.from(response['user']));
          updated['name'] =
              '${updated['first_name'] ?? ''} ${updated['last_name'] ?? ''}'.trim();
          if (response['user']['avatar_url'] != null) {
            updated['avatar_url'] = response['user']['avatar_url'];
          }
          if (response['user']['avatar'] != null) {
            updated['avatar'] = response['user']['avatar'];
          }
          await saveUserData(User.fromJson(updated));
        }

        if (!context.mounted) return false;
        await context.read<HomeViewModel>().loadHomeData(context);
        if (!context.mounted) return false;
        if (popOnSuccess) {
          Navigator.of(context).pop();
        }
        return true;
      } else {
        Utils.toastMessage(response['message']);
        return false;
      }
    } catch (e) {
      debugPrint('Update Profile error: $e');
      Utils.toastMessage('Error: ${e.toString()}');
      return false;
    } finally {
      loading = false;
    }
  }

  Future<bool> updatePassword(
    BuildContext context, {
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    loading = true;
    try {
      final response = await authRepository.settingsRepo({
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': confirmPassword,
      });
      if (!context.mounted) return false;
      final l10n = AppLocalizations.of(context);
      if (response['status'].toString() == '1') {
        Utils.toastMessage(
          response['message'] ??
              l10n?.translate('passwordUpdatedSuccessfully') ??
              'Password updated successfully.',
        );
        return true;
      } else {
        Utils.toastMessage(
          response['message'] ??
              l10n?.translate('passwordUpdateFailed') ??
              'Password update failed.',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Password update error: $e');
      if (!context.mounted) return false;
      Utils.toastMessage(
        AppLocalizations.of(context)?.translate('passwordUpdateFailedRetry') ??
            'Password update failed. Please try again.',
      );
      return false;
    } finally {
      loading = false;
    }
  }

  ///Handle User Session
  Future<void> checkLoginStatus(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));
    await loadUserData();
    final token = await NetworkApiService().getToken();

    if (!context.mounted) return;

    if (token != null && token.isNotEmpty) {
      await refreshProfile(silent: true);
      if (!context.mounted) return;
      final promoProvider = Provider.of<PromotionsViewModel>(
        context,
        listen: false,
      );

      try {
        await promoProvider.checkBirthday(context);
        if (!context.mounted) return;
        if (promoProvider.checkBirthdayModel?.daysRemaining == 0) {
          await promoProvider.getBirthday(context);
        }

        if (!context.mounted) return;
        context.read<BottomNavViewModel>().goHome();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BottomNavBar()),
        );
      } catch (e) {
        debugPrint("Error checking birthday: $e");

        if (!context.mounted) return;
        context.read<BottomNavViewModel>().goHome();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BottomNavBar()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  ///Logout

  Future<void> logoutApi(BuildContext context) async {
    loading = true;
    try {
      final response = await authRepository.logout();

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["message"]);

        // Clear session if necessary
        await NetworkApiService().clearToken();
        await clearUserData();

        if (!context.mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
      } else {
        Utils.toastMessage(response["message"]);
      }

      if (kDebugMode) {
        debugPrint("Logout API Response: $response");
      }
    } catch (e) {
      debugPrint("Logout Api error: $e");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }
}
