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

  List<CartEntry> get items => _items;

  void addToCart(MenuItem item, int quantity) {
    final index = _items.indexWhere((e) => e.menuItem.menuId == item.menuId);
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
    final index = _items.indexWhere((e) => e.menuItem.menuId == item.menuId);
    if (index != -1) {
      _items[index].quantity += change;
      if (_items[index].quantity <= 0) {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  double get totalAmount {
    double total = 0;
    for (var item in _items) {
      total += item.menuItem.price * item.quantity;
    }
    return total;
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  int get itemCount => _items.length;

  void loadFromFirestore(
    List<CartItem> cartItems,
    List<MenuItem> allMenuItems,
  ) {
    _items.clear();

    for (var cart in cartItems) {
      final matched = allMenuItems.firstWhere(
        (item) => item.menuId == cart.menuId, // ✅ FIXED: match with menuId
        orElse:
            () => MenuItem(
              menuId: cart.menuId,
              name: cart.name,
              description: cart.subtitle ?? '',
              imageUrl: cart.imageUrl,
              price: cart.price,
              category: '',
              isAvailable: true,
              isFeatured: false,
            ),
      );

      _items.add(CartEntry(menuItem: matched, quantity: cart.quantity));
    }

    notifyListeners();
  }
}
