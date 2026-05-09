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

  Map<String, dynamic> toMap() => {
        'orderId': orderId,
        'userId': userId,
        'menuItemId': menuItemId,
        'rating': rating,
        'comment': comment,
        'timestamp': Timestamp.fromDate(timestamp),
      };

  factory RatingModel.fromMap(Map<String, dynamic> map) => RatingModel(
        orderId: map['orderId'] as String,
        userId: map['userId'] as String,
        menuItemId: map['menuItemId'] as String,
        rating: (map['rating'] as num).toDouble(),
        comment: map['comment'] as String?,
        timestamp: (map['timestamp'] as Timestamp).toDate(),
      );
}
