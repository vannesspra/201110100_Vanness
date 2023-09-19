import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/dio_config.dart';
import '../models/activityLog.dart';
import '../models/api_response.dart';

class logService {
  Future<ApiResponse> getLogs() async {
    ApiResponse apiResponse = ApiResponse();
    List<ActivityLog> logs = <ActivityLog>[];
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      Map<String, String> _headers = {
        "authorization": "Bearer ${accessToken}",
      };

      final Response response =
          await ApiClient().fetch('/logs', headers: _headers);
      print(response.data);
      response.data['data'].forEach((data) {
        logs.add(ActivityLog.fromJson(data));
      });
      apiResponse = ApiResponse(
          message: response.data['message'],
          status: response.data['status'],
          data: logs);
      return apiResponse;
    } on DioError catch (e) {
      print('Error sending request ${e.message}!');
    }
    return apiResponse;
  }
}
