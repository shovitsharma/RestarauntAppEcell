import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; 

class ImageService {
  final ImagePicker _picker = ImagePicker();
  
  
  final String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? ''; 
  final String uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? ''; 

  // 1. Pick Image from Gallery
  Future<File?> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery, 
        imageQuality: 80, 
      );
      if (pickedFile != null) return File(pickedFile.path);
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  // 2. Upload Image to Cloudinary
  Future<String?> uploadImage(File imageFile) async {
    // 3. Safety Check: Stop if keys are missing
    if (cloudName.isEmpty || uploadPreset.isEmpty) {
      print("ERROR: Cloudinary keys are missing! Check your key.env file.");
      print("Current CloudName: '$cloudName'");
      print("Current Preset: '$uploadPreset'");
      return null;
    }

    try {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/upload');
      
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonMap = jsonDecode(responseString);
        return jsonMap['secure_url'];
      } else {
        print('Upload failed with status: ${response.statusCode}');
        // Optional: Print the response body to see why Cloudinary rejected it
        final responseBody = await response.stream.bytesToString();
        print('Response Body: $responseBody'); 
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}