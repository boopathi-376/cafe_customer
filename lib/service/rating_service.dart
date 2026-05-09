import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rating_model.dart';
import '../core/constants/firestore_paths.dart';

class RatingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitRating(RatingModel rating) async {
    final docId = '${rating.orderId}_${rating.menuItemId}';
    await _firestore
        .collection(FirestorePaths.ratings)
        .doc(docId)
        .set(rating.toMap());
  }

  Future<bool> hasRated(String orderId, String menuItemId) async {
    final docId = '${orderId}_$menuItemId';
    final doc = await _firestore
        .collection(FirestorePaths.ratings)
        .doc(docId)
        .get();
    return doc.exists;
  }
}
