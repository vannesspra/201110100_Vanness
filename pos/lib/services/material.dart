import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/dio_config.dart';
import '../models/material.dart';
import '../models/api_response.dart';

class MaterialService {
  Future<ApiResponse> getMaterials() async {
    ApiResponse apiResponse = ApiResponse();
    List<Material> materials = <Material>[];
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      Map<String, String> _headers = {
        "authorization": "Bearer ${accessToken}",
      };
      final Response response =
          await ApiClient().fetch('/materials', headers: _headers);
      response.data['data'].forEach((data) {
        materials.add(Material.fromJson(data));
      });
      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: materials);
      return apiResponse;
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> postMaterial(
      {required String materialCode,
      required String materialName,
      int? colorId,
      required String materialUnit,
      required String materialMinimumStock,
      required String materialQty,
      required String materialPrice}) async {
    ApiResponse apiResponse = ApiResponse();
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    Map<String, String> _headers = {
      "authorization": "Bearer ${accessToken}",
    };
    Map<String, dynamic> _body = {
      "materialCode": materialCode,
      "materialName": materialName,
      "colorId": colorId,
      "materialUnit": materialUnit,
      "materialMinimumStock": materialMinimumStock,
      "materialQty": materialQty,
      "materialPrice": materialPrice
    };

    try {
      final Response response =
          await ApiClient().post('/material', _body, headers: _headers);
      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: response.data['data']);
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> updateMaterial(
      {required int materialId,
      required String materialName,
      int? colorId,
      required String materialUnit,
      required String materialMinimumStock,
      required String materialQty,
      required String materialPrice}) async {
    ApiResponse apiResponse = ApiResponse();
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    Map<String, dynamic> _headers = {
      "authorization": "Bearer ${accessToken}",
      "materialId": materialId,
    };
    Map<String, dynamic> _materialBody = {
      "materialName": materialName,
      "colorId": colorId,
      "materialUnit": materialUnit,
      "materialMinimumStock": materialMinimumStock,
      "materialQty": materialQty,
      "materialPrice": materialPrice
    };
    try {
      final Response response =
          await ApiClient().put('/material', _materialBody, headers: _headers);
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

  Future<ApiResponse> removeMaterial({
    required int materialId,
  }) async {
    ApiResponse apiResponse = ApiResponse();
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    Map<String, dynamic> _headers = {
      "authorization": "Bearer ${accessToken}",
      "materialId": materialId,
    };

    try {
      final Response response =
          await ApiClient().put('/material/delete', null, headers: _headers);
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
