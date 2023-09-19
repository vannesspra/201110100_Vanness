import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/dio_config.dart';
import '../models/profile.dart';
import '../models/api_response.dart';

class HomeService {
  Future<ApiResponse> getHomeStat() async {
    ApiResponse apiResponse = ApiResponse();
    Profile? profile;
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      Map<String, String> _headers = {
        "authorization": "Bearer ${accessToken}",
      };

      final Response response =
          await ApiClient().fetch('/home', headers: _headers);

      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: response.data['data']);
      return apiResponse;
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }
}
