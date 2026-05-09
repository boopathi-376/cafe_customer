import 'package:flutter/material.dart';
import 'package:cafe/models/menu_items.dart';
import 'package:cafe/view/product_screen.dart';

class CustomerMenuCard extends StatelessWidget {
  final MenuItem item;
  final bool showDescription;

  const CustomerMenuCard({
    super.key,
    required this.item,
    this.showDescription = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    final double cardPadding = 6;
    final double cardRadius = 12;
    final double fontSize = screenWidth <= 360 ? 12 : 13;
    final double imageHeight = (screenWidth - 48) / 2 * 0.68;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailScreen(item: item),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(cardRadius)),
                  child: Image.network(
                    item.imageUrl,
                    height: imageHeight,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: imageHeight,
                      color: colorScheme.surfaceContainerHighest,
                      child: const Center(child: Icon(Icons.broken_image)),
                    ),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return SizedBox(
                        height: imageHeight,
                        child: Center(
                          child: CircularProgressIndicator(color: colorScheme.primary),
                        ),
                      );
                    },
                  ),
                ),


                // ⭐ Rating (bottom left or right)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          item.averageRating.toStringAsFixed(1), // e.g. 4.5
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (showDescription)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        item.description.length > 40
                            ? "${item.description.substring(0, 40)}..."
                            : item.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: fontSize * 0.85,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        "₹${item.price.toStringAsFixed(2)}",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.add, color: Colors.white, size: fontSize + 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
