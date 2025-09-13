import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Place a new order and return the DocumentReference
  Future<DocumentReference> placeOrder(CafeOrder order) async {
    final docRef = await _firestore.collection('orders').add(order.toMap());
    return docRef;
  }

  /// Stream all orders for a given customer UID
  Stream<List<CafeOrder>> getUserOrders(String uid) {
    return _firestore
        .collection('orders')
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => CafeOrder.fromFirestore(doc)).toList());
  }

  /// Stream a single order by ID
  Stream<CafeOrder> getOrderById(String orderId) {
    return _firestore
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .map((doc) => CafeOrder.fromFirestore(doc));
  }

  /// Update order status (admin use)
  Future<void> updateOrderStatus(String orderId, String status, {String? reason}) async {
    await _firestore.collection('orders').doc(orderId).update({'status': status});
  }
}
