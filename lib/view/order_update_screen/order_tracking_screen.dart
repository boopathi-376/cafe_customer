import 'package:flutter/material.dart';
import '../../models/enums.dart';
import '../../models/order.dart';
import '../../service/order_service.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  static const _steps = [
    OrderStatus.pending,
    OrderStatus.accepted,
    OrderStatus.preparing,
    OrderStatus.ready,
    OrderStatus.outForDelivery,
    OrderStatus.delivered,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Order Tracking'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: StreamBuilder<CafeOrder>(
        stream: OrderService().getOrderById(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Order not found.'));
          }

          final order = snapshot.data!;

          if (order.status == OrderStatus.cancelled) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cancel_outlined,
                      size: 64, color: theme.colorScheme.error),
                  const SizedBox(height: 12),
                  Text('Order Cancelled',
                      style: theme.textTheme.titleLarge),
                ],
              ),
            );
          }

          final currentIndex = _steps.indexOf(order.status);
          final safeIndex =
              currentIndex == -1 ? 0 : currentIndex;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Stepper(
              currentStep: safeIndex,
              controlsBuilder: (_, __) => const SizedBox.shrink(),
              steps: List.generate(_steps.length, (index) {
                final status = _steps[index];
                final isCompleted = index < safeIndex;
                final isCurrent = index == safeIndex;

                return Step(
                  title: Row(
                    children: [
                      Text(
                        status.label,
                        style: TextStyle(
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Current',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  content: const SizedBox.shrink(),
                  isActive: isCurrent,
                  state: isCompleted
                      ? StepState.complete
                      : isCurrent
                          ? StepState.editing
                          : StepState.indexed,
                );
              }),
            ),
          );
        },
      ),
    );
  }
}
