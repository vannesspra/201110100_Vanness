import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/dio_config.dart';
import '../models/profile.dart';
import '../models/api_response.dart';

class AuthService {
  Future<ApiResponse> getProfile() async {
    ApiResponse apiResponse = ApiResponse();
    Profile? profile;
    try {
      // Map<String, dynamic> _headers= {

      // };

      final Response response = await ApiClient().fetch('/profile');

      if (response.data['data'] != null) {
        profile = Profile.fromJson(response.data['data']);
      } else {
        print("null");
        profile = Profile(
            companyId: null,
            companyName: null,
            companyAddress: null,
            companyContactPerson: null,
            companyContactPersonNumber: null,
            companyEmail: null,
            companyPhoneNumber: null,
            companyWebsite: null);
      }

      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: profile);
      return apiResponse;
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> login({
    required userName,
    required password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    ApiResponse apiResponse = ApiResponse();
    Map<String, dynamic> _body = {
      "userName": userName,
      "password": password,
    };

    try {
      final Response response = await ApiClient().post('/login', _body);
      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          type: response.data['type'],
          data: response.data['data']);

      await prefs.setString('accessToken', apiResponse.data['accessToken']);
      await prefs.setString('refreshToken', apiResponse.data['refreshToken']);
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> refreshToken() async {
    ApiResponse apiResponse = ApiResponse();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? refreshToken = prefs.getString('refreshToken');
      Map<String, dynamic> _headers = {
        "authorization": "Bearer ${refreshToken}"
      };
      final Response response =
          await ApiClient().fetch('/token', headers: _headers);

      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          type: response.data['type'],
          data: response.data['data']);
      await prefs.setString('accessToken', apiResponse.data['accessToken']);
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }
}
