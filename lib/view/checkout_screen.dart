import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../models/user.dart';
import '../provider/auth_provider.dart';
import '../provider/cart_provider.dart';
import '../provider/order_provider.dart';
import '../provider/user_provider.dart';
import '../service/cart_service.dart';

class CheckoutSummaryScreen extends StatefulWidget {
  final double totalAmount;
  final List<Map<String, dynamic>> cartItems;
  final String customerName;
  final String customerPhone;
  final String customeruid;

  const CheckoutSummaryScreen({
    super.key,
    required this.totalAmount,
    required this.cartItems,
    required this.customerName,
    required this.customerPhone,
    required this.customeruid,
  });

  @override
  State<CheckoutSummaryScreen> createState() =>
      _CheckoutSummaryScreenState();
}

class _CheckoutSummaryScreenState
    extends State<CheckoutSummaryScreen> {
  List<bool> _isSelected = [true, false];
  String _orderType = 'Delivery';
  String _selectedPaymentMethod = 'Cash on Delivery';
  AddressModel? _selectedAddress;
  List<AddressModel> _addresses = [];
  bool _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    final uid =
        Provider.of<AuthenticationProvider>(context, listen: false)
            .user
            ?.uid;
    if (uid != null) {
      Provider.of<UserProvider>(context, listen: false)
          .loadUser(uid)
          .then((_) {
        if (!mounted) return;
        final user =
            Provider.of<UserProvider>(context, listen: false).user;
        final list = user?.addresses ?? [];
        setState(() {
          _addresses = list;
          _selectedAddress = list.isEmpty
              ? null
              : list.firstWhere((a) => a.isCurrent,
                  orElse: () => list.first);
        });
      });
    }
  }

  Future<void> _placeOrder() async {
    if (_isPlacingOrder) return;
    setState(() => _isPlacingOrder = true);

    try {
      final orderProvider =
          Provider.of<OrderProvider>(context, listen: false);
      final cartProvider =
          Provider.of<CartProvider>(context, listen: false);

      final items = widget.cartItems
          .map((m) => OrderItem(
                menuItemId: m['menuItemId'] as String? ?? '',
                name: m['name'] as String? ?? '',
                quantity: m['quantity'] as int? ?? 1,
                price: (m['price'] as num? ?? 0).toDouble(),
              ))
          .toList();

      final finalAmount = _orderType == 'Delivery'
          ? widget.totalAmount + 2
          : widget.totalAmount;

      final order = CafeOrder(
        uid: widget.customeruid,
        customerName: widget.customerName,
        customerPhone: widget.customerPhone,
        items: items,
        totalAmount: finalAmount,
        notes: _orderType == 'Delivery'
            ? _selectedAddress?.address ?? 'No address'
            : 'Pickup from café',
      );

      final orderId = await orderProvider.placeOrder(order);

      cartProvider.clearCart();
      await CartService().clearCart(widget.customeruid);

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Order Placed 🎉'),
          content: Text(
              'Your order was placed successfully.\nOrder ID: $orderId'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.popUntil(context, (r) => r.isFirst);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Failed to place order. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  Widget _row(String label, String value, TextTheme tt,
      {bool bold = false, Color? color}) {
    final style = bold
        ? tt.titleMedium?.copyWith(
            fontWeight: FontWeight.bold, color: color)
        : tt.bodyMedium;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: bold
                ? tt.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)
                : tt.bodyMedium),
        Text(value, style: style),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final deliveryFee = _orderType == 'Delivery' ? 2.0 : 0.0;
    final total = widget.totalAmount + deliveryFee;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order Type', style: tt.titleMedium),
                  const SizedBox(height: 10),
                  ToggleButtons(
                    isSelected: _isSelected,
                    onPressed: (i) => setState(() {
                      _isSelected = [i == 0, i == 1];
                      _orderType = i == 0 ? 'Delivery' : 'Pickup';
                    }),
                    borderRadius: BorderRadius.circular(10),
                    selectedColor: cs.onPrimary,
                    fillColor: cs.primary,
                    children: const [
                      Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 20),
                          child: Text('Delivery')),
                      Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 20),
                          child: Text('Pickup')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_orderType == 'Delivery') ...[
                    Text('Delivery Address', style: tt.titleMedium),
                    const SizedBox(height: 12),
                    if (_addresses.isEmpty)
                      Text('No saved addresses. Add one in Profile.',
                          style: tt.bodySmall
                              ?.copyWith(color: cs.error))
                    else
                      DropdownButtonFormField<AddressModel>(
                        value: _selectedAddress,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: cs.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: _addresses
                            .map((a) => DropdownMenuItem(
                                  value: a,
                                  child: Text(
                                      '${a.label} — ${a.address}',
                                      overflow:
                                          TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedAddress = v),
                      ),
                    const SizedBox(height: 24),
                  ],
                  Text('Payment Method', style: tt.titleMedium),
                  const SizedBox(height: 8),
                  ...['Cash on Delivery', 'UPI', 'Card'].map(
                    (method) => RadioListTile<String>(
                      value: method,
                      groupValue: _selectedPaymentMethod,
                      title: Text(method),
                      onChanged: (v) => setState(
                          () => _selectedPaymentMethod = v!),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16)),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5))
              ],
            ),
            child: Column(
              children: [
                _row('Items Total',
                    '₹${widget.totalAmount.toStringAsFixed(2)}', tt),
                const SizedBox(height: 8),
                _row('Delivery Fee',
                    '₹${deliveryFee.toStringAsFixed(2)}', tt),
                const Divider(height: 24),
                _row('Total', '₹${total.toStringAsFixed(2)}', tt,
                    bold: true, color: cs.primary),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _isPlacingOrder ? null : _placeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isPlacingOrder
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white),
                          )
                        : Text('Place Order',
                            style: tt.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: cs.onPrimary)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
