import 'package:clinic/core/constants/app_contants.dart';
import 'package:clinic/core/local/local_storage_service.dart';
import 'package:clinic/core/local/storage_keys.dart';
import 'package:clinic/core/network/token_manager.dart';
import 'package:dio/dio.dart';
import 'dart:developer';

import 'package:flutter/widgets.dart';

class NetworkService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl, // API bazaviy URL
      connectTimeout: Duration(minutes: 1),
      receiveTimeout: Duration(minutes: 1),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );
  static GlobalKey<NavigatorState> navigatorKey = TokenManager.navigatorKey;

  // Singleton pattern
  static Dio get dio => _dio;

  static void initializeInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          log('Request [${options.method}] => ${options.uri}');
          log('Headers => ${options.headers}');
          if (options.queryParameters.isNotEmpty) {
            log('Query Parameters => ${options.queryParameters}');
          }
          if (options.data != null) {
            log('Request Data => ${options.data}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Javob qaytganidan keyin: Log
          log('Response [${response.statusCode}] => ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          // Xatolikni qayta ishlash: API va tarmoq xatoliklari
          log('Error [${e.response?.statusCode}] => ${e.message}');

          if (e.response?.statusCode == 401) {
            // TokenManager orqali xatolikni hal qilish
            final response = await TokenManager.handle401Error(e, _dio);
            if (response != null) {
              return handler.resolve(response);
            }
          }

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
      final accesToken =
          await LocalStorageService().getString(StorageKeys.accesToken);
      final options = Options(
        method: method,
        headers:
            useAuthorization ? {} : {'Authorization': 'Bearer $accesToken'},
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
  static DioException _handleError(DioException e) {
    if (e.response != null) {
      // API javobidagi xatolik
      return DioException(
        requestOptions: e.requestOptions,
        response: e.response,
        type: e.type,
        error:
            'Произошла ошибка при выполнении запроса. Пожалуйста, попробуйте позже.',
      );
    } else {
      // Tarmoq bilan bog‘liq xatolik
      return DioException(
        requestOptions: e.requestOptions,
        type: DioExceptionType.unknown,
        error: 'Отсутствует подключение к сети',
      );
    }
  }
}
