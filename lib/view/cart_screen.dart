import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cartItem.dart';
import '../models/menu_items.dart';
import '../models/order.dart';
import '../provider/auth_provider.dart';
import '../provider/cart_provider.dart';
import '../service/cart_service.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCartFromFirebase();
  }

  Future<void> _loadCartFromFirebase() async {
    final auth = Provider.of<AuthenticationProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final cartService = CartService();
    final uid = auth.user?.uid ?? '';

    final cartItems = await cartService.fetchCart(uid);
    final List<MenuItem> allMenuItems = await fetchAllMenuItems();

    cartProvider.loadFromFirestore(cartItems, allMenuItems);

    setState(() => _isLoading = false);
  }

  Future<List<MenuItem>> fetchAllMenuItems() async {
    // TODO: Replace with your actual fetch logic
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
    final cartService = CartService();
    final customerUid = authProvider.user?.uid ?? '';
    final items = cartProvider.items;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('My Cart', style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: colorScheme.surface,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: colorScheme.error),
            onPressed: () => cartProvider.clearCart(),
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? Center(child: Text("Your cart is empty 🛒", style: textTheme.titleMedium))
          : Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                final totalItemPrice = item.menuItem.price * item.quantity;

                return Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                        child: Image.network(
                          item.menuItem.imageUrl,
                          width: 90,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 90,
                            height: 120,
                            color: Colors.grey[300],
                            child: Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.menuItem.name, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(
                                item.menuItem.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  _qtyBtn(Icons.remove, () => cartProvider.updateQuantity(item.menuItem, -1), colorScheme),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Text('${item.quantity}', style: textTheme.bodyMedium),
                                  ),
                                  _qtyBtn(Icons.add, () => cartProvider.updateQuantity(item.menuItem, 1), colorScheme),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12, top: 12),
                        child: Text(
                          '₹${totalItemPrice.toStringAsFixed(2)}',
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          _buildTotalSection(theme, cartProvider, context, authProvider, customerUid, cartService),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: colorScheme.onSurface),
      ),
    );
  }

  Widget _buildTotalSection(
      ThemeData theme,
      CartProvider provider,
      BuildContext context,
      AuthenticationProvider authProvider,
      String customerUid,
      CartService cartService,
      ) {
    final total = provider.totalAmount;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, -2),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total:', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text(
                '₹${total.toStringAsFixed(2)}',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final cartItemsToSave = provider.items.map((item) {
                  return CartItem(
                    menuId: item.menuItem.menuId ?? "",
                    name: item.menuItem.name,
                    imageUrl: item.menuItem.imageUrl,
                    price: item.menuItem.price,
                    subtitle: item.menuItem.description,
                    quantity: item.quantity,
                  );
                }).toList();

                try {
                  await cartService.saveCart(customerUid, cartItemsToSave);

                  final orderItems = provider.items.map((item) => OrderItem(
                    menuItemId: item.menuItem.menuId ?? '',
                    name: item.menuItem.name,
                    quantity: item.quantity,
                    price: item.menuItem.price,
                  ).toMap()).toList();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CheckoutSummaryScreen(
                        totalAmount: provider.totalAmount,
                        cartItems: orderItems,
                        customerName: authProvider.user?.name ?? '',
                        customerPhone: authProvider.user?.phone ?? '',
                        customeruid: customerUid,
                      ),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to save cart. Please try again.")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Proceed to Checkout →',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}