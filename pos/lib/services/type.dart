import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/dio_config.dart';
import '../models/product_type.dart';
import '../models/api_response.dart';

class TypeService {
  Future<ApiResponse> getTypes() async {
    ApiResponse apiResponse = ApiResponse();
    List<ProductType> products = <ProductType>[];
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      Map<String, dynamic> _headers = {
        "authorization": "Bearer ${accessToken}"
      };

      final Response response =
          await ApiClient().fetch('/types', headers: _headers);
      response.data['data'].forEach((data) {
        products.add(ProductType.fromJson(data));
      });
      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: products);
      return apiResponse;
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> postType({
    required String typeCode,
    required String typeName,
    required String typeDesc,
  }) async {
    ApiResponse apiResponse = ApiResponse();
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    Map<String, dynamic> _headers = {"authorization": "Bearer ${accessToken}"};
    Map<String, dynamic> _body = {
      "typeCode": typeCode,
      "typeName": typeName,
      "typeDesc": typeDesc,
    };
    print(_body);
    try {
      final Response response =
          await ApiClient().post('/type', _body, headers: _headers);
      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: response.data['data']);
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> updateType({
    required int typeId,
    required String typeName,
    required String typeDesc,
  }) async {
    ApiResponse apiResponse = ApiResponse();
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    Map<String, dynamic> _headers = {
      "authorization": "Bearer ${accessToken}",
      "typeId": typeId,
    };
    Map<String, dynamic> _body = {"typeName": typeName, "typeDesc": typeDesc};

    try {
      final Response response =
          await ApiClient().put('/type', _body, headers: _headers);
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

  Future<ApiResponse> removeType({
    required int typeId,
  }) async {
    ApiResponse apiResponse = ApiResponse();
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    Map<String, dynamic> _headers = {
      "authorization": "Bearer ${accessToken}",
      "typeId": typeId,
    };

    try {
      final Response response =
          await ApiClient().put('/type/delete', null, headers: _headers);
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
