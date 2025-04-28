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
    try {
      final response = await requestHandler.get<T>(
        url: url,
        queryParameters: queryParameters,
        useAuthorization: useAuthorization,
      );
      return response.data;  // Olingan natijani qaytarish
    } catch (e) {
      throw Exception('Error while fetching data: $e');
    }
  }

  // Dinamik postData: POST request
  Future<T> postData<T>({
    required String url,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool useAuthorization = false,
  }) async {
    try {
      final response = await requestHandler.post<T>(
        url: url,
        data: data,
        queryParameters: queryParameters,
        useAuthorization: useAuthorization,
      );
      return response.data;  // Olingan natijani qaytarish
    } catch (e) {
      throw Exception('Error while posting data: $e');
    }
  }

  // Dinamik putData: PUT request
  Future<T> putData<T>({
    required String url,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool useAuthorization = false,
  }) async {
    try {
      final response = await requestHandler.put<T>(
        url: url,
        data: data,
        queryParameters: queryParameters,
        useAuthorization: useAuthorization,
      );
      return response.data;  // Olingan natijani qaytarish
    } catch (e) {
      throw Exception('Error while updating data: $e');
    }
  }

  // Dinamik deleteData: DELETE request
  Future<T> deleteData<T>({
    required String url,
    Map<String, dynamic>? queryParameters,
    bool useAuthorization = false,
  }) async {
    try {
      final response = await requestHandler.delete<T>(
        url: url,
        queryParameters: queryParameters,
        useAuthorization: useAuthorization,
      );
      return response.data;  // Olingan natijani qaytarish
    } catch (e) {
      throw Exception('Error while deleting data: $e');
    }
  }
}
