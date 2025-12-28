import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Generic POST request
  static Future<Map<String, dynamic>> post({
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
  static Future<Map<String, dynamic>> get({
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
  static Future<Map<String, dynamic>> put({
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
  static Future<Map<String, dynamic>> delete({
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
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    // Try to parse response body
    Map<String, dynamic> responseData;
    try {
      responseData = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      responseData = {'message': response.body};
    }

    // Handle different status codes
    if (statusCode >= 200 && statusCode < 300) {
      // Success
      return responseData;
    } else if (statusCode == 400) {
      // Bad request
      throw Exception(responseData['message'] ?? 'Invalid request');
    } else if (statusCode == 401) {
      // Unauthorized
      throw Exception(responseData['message'] ?? 'Unauthorized');
    } else if (statusCode == 403) {
      // Forbidden
      throw Exception(responseData['message'] ?? 'Access forbidden');
    } else if (statusCode == 404) {
      // Not found
      throw Exception(responseData['message'] ?? 'Resource not found');
    } else if (statusCode == 409) {
      // Conflict
      throw Exception(responseData['message'] ?? 'Resource conflict');
    } else if (statusCode >= 500) {
      // Server error
      throw Exception(responseData['message'] ?? 'Server error');
    } else {
      // Other errors
      throw Exception(responseData['message'] ?? 'Unknown error occurred');
    }
  }
}
