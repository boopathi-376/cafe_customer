import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/menu_items.dart';

class CartEntry {
  final MenuItem menuItem;
  int quantity;
  CartEntry({required this.menuItem, required this.quantity});
}

class CartProvider with ChangeNotifier {
  final List<CartEntry> _items = [];

  List<CartEntry> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;

  double get totalAmount => _items.fold(
      0, (sum, e) => sum + e.menuItem.price * e.quantity);

  void addToCart(MenuItem item, int quantity) {
    final index =
        _items.indexWhere((e) => e.menuItem.menuId == item.menuId);
    if (index != -1) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartEntry(menuItem: item, quantity: quantity));
    }
    notifyListeners();
  }

  void removeFromCart(MenuItem item) {
    _items.removeWhere((e) => e.menuItem.menuId == item.menuId);
    notifyListeners();
  }

  void updateQuantity(MenuItem item, int change) {
    final index =
        _items.indexWhere((e) => e.menuItem.menuId == item.menuId);
    if (index == -1) return;
    _items[index].quantity += change;
    if (_items[index].quantity <= 0) _items.removeAt(index);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  /// Loads cart from Firestore CartItem list.
  /// Builds MenuItem directly from CartItem data — no separate menu fetch needed.
  void loadFromCartItems(List<CartItem> cartItems) {
    _items.clear();
    for (final cart in cartItems) {
      final menuItem = MenuItem(
        menuId: cart.menuId,
        name: cart.name,
        description: cart.subtitle ?? '',
        imageUrl: cart.imageUrl,
        price: cart.price,
        category: '',
        isAvailable: true,
        isFeatured: false,
      );
      _items.add(CartEntry(menuItem: menuItem, quantity: cart.quantity));
    }
    notifyListeners();
  }
}
