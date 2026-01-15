import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';

class CafeOrder {
  final String? id;
  final String uid;
  final String customerName;
  final String customerPhone;
  final List<OrderItem> items;
  final double totalAmount;
  final OrderStatus status; // Changed to Enum
  final DateTime createdAt;
  final String? notes;
  final bool hasRated;

  CafeOrder({
    this.id,
    required this.uid,
    required this.customerName,
    required this.customerPhone,
    required this.items,
    required this.totalAmount,
    this.status = OrderStatus.pending,
    DateTime? createdAt,
    this.notes,
    this.hasRated = false,
  }) : createdAt = createdAt ?? DateTime.now();

  factory CafeOrder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CafeOrder(
      id: doc.id,
      uid: data['uid'] ?? '',
      customerName: data['customerName'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      items:
          (data['items'] as List)
              .map((item) => OrderItem.fromMap(item))
              .toList(),
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'pending'),
        orElse: () => OrderStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      notes: data['notes'],
      hasRated: data['hasRated'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'items': items.map((e) => e.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status.name, // Save as string
      'createdAt': Timestamp.fromDate(createdAt),
      'notes': notes,
      'hasRated': hasRated,
    };
  }

  CafeOrder copyWith({
    String? id,
    String? customerUid,
    String? customerName,
    String? customerPhone,
    List<OrderItem>? items,
    double? totalAmount,
    OrderStatus? status,
    DateTime? createdAt,
    String? notes,
    bool? hasRated,
  }) {
    return CafeOrder(
      id: id ?? this.id,
      uid: customerUid ?? uid,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      hasRated: hasRated ?? this.hasRated,
    );
  }
}

class OrderItem {
  final String menuItemId;
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.menuItemId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      menuItemId: map['menuItemId'] ?? '',
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'menuItemId': menuItemId,
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }

  OrderItem copyWith({
    String? menuItemId,
    String? name,
    int? quantity,
    double? price,
  }) {
    return OrderItem(
      menuItemId: menuItemId ?? this.menuItemId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }
}
