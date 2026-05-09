import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/utils/app_logger.dart';

class ImageService {
  // Use an unsigned upload preset configured in your Cloudinary dashboard.
  // Never put API secret here — unsigned presets are safe for mobile clients.
  final String _cloudName = 'ddsludtsm';
  final String _uploadPreset = 'Cafe Images';

  Future<String?> uploadImageToCloudinary(File imageFile) async {
    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(
          await http.MultipartFile.fromPath('file', imageFile.path));

    try {
      final response = await request.send();
      final res = await http.Response.fromStream(response);
      final data = json.decode(res.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return data['secure_url'] as String?;
      } else {
        AppLogger.e(
            'Cloudinary upload failed',
            data['error']?['message'] ?? 'Unknown error');
        return null;
      }
    } catch (e, s) {
      AppLogger.e('Cloudinary upload exception', e, s);
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
      AppLogger.i('Image uploaded and URL saved to Firestore.');
    } else {
      AppLogger.w('Failed to upload image.');
    }
  }
}
