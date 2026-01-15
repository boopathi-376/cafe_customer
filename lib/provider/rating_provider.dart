import 'package:flutter/material.dart';
import '../models/rating_model.dart';
import '../service/rating_service.dart';

class RatingProvider extends ChangeNotifier {
  double _rating = 0;
  String _comment = '';
  bool _isSubmitting = false;

  double get rating => _rating;
  String get comment => _comment;
  bool get isSubmitting => _isSubmitting;

  void updateRating(double newRating) {
    _rating = newRating;
    notifyListeners();
  }

  void updateComment(String value) {
    _comment = value;
    notifyListeners();
  }

  Future<void> submitRating({
    required String orderId,
    required String userId,
    required String menuItemId,
  }) async {
    _isSubmitting = true;
    notifyListeners();

    final model = RatingModel(
      orderId: orderId,
      userId: userId,
      menuItemId: menuItemId,
      rating: _rating,
      comment: _comment.isEmpty ? null : _comment,
      timestamp: DateTime.now(),
    );

    await RatingService().submitRating(model);

    _isSubmitting = false;
    notifyListeners();
  }

  void reset() {
    _rating = 0;
    _comment = '';
    _isSubmitting = false;
  }
}
