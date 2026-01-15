import 'dart:async';
import 'package:flutter/material.dart';
import '../models/order.dart';
import '../service/order_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<CafeOrder> _orders = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<CafeOrder>>? _ordersSubscription;

  List<CafeOrder> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Listen to orders stream for real-time updates
  void listenToOrders(String customerUid) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _ordersSubscription?.cancel();
    _ordersSubscription = _orderService
        .getUserOrders(customerUid)
        .listen(
          (orders) {
            _orders = orders;
            _isLoading = false;
            notifyListeners();
          },
          onError: (e) {
            _error = e.toString();
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  /// Place an order
  Future<void> placeOrder(CafeOrder order) async {
    try {
      await _orderService.placeOrder(order);
      // No need to re-fetch manually if listening to stream
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Cancel order
  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      await _orderService.cancelOrder(orderId, reason);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Clear all order data (optional for logout or reset)
  void clearOrders() {
    _ordersSubscription?.cancel();
    _orders = [];
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }
}
