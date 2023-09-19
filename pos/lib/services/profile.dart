import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/dio_config.dart';
import '../models/profile.dart';
import '../models/api_response.dart';

class ProfileService {
  Future<ApiResponse> getProfile() async {
    ApiResponse apiResponse = ApiResponse();
    Profile? profile;
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      Map<String, String> _headers = {"authorization": "Bearer ${accessToken}"};

      final Response response =
          await ApiClient().fetch('/profile', headers: _headers);

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

  Future<ApiResponse> createProfile(
      {required companyName,
      required companyAddress,
      required companyPhoneNumber,
      required companyWebsite,
      required companyEmail,
      required companyContactPerson,
      required companyContactPersonNumber}) async {
    ApiResponse apiResponse = ApiResponse();
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    Map<String, String> _headers = {"authorization": "Bearer ${accessToken}"};
    Map<String, dynamic> _body = {
      "companyName": companyName,
      "companyAddress": companyAddress,
      "companyPhoneNumber": companyPhoneNumber,
      "companyWebsite": companyWebsite,
      "companyEmail": companyEmail,
      "companyContactPerson": companyContactPerson,
      "companyContactPersonNumber": companyContactPersonNumber
    };

    try {
      final Response response =
          await ApiClient().post('/profile', _body, headers: _headers);
      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: response.data['data']);
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> updateProfile(
      {required companyName,
      required companyAddress,
      required companyPhoneNumber,
      required companyWebsite,
      required companyEmail,
      required companyContactPerson,
      required companyContactPersonNumber}) async {
    ApiResponse apiResponse = ApiResponse();
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    Map<String, String> _headers = {
      "authorization": "Bearer ${accessToken}",
    };
    Map<String, dynamic> _body = {
      "companyName": companyName,
      "companyAddress": companyAddress,
      "companyPhoneNumber": companyPhoneNumber,
      "companyWebsite": companyWebsite,
      "companyEmail": companyEmail,
      "companyContactPerson": companyContactPerson,
      "companyContactPersonNumber": companyContactPersonNumber
    };

    try {
      final Response response =
          await ApiClient().put('/profile', _body, headers: _headers);
      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: response.data['data']);
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }
}
