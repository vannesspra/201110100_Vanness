import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/dio_config.dart';
import '../models/order.dart';
import '../models/api_response.dart';

class OrderService {
  Future<ApiResponse> getOrderByCode(String orderCode) async {
    ApiResponse apiResponse = ApiResponse();
    List<Order> orders = <Order>[];
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      Map<String, String> _headers = {
        "authorization": "Bearer ${accessToken}",
        "orderCode": orderCode
      };

      final Response response =
          await ApiClient().fetch('/order', headers: _headers);
      print(response.data);
      response.data['data'].forEach((data) {
        orders.add(Order.fromJson(data));
      });
      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: orders);
      return apiResponse;
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> getOrdersGrouped() async {
    ApiResponse apiResponse = ApiResponse();
    List<Order> orders = <Order>[];
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      Map<String, String> _headers = {
        "authorization": "Bearer ${accessToken}",
      };

      final Response response =
          await ApiClient().fetch('/orders/grouped', headers: _headers);
      response.data['data'].forEach((data) {
        orders.add(Order.fromJson(data));
      });
      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: orders);
      return apiResponse;
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> getOrders() async {
    ApiResponse apiResponse = ApiResponse();
    List<Order> orders = <Order>[];
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      Map<String, String> _headers = {
        "authorization": "Bearer ${accessToken}",
      };

      final Response response =
          await ApiClient().fetch('/orders', headers: _headers);
      response.data['data'].forEach((data) {
        orders.add(Order.fromJson(data));
      });
      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: orders);
      return apiResponse;
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> postOrder({
    required String orderCode,
    required List<Map<String, dynamic>> products,
    required int? customerId,
    required DateTime requestedDeliveryDate,
    required DateTime orderDate,
    required String orderDesc,
  }) async {
    ApiResponse apiResponse = ApiResponse();
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    Map<String, String> _headers = {
      "authorization": "Bearer ${accessToken}",
      "orderCode": orderCode
    };
    Map<String, dynamic> _body = {
      "orderCode": orderCode,
      "products": products,
      "customerId": customerId,
      "orderDate": orderDate.toString(),
      "requestedDeliveryDate": requestedDeliveryDate.toString(),
      "orderDesc": orderDesc
    };
    print(_body);
    try {
      final Response response =
          await ApiClient().post('/order', _body, headers: _headers);
      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: response.data['data']);
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> updateOrder({
    required String orderCode,
    required List<Map<String, dynamic>> products,
    required int? customerId,
    required DateTime requestedDeliveryDate,
    required DateTime orderDate,
    required String orderDesc,
  }) async {
    ApiResponse apiResponse = ApiResponse();
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    Map<String, String> _headers = {
      "authorization": "Bearer ${accessToken}",
      "orderCode": orderCode
    };
    Map<String, dynamic> _body = {
      "orderCode": orderCode,
      "products": products,
      "customerId": customerId,
      "orderDate": orderDate.toString(),
      "requestedDeliveryDate": requestedDeliveryDate.toString(),
      "orderDesc": orderDesc
    };
    print(_body);
    try {
      final Response response =
          await ApiClient().put('/order', _body, headers: _headers);
      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: response.data['data']);
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> checkOrderValid({
    required String orderCode,
  }) async {
    ApiResponse apiResponse = ApiResponse();
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    Map<String, String> _headers = {
      "authorization": "Bearer ${accessToken}",
      "orderCode": orderCode
    };
    Map<String, dynamic> _body = {
      "orderCode": orderCode,
    };
    print(_body);
    try {
      final Response response =
          await ApiClient().post('/order/check', _body, headers: _headers);
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
