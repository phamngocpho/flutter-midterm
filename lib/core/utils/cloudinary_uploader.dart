import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class CloudinaryUploader {
  CloudinaryUploader._();

  static Future<String> uploadImage({
    String? filePath,
    Uint8List? webBytes,
    String fileName = 'upload.jpg',
  }) async {
    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
    final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];

    if (cloudName == null || uploadPreset == null) {
      throw Exception('Cloudinary env missing: CLOUDINARY_CLOUD_NAME or CLOUDINARY_UPLOAD_PRESET');
    }

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset;

    if (kIsWeb) {
      if (webBytes == null) throw Exception('webBytes is required on web');
      final mime = lookupMimeType(fileName) ?? 'image/jpeg';
      final parts = mime.split('/');
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          webBytes,
          filename: fileName,
          contentType: MediaType(parts[0], parts[1]),
        ),
      );
    } else {
      if (filePath == null) throw Exception('filePath is required on mobile/desktop');
      final mime = lookupMimeType(filePath) ?? 'image/jpeg';
      final parts = mime.split('/');
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          filePath,
          contentType: MediaType(parts[0], parts[1]),
        ),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode != 200) {
      throw Exception('Cloudinary upload failed: ${response.statusCode} ${response.body}');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final secureUrl = json['secure_url'] as String?;
    if (secureUrl == null || secureUrl.isEmpty) {
      throw Exception('Cloudinary response missing secure_url');
    }
    return secureUrl;
  }
}


