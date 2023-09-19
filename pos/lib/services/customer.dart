import 'package:dio/dio.dart';
import 'package:example/config/dio_config.dart';
import 'package:example/models/api_response.dart';
import 'package:example/models/customer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerServices {
  Future<ApiResponse> getCustomer() async {
    ApiResponse apiResponse = ApiResponse();
    List<Customer> customers = <Customer>[];
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      Map<String, String> _headers = {
        "authorization": "Bearer ${accessToken}",
      };
      final Response response =
          await ApiClient().fetch('/customers', headers: _headers);

      response.data['data'].forEach((data) {
        customers.add(Customer.fromJson(data));
      });
      apiResponse = ApiResponse(
        message: response.data['message'],
        status: response.data['status'],
        data: customers,
      );
      return apiResponse;
    } on DioError catch (e) {
      print('Error Sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> postCustomer({
    required String customerCode,
    required String customerName,
    required String customerAddress,
    required String customerPhoneNumber,
    required String customerEmail,
    required String customerContactPerson,
    required String discountOne,
    required String discountTwo,
    required String paymentType,
    required String paymentTerm,
    required String tax,
    required List<Map<String, String>> extraDiscounts,
  }) async {
    ApiResponse apiResponse = ApiResponse();
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    Map<String, String> _headers = {
      "authorization": "Bearer ${accessToken}",
    };
    Map<String, dynamic> _customerBody = {
      "customerCode": customerCode,
      "customerName": customerName,
      "customerAddress": customerAddress,
      "customerPhoneNumber": customerPhoneNumber,
      "customerEmail": customerEmail,
      "customerContactPerson": customerContactPerson,
      "discountOne": discountOne,
      "discountTwo": discountTwo,
      "paymentType": paymentType,
      "paymentTerm": paymentTerm,
      "tax": tax,
      "extraDiscounts": extraDiscounts
    };
    print(_customerBody);
    try {
      final Response response =
          await ApiClient().post('/customer', _customerBody, headers: _headers);
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

  Future<ApiResponse> updateCustomer({
    required int customerId,
    required String customerName,
    required String customerAddress,
    required String customerPhoneNumber,
    required String customerEmail,
    required String customerContactPerson,
    required String discountOne,
    required String discountTwo,
    required String paymentType,
    required String paymentTerm,
    required String tax,
    required List<Map<String, String>> extraDiscounts,
  }) async {
    ApiResponse apiResponse = ApiResponse();
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    Map<String, dynamic> _headers = {
      "authorization": "Bearer ${accessToken}",
      "customerId": customerId,
    };
    Map<String, dynamic> _customerBody = {
      "customerName": customerName,
      "customerAddress": customerAddress,
      "customerPhoneNumber": customerPhoneNumber,
      "customerEmail": customerEmail,
      "customerContactPerson": customerContactPerson,
      "discountOne": discountOne,
      "discountTwo": discountTwo,
      "paymentType": paymentType,
      "paymentTerm": paymentTerm,
      "tax": tax,
      "extraDiscounts": extraDiscounts,
    };
    try {
      final Response response =
          await ApiClient().put('/customer', _customerBody, headers: _headers);
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

  Future<ApiResponse> removeCustomer({
    required int customerId,
  }) async {
    ApiResponse apiResponse = ApiResponse();
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    Map<String, dynamic> _headers = {
      "authorization": "Bearer ${accessToken}",
      "customerId": customerId,
    };

    try {
      final Response response =
          await ApiClient().put('/customer/delete', null, headers: _headers);
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
