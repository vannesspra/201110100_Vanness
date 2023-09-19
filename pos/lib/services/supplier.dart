import 'package:dio/dio.dart';
import 'package:example/config/dio_config.dart';
import 'package:example/models/api_response.dart';
import 'package:example/models/supplier.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupplierServices {
  Future<ApiResponse> getSupplier() async {
    ApiResponse apiResponse = ApiResponse();
    List<Supplier> suppliers = <Supplier>[];
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');
      Map<String, dynamic> _headers = {
        "authorization": "Bearer ${accessToken}",
      };
      final Response response =
          await ApiClient().fetch('/suppliers', headers: _headers);

      response.data['data'].forEach((data) {
        suppliers.add(Supplier.fromJson(data));
      });
      apiResponse = ApiResponse(
        message: response.data['message'],
        status: response.data['status'],
        data: suppliers,
      );
      return apiResponse;
    } on DioError catch (e) {
      print('Error Sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> postSupplier({
    required String supplierCode,
    required String supplierName,
    required String supplierAddress,
    required String supplierPhoneNumber,
    required String supplierEmail,
    required String supplierContactPerson,
    required String paymentType,
    required String paymentTerm,
    required String supplierTax,
    required List<Map<String, dynamic>> supplierProducts,
    required List<Map<String, dynamic>> supplierMaterials,
    required List<Map<String, dynamic>> supplierFabricatingMaterials,
  }) async {
    ApiResponse apiResponse = ApiResponse();
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    Map<String, dynamic> _headers = {
      "authorization": "Bearer ${accessToken}",
    };
    Map<String, dynamic> _supplierBody = {
      "supplierCode": supplierCode,
      "supplierName": supplierName,
      "supplierAddress": supplierAddress,
      "supplierPhoneNumber": supplierPhoneNumber,
      "supplierEmail": supplierEmail,
      "supplierContactPerson": supplierContactPerson,
      "paymentType": paymentType,
      "paymentTerm": paymentTerm,
      "supplierTax": supplierTax,
      "supplierProducts": supplierProducts,
      "supplierMaterials": supplierMaterials,
      "supplierFabricatingMaterials": supplierFabricatingMaterials,
    };
    print(_supplierBody);
    try {
      final Response response =
          await ApiClient().post('/supplier', _supplierBody, headers: _headers);
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

  Future<ApiResponse> updateSupplier({
    required int supplierId,
    required String supplierName,
    required String supplierAddress,
    required String supplierPhoneNumber,
    required String supplierEmail,
    required String supplierContactPerson,
    required String paymentType,
    required String paymentTerm,
    required String supplierTax,
    required List<Map<String, dynamic>> supplierProducts,
    required List<Map<String, dynamic>> supplierMaterials,
    required List<Map<String, dynamic>> supplierFabricatingMaterials,
  }) async {
    ApiResponse apiResponse = ApiResponse();
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    Map<String, dynamic> _headers = {
      "authorization": "Bearer ${accessToken}",
      "supplierId": supplierId,
    };
    Map<String, dynamic> _supplierBody = {
      "supplierName": supplierName,
      "supplierAddress": supplierAddress,
      "supplierPhoneNumber": supplierPhoneNumber,
      "supplierEmail": supplierEmail,
      "supplierContactPerson": supplierContactPerson,
      "paymentType": paymentType,
      "paymentTerm": paymentTerm,
      "supplierTax": supplierTax,
      "supplierProducts": supplierProducts,
      "supplierMaterials": supplierMaterials,
      "supplierFabricatingMaterials": supplierFabricatingMaterials,
    };

    try {
      final Response response =
          await ApiClient().put('/supplier', _supplierBody, headers: _headers);
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

  Future<ApiResponse> removeSupplier({
    required int supplierId,
  }) async {
    ApiResponse apiResponse = ApiResponse();
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    Map<String, dynamic> _headers = {
      "authorization": "Bearer ${accessToken}",
      "supplierId": supplierId,
    };

    try {
      final Response response =
          await ApiClient().put('/supplier/delete', null, headers: _headers);
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
