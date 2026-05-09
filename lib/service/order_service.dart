import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart';
import '../models/enums.dart';
import '../core/constants/firestore_paths.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Place a new order. Writes orderId into the document atomically.
  Future<String> placeOrder(CafeOrder order) async {
    final docRef =
        _firestore.collection(FirestorePaths.orders).doc();
    final data = order.toMap();
    data['orderId'] = docRef.id;
    await docRef.set(data);
    return docRef.id;
  }

  /// Real-time stream of all orders for a customer.
  Stream<List<CafeOrder>> getUserOrders(String uid) {
    return _firestore
        .collection(FirestorePaths.orders)
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => CafeOrder.fromFirestore(d)).toList());
  }

  /// Real-time stream of a single order — used by tracking screen.
  Stream<CafeOrder> getOrderById(String orderId) {
    return _firestore
        .collection(FirestorePaths.orders)
        .doc(orderId)
        .snapshots()
        .map((doc) => CafeOrder.fromFirestore(doc));
  }

  Future<void> cancelOrder(String orderId, String reason) async {
    await _firestore
        .collection(FirestorePaths.orders)
        .doc(orderId)
        .update({
      'status': OrderStatus.cancelled.name,
      'cancellationReason': reason,
    });
  }

  Future<void> markAsRated(String orderId) async {
    await _firestore
        .collection(FirestorePaths.orders)
        .doc(orderId)
        .update({'hasRated': true});
  }
}
