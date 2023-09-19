import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/dio_config.dart';
import '../models/delivery.dart';
import '../models/order.dart';
import '../models/api_response.dart';

class DeliveryService {
  Future<ApiResponse> getDeliveryOrder(String deliveryId) async {
    ApiResponse apiResponse = ApiResponse();
    List<Order> orders = <Order>[];
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      Map<String, String> _headers = {
        "authorization": "Bearer ${accessToken}",
        "deliveryId": deliveryId
      };

      final Response response =
          await ApiClient().fetch('/delivery/order', headers: _headers);

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

  Future<ApiResponse> getDeliveries() async {
    ApiResponse apiResponse = ApiResponse();
    List<Delivery> deliveries = <Delivery>[];
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      Map<String, String> _headers = {
        "authorization": "Bearer ${accessToken}",
      };

      final Response response =
          await ApiClient().fetch('/deliveries', headers: _headers);
      response.data['data'].forEach((data) {
        deliveries.add(Delivery.fromJson(data));
      });
      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: deliveries);
      return apiResponse;
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> postDelivery({
    required DateTime deliveryDate,
    required String deliveryCode,
    required List orders,
    required String carPlatNumber,
    required String senderName,
    required String deliveryDesc,
  }) async {
    ApiResponse apiResponse = ApiResponse();
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    Map<String, String> _headers = {
      "authorization": "Bearer ${accessToken}",
    };
    Map<String, dynamic> _body = {
      "deliveryDate": deliveryDate.toString(),
      "deliveryCode": deliveryCode,
      "orders": orders,
      "carPlatNumber": carPlatNumber,
      "senderName": senderName,
      "deliveryDesc": deliveryDesc
    };
    print(_body);
    try {
      final Response response =
          await ApiClient().post('/delivery', _body, headers: _headers);
      print("Response : $response");
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
