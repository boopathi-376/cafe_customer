import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItem {
  final String? menuId; // ✅ renamed from id
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final bool isAvailable;
  final bool isFeatured;
  final String? specialTag;
  final double? specialPrice;
  final DateTime? specialDate;

  final double totalRating;
  final int ratingCount;

  MenuItem({
    this.menuId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.isAvailable,
    required this.isFeatured,
    this.specialTag,
    this.specialPrice,
    this.specialDate,
    this.totalRating = 0.0,
    this.ratingCount = 0,
  });

  double get averageRating =>
      ratingCount == 0 ? 0.0 : totalRating / ratingCount;

  factory MenuItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MenuItem(
      menuId: doc.id, // ✅ changed to menuId
      name: data['name'],
      description: data['description'],
      price: (data['price'] as num).toDouble(),
      category: data['category'],
      imageUrl: data['imageUrl'],
      isAvailable: data['isAvailable'],
      isFeatured: data['isFeatured'],
      specialTag: data['specialTag'],
      specialPrice: data['specialPrice'] != null
          ? (data['specialPrice'] as num).toDouble()
          : null,
      specialDate: data['specialDate'] != null
          ? (data['specialDate'] as Timestamp).toDate()
          : null,
      totalRating: (data['totalRating'] ?? 0.0).toDouble(),
      ratingCount: (data['ratingCount'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'menuId': menuId, // ✅ added for consistency
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'isFeatured': isFeatured,
      'specialTag': specialTag,
      'specialPrice': specialPrice,
      'specialDate': specialDate,
      'totalRating': totalRating,
      'ratingCount': ratingCount,
    };
  }

  MenuItem copyWith({
    String? menuId,
    String? name,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    bool? isAvailable,
    bool? isFeatured,
    String? specialTag,
    double? specialPrice,
    DateTime? specialDate,
    double? totalRating,
    int? ratingCount,
  }) {
    return MenuItem(
      menuId: menuId ?? this.menuId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      isFeatured: isFeatured ?? this.isFeatured,
      specialTag: specialTag ?? this.specialTag,
      specialPrice: specialPrice ?? this.specialPrice,
      specialDate: specialDate ?? this.specialDate,
      totalRating: totalRating ?? this.totalRating,
      ratingCount: ratingCount ?? this.ratingCount,
    );
  }

  factory MenuItem.fromMap(Map<String, dynamic> map, String id) {
    return MenuItem(
      menuId: id, // ✅ changed from id
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] as num).toDouble(),
      category: map['category'] ?? 'Uncategorized',
      imageUrl: map['imageUrl'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
      isFeatured: map['isFeatured'] ?? false,
      specialTag: map['specialTag'],
      specialPrice: map['specialPrice'] != null
          ? (map['specialPrice'] as num).toDouble()
          : null,
      specialDate: map['specialDate'] != null
          ? (map['specialDate'] as Timestamp).toDate()
          : null,
      totalRating: (map['totalRating'] ?? 0.0).toDouble(),
      ratingCount: (map['ratingCount'] ?? 0),
    );
  }
}
