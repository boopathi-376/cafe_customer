import 'package:flutter/material.dart';
import '../models/rating_model.dart';
import '../service/rating_service.dart';

class RatingProvider extends ChangeNotifier {
  final RatingService _ratingService = RatingService();

  double _rating = 0;
  String _comment = '';
  bool _isSubmitting = false;
  bool _submitted = false;

  double get rating => _rating;
  String get comment => _comment;
  bool get isSubmitting => _isSubmitting;
  bool get submitted => _submitted;

  void updateRating(double value) {
    _rating = value;
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
    if (_rating == 0) return;
    _isSubmitting = true;
    notifyListeners();
    try {
      final model = RatingModel(
        orderId: orderId,
        userId: userId,
        menuItemId: menuItemId,
        rating: _rating,
        comment: _comment.isEmpty ? null : _comment,
        timestamp: DateTime.now(),
      );
      await _ratingService.submitRating(model);
      _submitted = true;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void reset() {
    _rating = 0;
    _comment = '';
    _isSubmitting = false;
    _submitted = false;
  }
}
