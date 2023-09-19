import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/dio_config.dart';
import '../models/adjustment.dart';
import '../models/api_response.dart';

class AdjustmentService {
  Future<ApiResponse> getAdjustments() async {
    ApiResponse apiResponse = ApiResponse();
    List<Adjustment> adjustments = <Adjustment>[];
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      Map<String, String> _headers = {
        "authorization": "Bearer ${accessToken}",
      };

      final Response response =
          await ApiClient().fetch('/adjustments', headers: _headers);
      print(response.data);
      response.data['data'].forEach((data) {
        adjustments.add(Adjustment.fromJson(data));
      });
      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: adjustments);
      return apiResponse;
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }

  Future<ApiResponse> postAdjustment({
    required String adjustmentCode,
    required String adjustedQty,
    int? productId,
    int? materialId,
    int? fabricatingMaterialId,
    String? adjustmentReason,
    String? adjustmentDesc,
  }) async {
    ApiResponse apiResponse = ApiResponse();
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    Map<String, String> _headers = {
      "authorization": "Bearer ${accessToken}",
    };
    Map<String, dynamic> _body = {
      "adjustmentCode": adjustmentCode,
      "adjustedQty": adjustedQty,
      "materialId": materialId,
      "productId": productId,
      "fabricatingMaterialId": fabricatingMaterialId,
      "adjustmentReason": adjustmentReason,
      "adjustmentDesc": adjustmentDesc
    };
    print(_body);
    try {
      final Response response =
          await ApiClient().post('/adjustment', _body, headers: _headers);
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
