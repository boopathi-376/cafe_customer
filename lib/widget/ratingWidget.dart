import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final Function(double) onRatingChanged;
  final int starCount;

  const StarRating({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.starCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(starCount, (index) {
        final filled = index < rating;
        return IconButton(
          icon: Icon(
            filled ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 30,
          ),
          onPressed: () => onRatingChanged(index + 1.0),
        );
      }),
    );
  }
}
