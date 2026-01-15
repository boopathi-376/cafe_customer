import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save cart items to Firestore
  Future<void> saveCart(String uid, List<CartItem> items) async {
    try {
      await _firestore.collection('carts').doc(uid).set({
        'items': items.map((e) => e.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Error saving cart: $e');
      rethrow;
    }
  }

  /// Fetch cart items from Firestore
  Future<List<CartItem>> fetchCart(String uid) async {
    try {
      final doc = await _firestore.collection('carts').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        final itemList = (data?['items'] ?? []) as List<dynamic>;
        return itemList.map((e) => CartItem.fromMap(e)).toList();
      }
    } catch (e) {
      print('❌ Error fetching cart: $e');
    }
    return [];
  }

  /// Clear cart in Firestore
  Future<void> clearCart(String uid) async {
    try {
      await _firestore.collection('carts').doc(uid).delete();
    } catch (e) {
      debugPrint('❌ Error clearing cart: $e');
    }
  }
}
