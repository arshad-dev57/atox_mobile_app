import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String uploadPreset = 'atox_uploads'; // Typically you need an upload preset for unsigned uploads
  static const String cloudName = 'doxb5l503'; // Replace with actual cloud name if available, otherwise dummy
  
  static Future<String?> uploadImage(File imageFile, {String folder = 'uploads'}) async {
    try {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      
      final request = http.MultipartRequest('POST', url);
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = folder;
      
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonMap = jsonDecode(responseString);
        return jsonMap['secure_url'] as String;
      }
      return null;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }
}
