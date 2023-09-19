import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/dio_config.dart';
import '../models/product.dart';
import '../models/api_response.dart';

class ProductService {
  Future<ApiResponse> getProduct() async {
    ApiResponse apiResponse = ApiResponse();
    List<Product> products = <Product>[];
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      Map<String, String> _headers = {
        "authorization": "Bearer ${accessToken}",
      };

      final Response response =
          await ApiClient().fetch('/products', headers: _headers);
      response.data['data'].forEach((data) {
        products.add(Product.fromJson(data));
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

  Future<ApiResponse> postProduct(
      {required String productCode,
      required String productName,
      required String productPrice,
      required String productDesc,
      required String productMinimumStock,
      required String productQty,
      required int? colorId,
      // List? colors,
      required int? typeId}) async {
    ApiResponse apiResponse = ApiResponse();
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    Map<String, String> _headers = {"authorization": "Bearer ${accessToken}"};
    Map<String, dynamic> _body = {
      "productCode": productCode,
      "productName": productName,
      "typeId": typeId,
      "colorId": colorId,
      "productPrice": productPrice,
      "productDesc": productDesc,
      "productMinimumStock": productMinimumStock,
      "productQty": productQty,
      // "colors": colors
    };
    print(_body);
    try {
      final Response response =
          await ApiClient().post('/product', _body, headers: _headers);
      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: response.data['data']);
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> removeProduct({
    required int productId,
  }) async {
    ApiResponse apiResponse = ApiResponse();
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    Map<String, dynamic> _headers = {
      "authorization": "Bearer ${accessToken}",
      "productId": productId,
    };
    try {
      final Response response =
          await ApiClient().put('/product/delete', null, headers: _headers);
      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: response.data['data']);
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> updateProduct(
      {required int productId,
      required String productCode,
      required String productName,
      required String productPrice,
      required String productDesc,
      required String productMinimumStock,
      required String productQty,
      required int? colorId,
      // List? colors,
      required int? typeId}) async {
    ApiResponse apiResponse = ApiResponse();

    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    Map<String, dynamic> _headers = {
      "authorization": "Bearer ${accessToken}",
      "productId": productId,
    };
    Map<String, dynamic> _body = {
      "productCode": productCode,
      "productName": productName,
      "typeId": typeId,
      "colorId": colorId,
      "productPrice": productPrice,
      "productDesc": productDesc,
      "productMinimumStock": productMinimumStock,
      "productQty": productQty,
      // "colors": colors
    };
    print(_body);
    try {
      final Response response =
          await ApiClient().put('/product', _body, headers: _headers);
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
