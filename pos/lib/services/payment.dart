import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:example/models/order.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/dio_config.dart';
import '../models/sale.dart';
import '../models/payment.dart';
import '../models/api_response.dart';

class PaymentService {
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

  Future<ApiResponse> getPayments() async {
    ApiResponse apiResponse = ApiResponse();
    List<Payment> payments = <Payment>[];
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      Map<String, String> _headers = {
        "authorization": "Bearer ${accessToken}",
      };

      final Response response =
          await ApiClient().fetch('/payments', headers: _headers);
      print("Holy");
      print(response.data['data']);
      response.data['data'].forEach((data) {
        payments.add(Payment.fromJson(data));
      });

      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: payments);
      return apiResponse;
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> postPayment({
    required String paymentCode,
    required String saleId,
    required DateTime paymentDate,
    required String? paymentDesc,
  }) async {
    ApiResponse apiResponse = ApiResponse();
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    Map<String, String> _headers = {
      "authorization": "Bearer ${accessToken}",
    };
    Map<String, dynamic> _body = {
      "paymentCode": paymentCode,
      "paymentDate": paymentDate.toString(),
      "saleId": saleId,
      "paymentDesc": paymentDesc
    };
    print(_body);
    try {
      final Response response =
          await ApiClient().post('/payment', _body, headers: _headers);
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
