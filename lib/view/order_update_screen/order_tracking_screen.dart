import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final List<String> statuses = [
    'pending',
    'accepted',
    'preparing',
    'ready',
    'outForDelivery',
    'delivered',
    'cancelled',
  ];

  int _currentStep = 0;
  Map<String, dynamic>? orderData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrderData();
  }

  Future<void> fetchOrderData() async {
    final doc = await FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        orderData = data;
        _currentStep = statuses.indexOf(data['status']);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (orderData == null) {
      return const Scaffold(
        body: Center(child: Text("Order not found.")),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor ,
      appBar: AppBar(
        title: const Text("Order Tracking"),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Stepper(
          currentStep: _currentStep,
          controlsBuilder: (_, __) => const SizedBox.shrink(),
          steps: statuses.map((status) {
            final index = statuses.indexOf(status);
            final isCompleted = index < _currentStep;
            final isCurrent = index == _currentStep;

            return Step(
              title: Row(
                children: [
                  Text(
                    status[0].toUpperCase() + status.substring(1),
                    style: TextStyle(
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "Current",
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
              content: const SizedBox(height: 0),
              isActive: isCurrent,
              state: isCompleted
                  ? StepState.complete
                  : isCurrent
                  ? StepState.editing
                  : StepState.indexed,
            );
          }).toList(),
        ),
      ),
    );
  }
}
