import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Generic POST request
  static Future<dynamic> post({
    required String url,
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers:
            headers ??
            {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Generic GET request
  static Future<dynamic> get({
    required String url,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers:
            headers ??
            {'Content-Type': 'application/json', 'Accept': 'application/json'},
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Generic PUT request
  static Future<dynamic> put({
    required String url,
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(url),
        headers:
            headers ??
            {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Generic DELETE request
  static Future<dynamic> delete({
    required String url,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers:
            headers ??
            {'Content-Type': 'application/json', 'Accept': 'application/json'},
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Handle HTTP response
  static dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    // Try to parse response body
    dynamic responseData;
    try {
      responseData = jsonDecode(response.body);
    } catch (e) {
      responseData = {'message': response.body};
    }

    // Handle different status codes
    if (statusCode >= 200 && statusCode < 300) {
      // Success
      return responseData;
    } else {
      // Error handling - assuming error response is a Map
      String errorMessage = 'Unknown error occurred';
      if (responseData is Map<String, dynamic>) {
        errorMessage = responseData['message'] ?? errorMessage;
      } else if (responseData is String) {
        errorMessage = responseData;
      }

      if (statusCode == 400) {
        throw Exception(errorMessage);
      } else if (statusCode == 401) {
        throw Exception(errorMessage);
      } else if (statusCode == 403) {
        throw Exception(errorMessage);
      } else if (statusCode == 404) {
        throw Exception(errorMessage);
      } else if (statusCode == 409) {
        throw Exception(errorMessage);
      } else if (statusCode >= 500) {
        throw Exception(errorMessage);
      } else {
        throw Exception(errorMessage);
      }
    }
  }
}
