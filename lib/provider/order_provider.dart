import 'package:flutter/material.dart';
import '../models/order.dart';
import '../service/order_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<CafeOrder> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<CafeOrder> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch all orders for a customer using UID
  Future<void> fetchOrders(String customerUid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _orderService
          .getUserOrders(customerUid)
          .first; // convert stream to future
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Place an order
  Future<void> placeOrder(CafeOrder order) async {
    try {
      await _orderService.placeOrder(order);
      // Re-fetch orders after placing
      await fetchOrders(order.customerPhone); // or use `uid` field if available
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Clear all order data (optional for logout or reset)
  void clearOrders() {
    _orders = [];
    _error = null;
    notifyListeners();
  }
}
