import 'package:dio/dio.dart';
import 'package:example/models/production.dart';
import 'package:example/screens/production_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/dio_config.dart';
import '../models/api_response.dart';

class ProductionService {
  Future<ApiResponse> getProductionByCode(String productionCode) async {
    ApiResponse apiResponse = ApiResponse();
    List<Production> productions = <Production>[];
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      Map<String, String> _headers = {
        "authorization": "Bearer ${accessToken}",
        "productionCode": productionCode,
      };

      final Response response =
          await ApiClient().fetch('/production', headers: _headers);
      print(response.data);
      response.data['data'].forEach((data) {
        productions.add(Production.fromJson(data));
      });
      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: productions);
      return apiResponse;
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> getProductionGrouped() async {
    ApiResponse apiResponse = ApiResponse();
    List<Production> productions = <Production>[];
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      Map<String, String> _headers = {
        "authorization": "Bearer ${accessToken}",
      };

      final Response response =
          await ApiClient().fetch('/productions/grouped', headers: _headers);
      response.data['data'].forEach((data) {
        productions.add(Production.fromJson(data));
      });
      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: productions);
      return apiResponse;
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> getProduction() async {
    ApiResponse apiResponse = ApiResponse();
    List<Production> productions = <Production>[];
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      Map<String, String> _headers = {
        "authorization": "Bearer ${accessToken}",
      };

      final Response response =
          await ApiClient().fetch('/productions', headers: _headers);
      response.data['data'].forEach((data) {
        productions.add(Production.fromJson(data));
      });
      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: productions);
      return apiResponse;
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> postProduction({
    required String productionCode,
    required List<Map<String, dynamic>> materials,
    required String productionQty,
    required String productionDesc,
    required DateTime productionDate,
  }) async {
    ApiResponse apiResponse = ApiResponse();
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    Map<String, String> _headers = {"authorization": "Bearer ${accessToken}"};
    Map<String, dynamic> _body = {
      "productionCode": productionCode,
      "materials": materials,
      "productionDate": productionDate.toString(),
      "productionQty": productionQty,
      "productionDesc": productionDesc
    };
    print(_body);
    try {
      final Response response =
          await ApiClient().post('/production', _body, headers: _headers);
      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: response.data['data']);
      print(response);
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> deleteProduction({required String productionCode}) async {
    ApiResponse apiResponse = ApiResponse();
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    Map<String, String> _headers = {
      "authorization": "Bearer ${accessToken}",
      "productionCode": productionCode
    };
    Map<String, dynamic> _body = {};
    print(_body);
    try {
      final Response response =
          await ApiClient().put('/production', _body, headers: _headers);
      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: response.data['data']);
      print(response);
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }
}
