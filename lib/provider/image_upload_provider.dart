import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../service/image_service.dart';

class ImageUploadProvider with ChangeNotifier {
  XFile? _imageFile;
  bool _isUploading = false;
  String? _imageUrl;
  String? _error;

  XFile? get imageFile => _imageFile;
  bool get isUploading => _isUploading;
  String? get imageUrl => _imageUrl;
  String? get error => _error;

  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        _imageFile = pickedFile;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

// Make sure this import exists

  Future<void> uploadImage() async {
    if (_imageFile == null) return;

    _isUploading = true;
    notifyListeners();

    try {
      final file = File(_imageFile!.path); // Convert XFile to File

      final imageService = ImageService();
      final uploadedUrl = await imageService.uploadImageToCloudinary(file);

      if (uploadedUrl != null) {
        _imageUrl = uploadedUrl;
        await imageService.saveImageUrlToFirestore(_imageUrl!);
        _error = null;
      } else {
        _error = 'Image upload failed.';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }


  void clearImage() {
    _imageFile = null;
    _imageUrl = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}