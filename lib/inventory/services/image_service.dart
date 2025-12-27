import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();
  
  // --- CONFIGURATION ---
  // Replace these with YOUR actual values from Cloudinary Dashboard
  final String cloudName = "ddkocwzxf"; 
  final String uploadPreset = "RestarauntApp"; 

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

  // 2. Upload Image to Cloudinary (Free & No Auth Rules needed)
  Future<String?> uploadImage(File imageFile) async {
    try {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/upload');
      
      // Create the POST request
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      // Send
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonMap = jsonDecode(responseString);
        
        // Return the secure URL of the uploaded image
        return jsonMap['secure_url'];
      } else {
        print('Upload failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}