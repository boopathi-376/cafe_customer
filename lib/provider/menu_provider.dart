import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/menu_items.dart';

class MenuProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<MenuItem> _menuItems = [];
  bool _isLoading = false;

  List<MenuItem> get menuItems => _menuItems;
  bool get isLoading => _isLoading;

  Future<void> fetchMenuItems() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore.collection('menuItems').get();
      _menuItems = snapshot.docs.map((doc) => MenuItem.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching menu items: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

}
