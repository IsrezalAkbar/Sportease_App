import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class CloudinaryService {
  // Cloudinary config provided by the user.
  static const _cloudName = 'dosrtdg22';
  static const _uploadPreset = 'spe_app';

  Future<String> uploadImage(File file) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final url = (data['secure_url'] ?? data['url']) as String?;
      if (url != null && url.isNotEmpty) return url;
      throw Exception('Upload berhasil tetapi URL tidak ditemukan');
    }

    throw Exception('Upload gagal (${response.statusCode}): $body');
  }
}
