import 'package:flutter/material.dart';
import '../models/menu_items.dart';
import '../view/product_screen.dart';

class SpecialItemCard extends StatelessWidget {
  final MenuItem item;

  const SpecialItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive base size
    final double baseSize = screenWidth <= 360
        ? 12
        : screenWidth <= 480
        ? 14
        : 16;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(item: item),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(baseSize * 0.8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(baseSize),
          border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left: Tag + Image
            Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: baseSize * 0.6, vertical: baseSize * 0.4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.specialTag ?? 'Special',
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: baseSize * 0.8,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                SizedBox(height: baseSize * 0.6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(baseSize * 0.75),
                  child: Image.network(
                    item.imageUrl ?? '',
                    height: baseSize * 5,
                    width: baseSize * 5,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: baseSize * 5,
                      width: baseSize * 5,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: baseSize),
            // Right: Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: baseSize,
                    ),
                  ),
                  SizedBox(height: baseSize * 0.3),
                  Text(
                    item.description.length > 60
                        ? '${item.description.substring(0, 60)}...'
                        : item.description,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: baseSize * 0.75,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: baseSize * 0.6),
                  Row(
                    children: [
                      Text(
                        "₹${item.price.toStringAsFixed(2)}",
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: baseSize * 0.9,
                          decoration: TextDecoration.lineThrough,
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (item.specialPrice != null)
                        Text(
                          "₹${item.specialPrice!.toStringAsFixed(2)}",
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: baseSize,
                            color: colorScheme.primary,
                          ),
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
