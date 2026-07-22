import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class DioClient {
  final Dio _dio;

  DioClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            responseType: ResponseType.json,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // You can handle global errors here (e.g. 401 unauthorized logouts)
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;

  /// Custom error mapper for user-friendly notifications
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timed out. Please check your network and try again.';
        case DioExceptionType.badResponse:
          final response = error.response;
          if (response != null && response.data != null) {
            final data = response.data;
            if (data is Map && data.containsKey('message')) {
              return data['message'].toString();
            }
            if (data is Map && data.containsKey('errors')) {
              final errList = data['errors'] as List;
              if (errList.isNotEmpty) {
                return errList.map((e) => e['message']).join('\n');
              }
            }
          }
          return 'Server error occurred (Code: ${response?.statusCode}).';
        case DioExceptionType.cancel:
          return 'Request cancelled by user.';
        case DioExceptionType.connectionError:
          return 'Unable to reach the server. Please ensure the backend is running and online.';
        default:
          return 'An unexpected network error occurred. Please try again.';
      }
    }
    return error?.toString() ?? 'Something went wrong.';
  }
}
