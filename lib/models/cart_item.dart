class CartItem {
  final String menuId; // ✅ renamed from 'id'
  final String name;
  final String imageUrl;
  final double price;
  final String? subtitle;
  int quantity;

  CartItem({
    required this.menuId,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.subtitle,
    this.quantity = 1,
  });

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      menuId: map['menuId'], // ✅ from Firestore or local map
      name: map['name'],
      imageUrl: map['imageUrl'],
      price: (map['price'] ?? 0).toDouble(),
      subtitle: map['subtitle'],
      quantity: map['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'menuId': menuId, // ✅ save menuId not id
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'subtitle': subtitle,
      'quantity': quantity,
    };
  }
}
