import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_item.dart';
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
  bool _isLoadingCart = true;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final auth =
        Provider.of<AuthenticationProvider>(context, listen: false);
    final cartProvider =
        Provider.of<CartProvider>(context, listen: false);
    final uid = auth.user?.uid ?? '';
    if (uid.isEmpty) {
      setState(() => _isLoadingCart = false);
      return;
    }
    final cartItems = await CartService().fetchCart(uid);
    cartProvider.loadFromCartItems(cartItems);
    if (mounted) setState(() => _isLoadingCart = false);
  }

  Future<void> _proceedToCheckout(
    CartProvider cartProvider,
    AuthenticationProvider auth,
    String uid,
  ) async {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);

    try {
      final cartItemsToSave = cartProvider.items
          .map((e) => CartItem(
                menuId: e.menuItem.menuId ?? '',
                name: e.menuItem.name,
                imageUrl: e.menuItem.imageUrl,
                price: e.menuItem.price,
                subtitle: e.menuItem.description,
                quantity: e.quantity,
              ))
          .toList();

      await CartService().saveCart(uid, cartItemsToSave);

      final orderItems = cartProvider.items
          .map((e) => OrderItem(
                menuItemId: e.menuItem.menuId ?? '',
                name: e.menuItem.name,
                quantity: e.quantity,
                price: e.menuItem.price,
              ).toMap())
          .toList();

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CheckoutSummaryScreen(
            totalAmount: cartProvider.totalAmount,
            cartItems: orderItems,
            customerName: auth.user?.name ?? '',
            customerPhone: auth.user?.phone ?? '',
            customeruid: uid,
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to save cart. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isNavigating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final cartProvider = Provider.of<CartProvider>(context);
    final auth =
        Provider.of<AuthenticationProvider>(context, listen: false);
    final uid = auth.user?.uid ?? '';
    final items = cartProvider.items;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('My Cart',
            style: tt.titleMedium?.copyWith(color: cs.onSurface)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: cs.surface,
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_outline, color: cs.error),
              onPressed: () async {
                cartProvider.clearCart();
                await CartService().clearCart(uid);
              },
            ),
        ],
      ),
      body: _isLoadingCart
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? Center(
                  child: Text('Your cart is empty 🛒',
                      style: tt.titleMedium))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final entry = items[index];
                          return _CartItemTile(
                            entry: entry,
                            cartProvider: cartProvider,
                            cs: cs,
                            tt: tt,
                          );
                        },
                      ),
                    ),
                    _BottomBar(
                      total: cartProvider.totalAmount,
                      isNavigating: _isNavigating,
                      onCheckout: () => _proceedToCheckout(
                          cartProvider, auth, uid),
                      cs: cs,
                      tt: tt,
                    ),
                  ],
                ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartEntry entry;
  final CartProvider cartProvider;
  final ColorScheme cs;
  final TextTheme tt;

  const _CartItemTile({
    required this.entry,
    required this.cartProvider,
    required this.cs,
    required this.tt,
  });

  @override
  Widget build(BuildContext context) {
    final totalPrice = entry.menuItem.price * entry.quantity;
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
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
              entry.menuItem.imageUrl,
              width: 90,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 90,
                color: Colors.grey[800],
                child: const Icon(Icons.image_not_supported),
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
                  Text(entry.menuItem.name,
                      style: tt.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    entry.menuItem.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: tt.bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _QtyButton(
                        icon: Icons.remove,
                        onTap: () => cartProvider.updateQuantity(
                            entry.menuItem, -1),
                        cs: cs,
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('${entry.quantity}',
                            style: tt.bodyMedium),
                      ),
                      _QtyButton(
                        icon: Icons.add,
                        onTap: () => cartProvider.updateQuantity(
                            entry.menuItem, 1),
                        cs: cs,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 12),
            child: Text(
              '₹${totalPrice.toStringAsFixed(2)}',
              style: tt.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold, color: cs.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme cs;
  const _QtyButton(
      {required this.icon, required this.onTap, required this.cs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: cs.outlineVariant),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: cs.onSurface),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final double total;
  final bool isNavigating;
  final VoidCallback onCheckout;
  final ColorScheme cs;
  final TextTheme tt;

  const _BottomBar({
    required this.total,
    required this.isNavigating,
    required this.onCheckout,
    required this.cs,
    required this.tt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 6, offset: Offset(0, -2))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total:',
                  style: tt.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Text('₹${total.toStringAsFixed(2)}',
                  style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold, color: cs.primary)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isNavigating ? null : onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: isNavigating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text('Proceed to Checkout →',
                      style: tt.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.onPrimary)),
            ),
          ),
        ],
      ),
    );
  }
}
