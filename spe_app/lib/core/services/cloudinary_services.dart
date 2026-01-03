import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  final String cloudName = "YOUR_CLOUD_NAME"; // Ganti
  final String uploadPreset = "YOUR_UPLOAD_PRESET"; // Ganti

  Future<String> uploadImage(File file) async {
    final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    final request = http.MultipartRequest("POST", url)
      ..fields["upload_preset"] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath("file", file.path));

    final response = await request.send();
    final result = await http.Response.fromStream(response);

    if (result.statusCode != 200 && result.statusCode != 201) {
      throw Exception("Cloudinary upload failed: ${result.body}");
    }

    final data = jsonDecode(result.body);
    return data["secure_url"];
  }
}
