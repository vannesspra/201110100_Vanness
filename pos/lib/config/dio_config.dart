import 'package:dio/dio.dart';
import 'package:example/services/auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jwt_decode/jwt_decode.dart';

class ApiClient {
  static Dio dio() {
    BaseOptions options = new BaseOptions(
      connectTimeout: 10000,
      receiveTimeout: 5000,
      baseUrl: dotenv.env['BASE_URL']!,
    );

    var _dio = Dio(options);
    _dio.options.extra['withCredentials'] = true;
    return _dio;
  }

  Future<Response> fetch(String endpoint,
      {Map<String, dynamic>? headers, CancelToken? cancelToken}) async {
    try {
      if (headers != null) {
        var token = headers['authorization'].toString().split(' ');
        var payload = Jwt.parseJwt(token[1]);
        var currentDate = DateTime.now();

        if (payload['exp'] * 1000 < currentDate.millisecondsSinceEpoch) {
          print("EXPIRED");
          var res = await AuthService().refreshToken();
          // prefs.setString('accessToken', res.data['accessToken']);
          // accessToken = prefs.getString('accessToken');
          headers['authorization'] = "Bearer ${res.data['accessToken']}";
        }
      }
      final response = await dio().get(
        Uri.encodeFull(endpoint),
        queryParameters: headers,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> post(String endpoint, dynamic data,
      {Map<String, dynamic>? headers, Options? options}) async {
    try {
      if (headers != null) {
        var token = headers['authorization'].toString().split(' ');
        var payload = Jwt.parseJwt(token[1]);
        var currentDate = DateTime.now();

        if (payload['exp'] * 1000 < currentDate.millisecondsSinceEpoch) {
          print("EXPIRED");
          var res = await AuthService().refreshToken();
          // prefs.setString('accessToken', res.data['accessToken']);
          // accessToken = prefs.getString('accessToken');
          headers['authorization'] = "Bearer ${res.data['accessToken']}";
        }
      }
      final response = await dio().post(Uri.encodeFull(endpoint),
          data: data, queryParameters: headers, options: options);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> put(String endpoint, dynamic data,
      {Map<String, dynamic>? headers}) async {
    try {
      if (headers != null) {
        var token = headers['authorization'].toString().split(' ');
        var payload = Jwt.parseJwt(token[1]);
        var currentDate = DateTime.now();

        if (payload['exp'] * 1000 < currentDate.millisecondsSinceEpoch) {
          print("EXPIRED");
          var res = await AuthService().refreshToken();
          // prefs.setString('accessToken', res.data['accessToken']);
          // accessToken = prefs.getString('accessToken');
          headers['authorization'] = "Bearer ${res.data['accessToken']}";
        }
      }
      final response = await dio().put(
        Uri.encodeFull(endpoint),
        data: data,
        queryParameters: headers,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
