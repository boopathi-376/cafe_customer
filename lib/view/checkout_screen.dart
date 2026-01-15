import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/order.dart';
import '../provider/auth_provider.dart';
import '../provider/user_provider.dart';
import '../provider/cart_provider.dart';
import '../service/cart_service.dart';
import '../service/order_service.dart';
import '../models/user.dart';

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
  State<CheckoutSummaryScreen> createState() => _CheckoutSummaryScreenState();
}

class _CheckoutSummaryScreenState extends State<CheckoutSummaryScreen> {
  List<bool> _isSelected = [true, false]; // Delivery, Pickup
  String _orderType = "Delivery";
  String _selectedPaymentMethod = "Card";

  AddressModel? _selectedAddress;
  List<AddressModel> _addresses = [];

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthenticationProvider>(
      context,
      listen: false,
    );
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final uid = authProvider.user?.uid;
    if (uid != null) {
      userProvider.loadUser(uid).then((_) {
        final user = userProvider.user;
        final addrList = user?.addresses ?? [];

        setState(() {
          _addresses = addrList;
          _selectedAddress = addrList.firstWhere(
            (a) => a.isCurrent,
            orElse:
                () =>
                    addrList.isNotEmpty
                        ? addrList.first
                        : AddressModel(
                          address: "No saved addresses",
                          label: "",
                        ),
          );
        });
      });
    }
  }

  Future<void> _placeOrder() async {
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final List<OrderItem> items =
          widget.cartItems.map((item) {
            return OrderItem(
              menuItemId: item['menuItemId'] ?? '',
              name: item['name'] ?? '',
              quantity: item['quantity'] ?? 1,
              price: (item['price'] ?? 0).toDouble(),
            );
          }).toList();

      final double finalAmount =
          _orderType == "Delivery"
              ? widget.totalAmount + 2
              : widget.totalAmount;

      final order = CafeOrder(
        uid: widget.customeruid,
        customerName: widget.customerName,
        customerPhone: widget.customerPhone,
        items: items,
        totalAmount: finalAmount,
        notes:
            _orderType == "Delivery"
                ? _selectedAddress?.address ?? "No address"
                : "Pickup from café",
      );

      final docRef = await OrderService().placeOrder(order);

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(docRef.id)
          .update({'orderId': docRef.id});

      cartProvider.clearCart();
      await CartService().clearCart(widget.customeruid);

      if (!context.mounted) return;

      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Order Placed 🎉"),
              content: Text(
                "Your order was placed successfully.\nOrder ID: ${docRef.id}",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error placing order: $e")));
      }
    }
  }

  Widget _summaryRow(
    String label,
    String value,
    TextTheme textTheme, {
    bool bold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:
              bold
                  ? textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                  : textTheme.bodyMedium,
        ),
        Text(
          value,
          style:
              bold
                  ? textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  )
                  : textTheme.bodyMedium,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text("Checkout"),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
      ),
      body: Column(
        // Main column structure
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Order Type", style: textTheme.titleMedium),
                  const SizedBox(height: 10),
                  ToggleButtons(
                    isSelected: _isSelected,
                    onPressed: (index) {
                      setState(() {
                        _isSelected = [index == 0, index == 1];
                        _orderType = index == 0 ? "Delivery" : "Pickup";
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    selectedColor: colorScheme.onPrimary,
                    fillColor: colorScheme.primary,
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text("Delivery"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text("Pickup"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (_orderType == "Delivery") ...[
                    Text("Delivery Address", style: textTheme.titleMedium),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<AddressModel>(
                      value: _selectedAddress,
                      icon: const Icon(Icons.arrow_drop_down),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items:
                          _addresses.map((address) {
                            return DropdownMenuItem<AddressModel>(
                              value: address,
                              child: Text(
                                "${address.label} - ${address.address}",
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedAddress = value);
                      },
                    ),
                    const SizedBox(height: 24),
                  ],

                  Text("Payment Method", style: textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      RadioListTile(
                        value: 'Card',
                        groupValue: _selectedPaymentMethod,
                        title: const Text("Credit/Debit Card"),
                        secondary: const Icon(Icons.credit_card),
                        onChanged:
                            (value) =>
                                setState(() => _selectedPaymentMethod = value!),
                      ),
                      RadioListTile(
                        value: 'UPI',
                        groupValue: _selectedPaymentMethod,
                        title: const Text("UPI"),
                        secondary: const Icon(Icons.qr_code),
                        onChanged:
                            (value) =>
                                setState(() => _selectedPaymentMethod = value!),
                      ),
                      RadioListTile(
                        value: 'Cash on Delivery',
                        groupValue: _selectedPaymentMethod,
                        title: const Text("Cash on Delivery"),
                        secondary: const Icon(Icons.money),
                        onChanged:
                            (value) =>
                                setState(() => _selectedPaymentMethod = value!),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  colorScheme
                      .surface, // Changed from surfaceContainerHighest to match style
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ), // Only top radius for bottom sheet feel
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                _summaryRow(
                  "Items Total",
                  "₹${widget.totalAmount.toStringAsFixed(2)}",
                  textTheme,
                ),
                const SizedBox(height: 8),
                _summaryRow(
                  "Delivery",
                  _orderType == "Delivery" ? "₹2.00" : "₹0.00",
                  textTheme,
                ),
                const Divider(height: 24),
                _summaryRow(
                  "Total",
                  "₹${_orderType == "Delivery" ? (widget.totalAmount + 2).toStringAsFixed(2) : widget.totalAmount.toStringAsFixed(2)}",
                  textTheme,
                  bold: true,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _placeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Place Order",
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onPrimary,
                      ),
                    ),
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
