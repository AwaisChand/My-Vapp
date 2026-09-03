import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/login_model/login_model.dart';
import '../app_exception.dart';
import 'base_api_service.dart';

class NetworkApiService extends BaseApiServices {
  @override
  Future getRequest(String url) async {
    dynamic responseJson;
    String? token = await NetworkApiService().getToken();
    debugPrint("Get Token===$token");
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      responseJson = returnResponse(response);
      debugPrint("Raw response body: ${response.body}"); // Add this line
    } on SocketException {
      throw FetchDataException("No Internet Connection");
    }
    return responseJson;
  }

  @override
  Future<dynamic> postApiResponse(String url) async {
    try {
      String? token = await NetworkApiService().getToken();
      final response = await http
          .post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      )
          .timeout(const Duration(seconds: 30));

      debugPrint("Url === $url");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ Do not throw on API-level status == "0"
        final responseJson = jsonDecode(response.body);
        return responseJson;
      } else {
        // ❌ Only throw on HTTP error status
        return returnResponse(response);
      }
    } on SocketException {
      throw FetchDataException("No Internet Connection");
    } catch (e) {
      rethrow;
    }
  }


  @override
  Future<dynamic> postLoginRequest(String url, dynamic data) async {
    try {
      final response = await http
          .post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      )
          .timeout(const Duration(seconds: 30));

      debugPrint("login url === $url");
      debugPrint("login raw response === ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = json.decode(response.body);

        // ✅ Don't throw if status is 0, just return it to let UI show message
        if (responseBody["status"].toString() == "1") {
          final loginData = LoginModel.fromJson(responseBody).user;
          final loginToken = LoginModel.fromJson(responseBody);

          final token = loginToken.accessToken;
          final userId = loginData?.id;
          final email = loginData?.email;
          final phone = loginData?.phone;

          // Save token
          await NetworkApiService().setToken(token ?? '');
          debugPrint("login token === $token");

          // Save user info in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("token", token ?? '');
          await prefs.setString("userId", userId.toString());
          await prefs.setString("email", email ?? '');
          await prefs.setString("phone", phone ?? '');

          debugPrint("User info saved in SharedPreferences");
        }

        return responseBody;
      } else {
        // ❌ HTTP error status
        return returnResponse(response);
      }
    } on SocketException {
      throw FetchDataException("No Internet Connection");
    } catch (e) {
      rethrow;
    }
  }


  @override
  Future<dynamic> postSignUpRequest(String url, dynamic data) async {
    try {
      // String? token = await NetworkApiService().getToken();
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              // 'Authorization': 'Bearer $token',
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 30));
      debugPrint("volunteer url === $url");
      // debugPrint("volunteer token === $token");

      // Check HTTP status code
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseJson = jsonDecode(response.body);

        // Check API-level status from JSON
        if (responseJson["status"].toString() == "0") {
          throw BadRequestException(responseJson["message"].toString());
        }

        return responseJson;
      } else {
        // Handle all other HTTP errors via custom handler
        return returnResponse(response); // this throws internally
      }
    } on SocketException {
      throw FetchDataException("No Internet Connection");
    } catch (e) {
      rethrow; // Rethrow for higher-level error handling
    }
  }

  @override
  Future<dynamic> postRequest(String url, dynamic data) async {
    try {
      String? token = await NetworkApiService().getToken();
      final response = await http
          .post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      )
          .timeout(const Duration(seconds: 30));

      debugPrint("Url === $url");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return returnResponse(response);
      }
    } on SocketException {
      throw FetchDataException("No Internet Connection");
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> postMultipartRequest(
    String url,
    Map<String, String> fields, {
    String? fileField,
    String? filePath,
  }) async {
    try {
      final token = await getToken();
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Accept'] = 'application/json';
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.fields.addAll(fields);

      if (fileField != null && filePath != null && filePath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath(fileField, filePath));
      }

      final streamed = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamed);

      debugPrint('Multipart Url === $url');
      debugPrint('Multipart status === ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> deleteRequest(String url) async {
    try {
      String? token = await NetworkApiService().getToken();
      final response = await http
          .delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      )
          .timeout(const Duration(seconds: 30));

      debugPrint("Delete Url === $url");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return returnResponse(response);
      }
    } on SocketException {
      throw FetchDataException("No Internet Connection");
    } catch (e) {
      rethrow;
    }
  }


  @override
  Future<Map<String, dynamic>> postJsonRequest(String url, Map<String, dynamic> data) async {
    try {
      final token = await getToken();
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('POST JSON $url => ${response.statusCode}');
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'status': 0, 'message': 'Unexpected response'};
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
  }

  dynamic returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return jsonDecode(response.body); // ✅ No throw for status == 0
      case 400:
        throw BadRequestException("Bad Request");
      case 401:
        throw UnAuthorizedException("Unauthorized");
      case 403:
        throw UnAuthorizedException("Forbidden");
      case 404:
        throw FetchDataException("URL Not Found");
      case 500:
        throw FetchDataException("Internal Server Error");
      default:
        throw FetchDataException(
          "Error with status code: ${response.statusCode}",
        );
    }
  }

  Future<bool> setToken(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('token', value);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    debugPrint("Get Token=== $token");
    return token;
  }


  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }
}
