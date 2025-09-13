import 'package:cloud_firestore/cloud_firestore.dart';

class RatingModel {
  final String orderId;
  final String userId;
  final String menuItemId;
  final double rating;
  final String? comment;
  final DateTime timestamp;

  RatingModel({
    required this.orderId,
    required this.userId,
    required this.menuItemId,
    required this.rating,
    this.comment,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'menuItemId': menuItemId,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp,
    };
  }

  factory RatingModel.fromMap(Map<String, dynamic> map) {
    return RatingModel(
      orderId: map['orderId'],
      userId: map['userId'],
      menuItemId: map['menuItemId'],
      rating: map['rating'],
      comment: map['comment'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
