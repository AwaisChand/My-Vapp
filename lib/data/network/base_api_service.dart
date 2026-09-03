abstract class BaseApiServices {
  Future<dynamic> getRequest(String url);

  Future<dynamic> postLoginRequest(String url, dynamic data);
  Future<dynamic> postApiResponse(String url);
  Future<dynamic> postSignUpRequest(String url, dynamic data);
  Future<dynamic> postRequest(String url, dynamic data);
  Future<Map<String, dynamic>> postJsonRequest(String url, Map<String, dynamic> data);
  Future<dynamic> postMultipartRequest(
    String url,
    Map<String, String> fields, {
    String? fileField,
    String? filePath,
  });
  Future<dynamic> deleteRequest(String url);
}
