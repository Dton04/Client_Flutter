import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../services/storage_service.dart';

class UploadService {
  /// Upload image to Cloudinary
  /// Returns the URL of the uploaded image
  static Future<String> uploadImage(File imageFile) async {
    try {
      final token = StorageService.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.uploadImageUrl),
      );

      // Add headers (without Content-Type, let http package handle it)
      request.headers.addAll(ApiConfig.headersWithTokenNoContentType(token));

      // Add file to request
      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      );
      request.files.add(multipartFile);

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Handle response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final url = responseData['url'] as String?;

        if (url == null) {
          throw Exception('No URL returned from upload');
        }

        return url;
      } else {
        // Try to parse error message
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          throw Exception(errorData['message'] ?? 'Upload failed');
        } catch (e) {
          throw Exception('Upload failed: ${response.body}');
        }
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Upload error: ${e.toString()}');
    }
  }
}
