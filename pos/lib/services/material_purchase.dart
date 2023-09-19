import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/dio_config.dart';
import '../models/material_purchase.dart';
import '../models/api_response.dart';

class MaterialPurchaseService {
  Future<ApiResponse> getMaterialPurchaseByCode(
      String materialPurchaseCode) async {
    ApiResponse apiResponse = ApiResponse();
    List<MaterialPurchase> materialPurchases = <MaterialPurchase>[];
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      Map<String, String> _headers = {
        "authorization": "Bearer ${accessToken}",
        "materialPurchaseCode": materialPurchaseCode
      };

      final Response response =
          await ApiClient().fetch('/material_purchase', headers: _headers);
      print(response.data);
      response.data['data'].forEach((data) {
        materialPurchases.add(MaterialPurchase.fromJson(data));
      });
      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: materialPurchases);
      return apiResponse;
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> getMaterialPurchaseGrouped() async {
    ApiResponse apiResponse = ApiResponse();
    List<MaterialPurchase> materialPurchases = <MaterialPurchase>[];
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      Map<String, String> _headers = {
        "authorization": "Bearer ${accessToken}",
      };

      final Response response = await ApiClient()
          .fetch('/material_purchases/grouped', headers: _headers);
      response.data['data'].forEach((data) {
        materialPurchases.add(MaterialPurchase.fromJson(data));
      });
      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: materialPurchases);
      return apiResponse;
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> getMaterialPurchases() async {
    ApiResponse apiResponse = ApiResponse();
    List<MaterialPurchase> materialPurchases = <MaterialPurchase>[];
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      Map<String, String> _headers = {
        "authorization": "Bearer ${accessToken}",
      };

      final Response response =
          await ApiClient().fetch('/material_purchases', headers: _headers);
      response.data['data'].forEach((data) {
        materialPurchases.add(MaterialPurchase.fromJson(data));
      });
      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: materialPurchases);
      return apiResponse;
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> postMaterialPurchase(
      {required String materialPurchaseCode,
      required DateTime materialPruchaseDate,
      required String taxInvoiceNumber,
      required String taxAmount,
      required int? supplierId,
      required List<Map<String, dynamic>> materials,
      String? imagePath}) async {
    ApiResponse apiResponse = ApiResponse();
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    FormData formData = FormData();
    if (imagePath != null) {
      formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath),
        "materialPurchaseCode": materialPurchaseCode,
        "materialPurchaseDate": materialPruchaseDate.toString(),
        "supplierId": supplierId,
        "materials": materials,
        "taxInvoiceNumber": taxInvoiceNumber,
        "taxAmount": taxAmount,
      });
    } else {
      formData = FormData.fromMap({
        "materialPurchaseCode": materialPurchaseCode,
        "materialPurchaseDate": materialPruchaseDate.toString(),
        "supplierId": supplierId,
        "materials": materials,
        "taxInvoiceNumber": taxInvoiceNumber,
        "taxAmount": taxAmount,
      });
    }

    Map<String, String> _headers = {
      "authorization": "Bearer ${accessToken}",
    };
    // Map<String, dynamic> _body = {
    //   "materialPurchaseCode": materialPurchaseCode,
    //   "materialPurchaseDate": materialPruchaseDate.toString(),
    //   "supplierId": supplierId,
    //   "materials": materials,
    //   "taxInvoiceNumber": taxInvoiceNumber,
    //   "taxAmount": taxAmount,
    // };
    print("ANOS: ${imagePath}");
    print(formData.files);
    try {
      final Response response = await ApiClient().post(
          '/material_purchase', formData,
          headers: _headers,
          options: Options(contentType: 'multipart/form-data'));
      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: response.data['data']);
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> deletePurchase(
      {required String materialPurchaseCode}) async {
    ApiResponse apiResponse = ApiResponse();
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    Map<String, String> _headers = {
      "authorization": "Bearer ${accessToken}",
      "materialPurchaseCode": materialPurchaseCode,
    };
    Map<String, dynamic> _body = {};

    try {
      final Response response =
          await ApiClient().put('/material_purchase', _body, headers: _headers);
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
