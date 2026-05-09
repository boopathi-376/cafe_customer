import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item.dart';
import '../core/constants/firestore_paths.dart';
import '../core/utils/app_logger.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveCart(String uid, List<CartItem> items) async {
    try {
      await _firestore.collection(FirestorePaths.carts).doc(uid).set({
        'items': items.map((e) => e.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, s) {
      AppLogger.e('Error saving cart', e, s);
      rethrow;
    }
  }

  Future<List<CartItem>> fetchCart(String uid) async {
    try {
      final doc = await _firestore
          .collection(FirestorePaths.carts)
          .doc(uid)
          .get();
      if (doc.exists) {
        final itemList =
            List<dynamic>.from(doc.data()?['items'] ?? []);
        return itemList
            .map((e) => CartItem.fromMap(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e, s) {
      AppLogger.e('Error fetching cart', e, s);
    }
    return [];
  }

  Future<void> clearCart(String uid) async {
    try {
      await _firestore
          .collection(FirestorePaths.carts)
          .doc(uid)
          .delete();
    } catch (e, s) {
      AppLogger.e('Error clearing cart', e, s);
    }
  }
}
