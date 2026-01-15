import 'package:flutter/material.dart';
import '../models/category_model.dart';

class CategoryChips extends StatelessWidget {
  final List<CategoryModel> categories;
  final String selected;
  final Function(String) onSelected;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    // Responsive spacing and sizing
    final double iconSize = width * 0.035; // ~14
    final double fontSize = width * 0.032; // ~13
    final double hPadding = width * 0.035; // ~14
    final double vPadding = width * 0.014; // ~5
    final double spacing = width * 0.015; // ~6
    final double chipHeight = 36; // ✅ Compact height

    return SizedBox(
      height: chipHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: spacing),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selected == category.name;

          return Material(
            color:
                isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
            elevation: isSelected ? 3 : 1,
            borderRadius: BorderRadius.circular(24),
            shadowColor: Colors.black.withOpacity(0.15),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => onSelected(category.name),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: hPadding,
                  vertical: vPadding,
                ),
                child: Row(
                  children: [
                    Icon(
                      category.icon,
                      size: iconSize,
                      color:
                          isSelected
                              ? Colors.white
                              : theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    SizedBox(width: spacing),
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w500,
                        color:
                            isSelected
                                ? Colors.white
                                : theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
