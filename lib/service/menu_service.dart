import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_items.dart';
import '../core/constants/firestore_paths.dart';

class MenuService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<MenuItem>> getAllMenuItems() async {
    final query =
        await _firestore.collection(FirestorePaths.menuItems).get();
    return query.docs.map((doc) => MenuItem.fromFirestore(doc)).toList();
  }

  Future<List<MenuItem>> getFeaturedItems() async {
    final query = await _firestore
        .collection(FirestorePaths.menuItems)
        .where('isFeatured', isEqualTo: true)
        .where('isAvailable', isEqualTo: true)
        .get();
    return query.docs.map((doc) => MenuItem.fromFirestore(doc)).toList();
  }

  Future<List<MenuItem>> getTodaysSpecials() async {
    final today = DateTime.now();
    final startOfDay =
        DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = await _firestore
        .collection(FirestorePaths.menuItems)
        .where('specialDate',
            isGreaterThanOrEqualTo:
                Timestamp.fromDate(startOfDay))
        .where('specialDate',
            isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    return query.docs.map((doc) => MenuItem.fromFirestore(doc)).toList();
  }
}
