import 'request_handler.dart';

class NetworkManager {
  final RequestHandler requestHandler;

  NetworkManager({
    required this.requestHandler,
  });

  // Dinamik fetchData: GET request
  Future<T> fetchData<T>({
    required String url,
    Map<String, dynamic>? queryParameters,
    bool useAuthorization = false,
  }) async {
    final response = await requestHandler.get<T>(
      url: url,
      queryParameters: queryParameters,
      useAuthorization: useAuthorization,
    );
    return response.data; // Olingan natijani qaytarish
  }

  // Dinamik postData: POST request
  Future<T> postData<T>({
    required String url,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool useAuthorization = false,
  }) async {
    final response = await requestHandler.post<T>(
      url: url,
      data: data,
      queryParameters: queryParameters,
      useAuthorization: useAuthorization,
    );
    return response.data; // Olingan natijani qaytarish
  }

  // Dinamik putData: PUT request
  Future<T> putData<T>({
    required String url,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool useAuthorization = false,
  }) async {
    final response = await requestHandler.put<T>(
      url: url,
      data: data,
      queryParameters: queryParameters,
      useAuthorization: useAuthorization,
    );
    return response.data; // Olingan natijani qaytarish
  }

  // Dinamik deleteData: DELETE request
  Future<T> deleteData<T>({
    required String url,
    Map<String, dynamic>? queryParameters,
    bool useAuthorization = false,
  }) async {
    final response = await requestHandler.delete<T>(
      url: url,
      queryParameters: queryParameters,
      useAuthorization: useAuthorization,
    );
    return response.data; // Olingan natijani qaytarish
  }
}
