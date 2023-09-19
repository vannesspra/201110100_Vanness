import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/dio_config.dart';
import '../models/material_spending.dart';
import '../models/api_response.dart';

class MaterialSpendingService {
  Future<ApiResponse> getMaterialSpendingByCode(
      String materialSpendingCode) async {
    ApiResponse apiResponse = ApiResponse();
    List<MaterialSpending> materialSpendings = <MaterialSpending>[];
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      Map<String, String> _headers = {
        "authorization": "Bearer ${accessToken}",
        "materialSpendingCode": materialSpendingCode
      };

      final Response response =
          await ApiClient().fetch('/material_spending', headers: _headers);
      print(response.data);
      response.data['data'].forEach((data) {
        materialSpendings.add(MaterialSpending.fromJson(data));
      });
      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: materialSpendings);
      return apiResponse;
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> getMaterialSpendingGrouped() async {
    ApiResponse apiResponse = ApiResponse();
    List<MaterialSpending> materialSpendings = <MaterialSpending>[];
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      Map<String, String> _headers = {
        "authorization": "Bearer ${accessToken}",
      };

      final Response response = await ApiClient()
          .fetch('/material_spendings/grouped', headers: _headers);
      response.data['data'].forEach((data) {
        materialSpendings.add(MaterialSpending.fromJson(data));
      });
      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: materialSpendings);
      return apiResponse;
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> getMaterialSpendings() async {
    ApiResponse apiResponse = ApiResponse();
    List<MaterialSpending> materialSpendings = <MaterialSpending>[];
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      Map<String, String> _headers = {
        "authorization": "Bearer ${accessToken}",
      };

      final Response response =
          await ApiClient().fetch('/material_spendings', headers: _headers);
      response.data['data'].forEach((data) {
        materialSpendings.add(MaterialSpending.fromJson(data));
      });
      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: materialSpendings);
      return apiResponse;
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> postMaterialSpending({
    required String materialSpendingCode,
    required List<Map<String, dynamic>> materials,
    required DateTime materialSpendingDate,
  }) async {
    ApiResponse apiResponse = ApiResponse();
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    Map<String, String> _headers = {
      "authorization": "Bearer ${accessToken}",
    };
    Map<String, dynamic> _body = {
      "materialSpendingCode": materialSpendingCode,
      "materialSpendingDate": materialSpendingDate.toString(),
      "materials": materials,
    };
    print(_body);
    try {
      final Response response = await ApiClient()
          .post('/material_spending', _body, headers: _headers);
      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: response.data['data']);
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> deleteSpending({
    required String materialSpendingCode,
  }) async {
    ApiResponse apiResponse = ApiResponse();
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    Map<String, String> _headers = {
      "authorization": "Bearer ${accessToken}",
      "materialSpendingCode": materialSpendingCode,
    };
    Map<String, dynamic> _body = {};
    print(_body);
    try {
      final Response response =
          await ApiClient().put('/material_spending', _body, headers: _headers);
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
