import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/menu_items.dart';
import '../../models/cart_item.dart';
import '../../provider/cart_provider.dart';
import '../../provider/auth_provider.dart';
import '../../service/cart_service.dart';
import '../components/customer_menu_card.dart';

class ProductDetailScreen extends StatefulWidget {
  final MenuItem item;

  const ProductDetailScreen({super.key, required this.item});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool showFullDescription = false;

  Stream<List<MenuItem>> fetchSimilarItems(String category, String currentId) {
    return FirebaseFirestore.instance
        .collection('menuItems')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MenuItem.fromMap(doc.data(), doc.id))
              .where((item) => item.menuId != currentId)
              .toList();
        });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = widget.item;
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authProvider = Provider.of<AuthenticationProvider>(
      context,
      listen: false,
    );
    final userUid = authProvider.user?.uid ?? '';
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Image
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                    child: Image.network(
                      item.imageUrl,
                      height: screenWidth * 0.8,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _themedIconButton(context, Icons.arrow_back, () {
                          Navigator.pop(context);
                        }),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Product Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.category,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      showFullDescription || item.description.length <= 80
                          ? item.description
                          : '${item.description.substring(0, 80)}...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.9),
                      ),
                    ),
                    if (item.description.length > 80)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            showFullDescription = !showFullDescription;
                          });
                        },
                        child: Text(
                          showFullDescription ? 'See less' : 'See more',
                          style: TextStyle(color: theme.colorScheme.primary),
                        ),
                      ),
                    const SizedBox(height: 14),

                    // Add to Cart Button
                    ElevatedButton.icon(
                      icon: Icon(
                        Icons.add_shopping_cart,
                        color: theme.colorScheme.onPrimary,
                      ),
                      label: const Text("Add to cart"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        minimumSize: const Size.fromHeight(45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        cartProvider.addToCart(item, 1);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item.name} added to cart!'),
                          ),
                        );

                        final firebaseItems =
                            cartProvider.items
                                .map(
                                  (entry) => CartItem(
                                    menuId: entry.menuItem.menuId ?? '',
                                    name: entry.menuItem.name,
                                    imageUrl: entry.menuItem.imageUrl,
                                    price: entry.menuItem.price,
                                    subtitle: entry.menuItem.description,
                                    quantity: entry.quantity,
                                  ),
                                )
                                .toList();

                        await CartService().saveCart(userUid, firebaseItems);
                      },
                    ),
                    const SizedBox(height: 24),

                    // Similar Items
                    Text(
                      "Similar Items",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              StreamBuilder<List<MenuItem>>(
                stream: fetchSimilarItems(item.category, item.menuId ?? ''),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final similarItems = snapshot.data!;

                  if (similarItems.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text("No similar items found."),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children:
                            similarItems.map((menuItem) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: SizedBox(
                                  width: 150,
                                  child: CustomerMenuCard(
                                    item: menuItem,
                                    showDescription: false,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _themedIconButton(
    BuildContext context,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.85),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: theme.colorScheme.onSurface),
      ),
    );
  }
}
