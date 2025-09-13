import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/ratingProvider.dart';
import '../service/ratingService.dart';
import '../widget/ratingWidget.dart';



class RateOrderScreen extends StatelessWidget {
  final String orderId;
  final String userId;
  final String menuItemId;

  const RateOrderScreen({
    super.key,
    required this.orderId,
    required this.userId,
    required this.menuItemId,
  });

  @override
  Widget build(BuildContext context) {
    final ratingProvider = Provider.of<RatingProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Rate Your Order")),
      body: FutureBuilder<bool>(
        future: RatingService().hasRated(orderId, menuItemId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          if (snapshot.data == true) {
            return const Center(child: Text("You already rated this order."));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                StarRating(
                  rating: ratingProvider.rating,
                  onRatingChanged: ratingProvider.updateRating,
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Leave a comment (optional)",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onChanged: ratingProvider.updateComment,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: ratingProvider.isSubmitting
                      ? null
                      : () async {
                    await ratingProvider.submitRating(
                      orderId: orderId,
                      userId: userId,
                      menuItemId: menuItemId,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Thank you for rating!")),
                    );

                    Navigator.pop(context);
                  },
                  child: ratingProvider.isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text("Submit"),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
