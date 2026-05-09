import 'package:flutter/material.dart';
import '../models/menu_items.dart';
import '../service/menu_service.dart';

class MenuProvider extends ChangeNotifier {
  final MenuService _menuService = MenuService();

  List<MenuItem> _menuItems = [];
  bool _isLoading = false;
  String? _error;

  List<MenuItem> get menuItems => List.unmodifiable(_menuItems);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMenuItems() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _menuItems = await _menuService.getAllMenuItems();
    } catch (e) {
      _error = 'Failed to load menu. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
