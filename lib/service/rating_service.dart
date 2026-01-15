import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/rating_model.dart';

class RatingService {
  final CollectionReference ratingCollection = FirebaseFirestore.instance
      .collection('ratings');

  Future<void> submitRating(RatingModel rating) async {
    final docId = "${rating.orderId}_${rating.menuItemId}";
    await ratingCollection.doc(docId).set(rating.toMap());
  }

  Future<bool> hasRated(String orderId, String menuItemId) async {
    final docId = "${orderId}_${menuItemId}";
    final doc = await ratingCollection.doc(docId).get();
    return doc.exists;
  }
}
