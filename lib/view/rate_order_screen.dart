import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/rating_provider.dart';
import '../service/rating_service.dart';
import '../widget/ratingWidget.dart';

class RateOrderScreen extends StatefulWidget {
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
  State<RateOrderScreen> createState() => _RateOrderScreenState();
}

class _RateOrderScreenState extends State<RateOrderScreen> {
  @override
  void initState() {
    super.initState();
    // Reset any stale state from a previous rating session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RatingProvider>(context, listen: false).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Rate Your Order')),
      body: FutureBuilder<bool>(
        future: RatingService()
            .hasRated(widget.orderId, widget.menuItemId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data == true) {
            return const Center(
                child: Text('You already rated this order.'));
          }

          return Consumer<RatingProvider>(
            builder: (context, ratingProvider, _) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('How was your order?',
                        style: theme.textTheme.titleLarge),
                    const SizedBox(height: 24),
                    StarRating(
                      rating: ratingProvider.rating,
                      onRatingChanged: ratingProvider.updateRating,
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Leave a comment (optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      onChanged: ratingProvider.updateComment,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: ratingProvider.isSubmitting ||
                                ratingProvider.rating == 0
                            ? null
                            : () async {
                                await ratingProvider.submitRating(
                                  orderId: widget.orderId,
                                  userId: widget.userId,
                                  menuItemId: widget.menuItemId,
                                );
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content:
                                      Text('Thank you for rating!'),
                                ));
                                Navigator.pop(context);
                              },
                        child: ratingProvider.isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white),
                              )
                            : const Text('Submit Rating'),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
