import 'package:dio/dio.dart';

import 'network_service.dart';

class RequestHandler {
  // Dinamik GET request
  Future<Response> get<T>({
    required String url,
    Map<String, dynamic>? queryParameters,
    bool useAuthorization = false,
  }) async {
    return await NetworkService.request<T>(
      url: url,
      method: 'GET',
      queryParameters: queryParameters,
      useAuthorization: useAuthorization,
    );
  }

  // Dinamik POST request
  Future<Response> post<T>({
    required String url,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool useAuthorization = false,
  }) async {
    return await NetworkService.request<T>(
      url: url,
      method: 'POST',
      data: data,
      queryParameters: queryParameters,
      useAuthorization: useAuthorization,
    );
  }

  // Dinamik PUT request
  Future<Response> put<T>({
    required String url,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool useAuthorization = false,
  }) async {
    return await NetworkService.request<T>(
      url: url,
      method: 'PUT',
      data: data,
      queryParameters: queryParameters,
      useAuthorization: useAuthorization,
    );
  }

  // Dinamik DELETE request
  Future<Response> delete<T>({
    required String url,
    Map<String, dynamic>? queryParameters,
    bool useAuthorization = false,
  }) async {
    return await NetworkService.request<T>(
      url: url,
      method: 'DELETE',
      queryParameters: queryParameters,
      useAuthorization: useAuthorization,
    );
  }
}
