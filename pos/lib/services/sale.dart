import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:example/models/order.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/dio_config.dart';
import '../models/sale.dart';
import '../models/api_response.dart';

class SaleService {
  Future<ApiResponse> getSaleOrder(String saleId) async {
    ApiResponse apiResponse = ApiResponse();
    Order order = Order();
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      Map<String, String> _headers = {
        "authorization": "Bearer ${accessToken}",
        "saleId": saleId
      };

      final Response response =
          await ApiClient().fetch('/sale/order', headers: _headers);
      print(response);

      order = Order.fromJson(response.data['data'][0]);

      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: order);
      return apiResponse;
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> getSaleOrders(String saleId) async {
    ApiResponse apiResponse = ApiResponse();
    List<Order> orders = [];
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      Map<String, String> _headers = {
        "authorization": "Bearer ${accessToken}",
        "saleId": saleId
      };

      final Response response =
          await ApiClient().fetch('/sale/orders', headers: _headers);

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

  Future<ApiResponse> getSaleAvailOrder() async {
    ApiResponse apiResponse = ApiResponse();
    List<Order> orders = <Order>[];
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      Map<String, String> _headers = {
        "authorization": "Bearer ${accessToken}",
      };

      final Response response =
          await ApiClient().fetch('/sale/order/avail', headers: _headers);
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

  Future<ApiResponse> getSales() async {
    ApiResponse apiResponse = ApiResponse();
    List<Sale> sales = <Sale>[];
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      Map<String, String> _headers = {
        "authorization": "Bearer ${accessToken}",
      };
      print("TEST");
      final Response response =
          await ApiClient().fetch('/sales', headers: _headers);
      response.data['data'].forEach((data) {
        sales.add(Sale.fromJson(data));
      });
      print(response.data);
      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: sales);
      return apiResponse;
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> postSale({
    required String saleCode,
    required String? orderCode,
    required DateTime? saleDeadline,
    required DateTime? saleDate,
    required String? paymentType,
    required String? paymentTerm,
    required String? discountOne,
    required String? discountTwo,
    required String? extraDiscount,
    required String? tax,
    required String? saleDesc,
  }) async {
    ApiResponse apiResponse = ApiResponse();
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    Map<String, String> _headers = {
      "authorization": "Bearer ${accessToken}",
    };
    Map<String, dynamic> _body = {
      "saleCode": saleCode,
      "saleDeadline": saleDeadline.toString(),
      "saleDate": saleDate.toString(),
      "paymentType": paymentType,
      "paymentTerm": paymentTerm,
      "discountOnePercentage": discountOne,
      "discountTwoPercentage": discountTwo,
      "extraDiscountPercentage": extraDiscount,
      "tax": tax,
      "saleDesc": saleDesc,
      "orderCode": orderCode
    };
    print(_body);
    try {
      final Response response =
          await ApiClient().post('/sale', _body, headers: _headers);
      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: response.data['data']);
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> updateSale({
    required int saleId,
    required String saleCode,
    required String? orderCode,
    required DateTime? saleDeadline,
    required DateTime? saleDate,
    required String? paymentType,
    required String? paymentTerm,
    required String? discountOne,
    required String? discountTwo,
    required String? extraDiscount,
    required String? tax,
    required String? saleDesc,
  }) async {
    ApiResponse apiResponse = ApiResponse();
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    Map<String, dynamic> _headers = {
      "authorization": "Bearer ${accessToken}",
      "saleId": saleId
    };
    Map<String, dynamic> _body = {
      "saleCode": saleCode,
      "saleDeadline": saleDeadline.toString(),
      "saleDate": saleDate.toString(),
      "paymentType": paymentType,
      "paymentTerm": paymentTerm,
      "discountOnePercentage": discountOne,
      "discountTwoPercentage": discountTwo,
      "extraDiscountPercentage": extraDiscount,
      "tax": tax,
      "saleDesc": saleDesc,
      "orderCode": orderCode
    };
    print(_body);
    try {
      final Response response =
          await ApiClient().put('/sale', _body, headers: _headers);
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
