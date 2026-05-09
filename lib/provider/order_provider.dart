import 'dart:async';
import 'package:flutter/material.dart';
import '../models/order.dart';
import '../service/order_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<CafeOrder> _orders = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<CafeOrder>>? _subscription;

  List<CafeOrder> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  String? get error => _error;

  void listenToOrders(String uid) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _orderService.getUserOrders(uid).listen(
      (orders) {
        _orders = orders;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Failed to load orders.';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Returns the new order ID.
  Future<String> placeOrder(CafeOrder order) async {
    try {
      return await _orderService.placeOrder(order);
    } catch (e) {
      _error = 'Failed to place order. Please try again.';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      await _orderService.cancelOrder(orderId, reason);
    } catch (e) {
      _error = 'Failed to cancel order.';
      notifyListeners();
      rethrow;
    }
  }

  void clearOrders() {
    _subscription?.cancel();
    _orders = [];
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
