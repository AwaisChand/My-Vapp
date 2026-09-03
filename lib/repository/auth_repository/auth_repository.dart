import 'package:flutter/foundation.dart';

import '../../data/network/base_api_service.dart';
import '../../data/network/network_api_service.dart';
import '../../res/app_url.dart';

class AuthRepository{
  BaseApiServices baseApiServices = NetworkApiService();

  ///Login
  Future<dynamic> login(dynamic data) async {
    try {
      dynamic response = await baseApiServices.postLoginRequest(
        AppUrl.loginEndPoint,
        data,
      );
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.loginEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///Verify email

  Future<dynamic> verifyEmail(dynamic data) async {
    try {
      dynamic response = await baseApiServices.postRequest(
        AppUrl.sendOtpEndPoint,
        data,
      );
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.sendOtpEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///Verify Otp

  Future<dynamic> verifyOtp(dynamic data) async {
    try {
      dynamic response = await baseApiServices.postRequest(
        AppUrl.verifyOtpEndPoint,
        data,
      );
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.verifyOtpEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///Resend Otp

  Future<dynamic> resendOtp(dynamic data) async {
    try {
      dynamic response = await baseApiServices.postRequest(
        AppUrl.resendOtpEndPoint,
        data,
      );
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.resendOtpEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///Reset Password

  Future<dynamic> resetPassword(dynamic data) async {
    try {
      dynamic response = await baseApiServices.postRequest(
        AppUrl.resetPasswordEndPoint,
        data,
      );
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.resetPasswordEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///Settings

  Future<dynamic> settingsRepo(dynamic data) async {
    try {
      dynamic response = await baseApiServices.postRequest(
        AppUrl.settingsEndPoint,
        data,
      );
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.settingsEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }


  ///User Profile
  Future<dynamic> getProfileRepo() async {
    try {
      final response = await baseApiServices.getRequest(AppUrl.profileEndPoint);
      debugPrint("Api url: ${AppUrl.profileEndPoint}");
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<dynamic> updateProfileRepo(
    Map<String, dynamic> data, {
    String? avatarFilePath,
  }) async {
    try {
      final fields = data.map((key, value) => MapEntry(key, value?.toString() ?? ''));
      dynamic response;

      if (avatarFilePath != null && avatarFilePath.isNotEmpty) {
        response = await baseApiServices.postMultipartRequest(
          AppUrl.userProfileEndPoint,
          fields,
          fileField: 'avatar_file',
          filePath: avatarFilePath,
        );
      } else {
        response = await baseApiServices.postRequest(
          AppUrl.userProfileEndPoint,
          data,
        );
      }

      debugPrint('response$response');
      debugPrint('Api url: ${AppUrl.userProfileEndPoint}');

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///Logout

  Future<dynamic> logout() async {
    try {
      dynamic response = await baseApiServices.postApiResponse(
        AppUrl.logoutEndPoint,
      );
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.logoutEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

}