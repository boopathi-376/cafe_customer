import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class ImageService {
  final String cloudName = 'ddsludtsm';
  final String uploadPreset = 'Cafe Images';

  Future<String?> uploadImageToCloudinary(File imageFile) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    final res = await http.Response.fromStream(response);
    final data = json.decode(res.body);

    if (response.statusCode == 200) {
      return data['secure_url'];
    } else {
      print('Cloudinary upload failed: ${data['error']['message']}');
      return null;
    }
  }

  Future<void> saveImageUrlToFirestore(String imageUrl) async {
    await FirebaseFirestore.instance.collection('images').add({
      'url': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> uploadAndSave(File imageFile) async {
    final imageUrl = await uploadImageToCloudinary(imageFile);
    if (imageUrl != null) {
      await saveImageUrlToFirestore(imageUrl);
      print('Image uploaded and URL saved to Firestore.');
    } else {
      print('Failed to upload image.');
    }
  }
}
