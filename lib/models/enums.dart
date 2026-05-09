enum OrderStatus {
  pending,
  accepted,
  preparing,
  ready,
  outForDelivery,
  delivered,
  completed,
  cancelled,
}

extension OrderStatusX on OrderStatus {
  String get label => switch (this) {
        OrderStatus.pending => 'Pending',
        OrderStatus.accepted => 'Accepted',
        OrderStatus.preparing => 'Preparing',
        OrderStatus.ready => 'Ready for Pickup',
        OrderStatus.outForDelivery => 'Out for Delivery',
        OrderStatus.delivered => 'Delivered',
        OrderStatus.completed => 'Completed',
        OrderStatus.cancelled => 'Cancelled',
      };

  bool get isTerminal =>
      this == OrderStatus.delivered ||
      this == OrderStatus.completed ||
      this == OrderStatus.cancelled;

  bool get canCancel => this == OrderStatus.pending;
}

enum AuthStatus { unknown, authenticated, unauthenticated }
