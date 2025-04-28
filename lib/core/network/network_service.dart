import 'package:dio/dio.dart';
import 'dart:developer';

class NetworkService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.example.com', // API bazaviy URL
      connectTimeout: Duration(minutes: 1),
      receiveTimeout: Duration(minutes: 1),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  // Singleton pattern
  static Dio get dio => _dio;
  static void initializeInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // So'rovdan oldin: Authorization va log
          log('Request [${options.method}] => ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Javob qaytganidan keyin: Log
          log('Response [${response.statusCode}] => ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          // Xatolikni qayta ishlash: API va tarmoq xatoliklari
          log('Error [${e.response?.statusCode}] => ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }

  // Dinamik requestni boshqarish
  static Future<Response> request<T>({
    required String url,
    required String method,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool useAuthorization = false,
  }) async {
    try {
      final options = Options(
        method: method,
        headers: useAuthorization ? {'Authorization': 'Bearer YOUR_TOKEN'} : {},
      );
      Response response = await _dio.request(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Xatoliklarni boshqarish
  static Exception _handleError(DioException e) {
    if (e.response != null) {
      // API javob xatoliklari
      return Exception('API Error: ${e.response?.data}');
    } else {
      // Tarmoq xatoliklari
      return Exception('Network Error: ${e.message}');
    }
  }
}
