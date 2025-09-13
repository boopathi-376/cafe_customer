import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_items.dart';

class MenuService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'menuItems';



  Future<List<MenuItem>> getAllMenuItems() async {
    final query = await _firestore.collection(_collection).get();
    return query.docs.map((doc) => MenuItem.fromFirestore(doc)).toList();
  }

  Future<List<MenuItem>> getFeaturedItems() async {
    final query = await _firestore
        .collection(_collection)
        .where('isFeatured', isEqualTo: true)
        .get();
    return query.docs.map((doc) => MenuItem.fromFirestore(doc)).toList();
  }

  Future<List<MenuItem>> getTodaysSpecials() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = await _firestore
        .collection(_collection)
        .where('specialDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('specialDate', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    return query.docs.map((doc) => MenuItem.fromFirestore(doc)).toList();
  }
}
