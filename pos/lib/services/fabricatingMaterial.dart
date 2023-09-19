import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:example/models/fabricatingMaterial.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/dio_config.dart';
import '../models/material.dart';
import '../models/api_response.dart';

class FabricatingMaterialService {
  Future<ApiResponse> getFabricatingMaterials() async {
    ApiResponse apiResponse = ApiResponse();
    List<FabricatingMaterial> fabricatingMaterials = <FabricatingMaterial>[];
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      Map<String, String> _headers = {
        "authorization": "Bearer ${accessToken}",
      };
      final Response response =
          await ApiClient().fetch('/fabricatingMaterials', headers: _headers);
      response.data['data'].forEach((data) {
        fabricatingMaterials.add(FabricatingMaterial.fromJson(data));
      });
      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: fabricatingMaterials);
      return apiResponse;
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> postFabricatingMaterial(
      {required String fabricatingMaterialCode,
      required String fabricatingMaterialName,
      int? colorId,
      required String fabricatingMaterialUnit,
      required String fabricatingMaterialMinimumStock,
      required String fabricatingMaterialQty,
      required String fabricatingMaterialPrice}) async {
    ApiResponse apiResponse = ApiResponse();
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    Map<String, String> _headers = {
      "authorization": "Bearer ${accessToken}",
    };
    Map<String, dynamic> _body = {
      "fabricatingMaterialCode": fabricatingMaterialCode,
      "fabricatingMaterialName": fabricatingMaterialName,
      "colorId": colorId,
      "fabricatingMaterialUnit": fabricatingMaterialUnit,
      "fabricatingMaterialMinimumStock": fabricatingMaterialMinimumStock,
      "fabricatingMaterialQty": fabricatingMaterialQty,
      "fabricatingMaterialPrice": fabricatingMaterialPrice,
    };

    try {
      final Response response = await ApiClient()
          .post('/fabricatingMaterial', _body, headers: _headers);
      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: response.data['data']);
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> updateFabricatingMaterial({
    required int fabricatingMaterialId,
    required String fabricatingMaterialName,
    int? colorId,
    required String fabricatingMaterialUnit,
    required String fabricatingMaterialMinimumStock,
    required String fabricatingMaterialQty,
    required String fabricatingMaterialPrice,
  }) async {
    ApiResponse apiResponse = ApiResponse();
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    Map<String, dynamic> _headers = {
      "authorization": "Bearer ${accessToken}",
      "fabricatingMaterialId": fabricatingMaterialId,
    };
    Map<String, dynamic> _fabricatingMaterialBody = {
      "fabricatingMaterialName": fabricatingMaterialName,
      "colorId": colorId,
      "fabricatingMaterialUnit": fabricatingMaterialUnit,
      "fabricatingMaterialMinimumStock": fabricatingMaterialMinimumStock,
      "fabricatingMaterialQty": fabricatingMaterialQty,
      "fabricatingMaterialPrice": fabricatingMaterialPrice,
    };
    try {
      final Response response = await ApiClient().put(
          '/fabricatingMaterial', _fabricatingMaterialBody,
          headers: _headers);
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

  Future<ApiResponse> removeFabricatingMaterial({
    required int fabricatingMaterialId,
  }) async {
    ApiResponse apiResponse = ApiResponse();
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    Map<String, dynamic> _headers = {
      "authorization": "Bearer ${accessToken}",
      "fabricatingMaterialId": fabricatingMaterialId,
    };

    try {
      final Response response = await ApiClient()
          .put('/fabricatingMaterial/delete', null, headers: _headers);
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
