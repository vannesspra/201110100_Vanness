import 'package:dio/dio.dart';
import 'package:example/config/dio_config.dart';
import 'package:example/models/api_response.dart';
import 'package:example/models/user.dart';
import 'package:example/services/auth.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserServices {
  Future<ApiResponse> getUserAccount() async {
    ApiResponse apiResponse = ApiResponse();
    List<User> users = <User>[];
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      Map<String, dynamic> _headers = {
        "authorization": "Bearer ${accessToken}"
      };
      final Response response =
          await ApiClient().fetch('/userAccounts', headers: _headers);

      response.data['data'].forEach((data) {
        users.add(User.fromJson(data));
      });
      apiResponse = ApiResponse(
        message: response.data['message'],
        status: response.data['status'],
        data: users,
      );
      return apiResponse;
    } on DioError catch (e) {
      print('Error Sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> postUser({
    required String name,
    required String userName,
    required String password,
    required String role,
  }) async {
    ApiResponse apiResponse = ApiResponse();
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    Map<String, dynamic> _headers = {"authorization": "Bearer ${accessToken}"};
    Map<String, dynamic> _userBody = {
      "name": name,
      "userName": userName,
      "password": password,
      "role": role,
    };
    print(_userBody);
    try {
      final Response response =
          await ApiClient().post('/account', _userBody, headers: _headers);
      apiResponse = ApiResponse(
        message: response.data['message'],
        status: response.data['status'],
        data: response.data['data'],
      );
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> updateUser({
    required int userId,
    required String name,
    required String userName,
    required String password,
    required String role,
  }) async {
    ApiResponse apiResponse = ApiResponse();
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    Map<String, dynamic> _headers = {
      "authorization": "Bearer ${accessToken}",
      "userId": userId
    };
    Map<String, dynamic> _userBody = {
      "name": name,
      "userName": userName,
      "password": password,
      "role": role,
    };
    print(_userBody);
    try {
      final Response response =
          await ApiClient().put('/account', _userBody, headers: _headers);
      apiResponse = ApiResponse(
        message: response.data['message'],
        status: response.data['status'],
        data: response.data['data'],
      );
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> removeUser({
    required int userId,
  }) async {
    ApiResponse apiResponse = ApiResponse();
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    Map<String, dynamic> _headers = {
      "authorization": "Bearer ${accessToken}",
      "userId": userId
    };

    try {
      final Response response =
          await ApiClient().put('/account/delete', null, headers: _headers);
      apiResponse = ApiResponse(
        message: response.data['message'],
        status: response.data['status'],
        data: response.data['data'],
      );
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }
}
