import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/special_item_card.dart';
// import '../../models/menu_items.dart';
import '../models/category_model.dart';
import '../widget/category_chips.dart';
import '../provider/menu_provider.dart';

class TodaysSpecialScreenState extends StatefulWidget {
  const TodaysSpecialScreenState({super.key});

  @override
  State<TodaysSpecialScreenState> createState() => _TodaysSpecialScreenState();
}

class _TodaysSpecialScreenState extends State<TodaysSpecialScreenState> {
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    // Fetch menu items if not already fetched (or refetch to be sure)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MenuProvider>(context, listen: false).fetchMenuItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(colorScheme, textTheme),
              const SizedBox(height: 28),

              CategoryChips(
                categories: cafeCategories,
                selected: selectedCategory,
                onSelected: (category) {
                  setState(() {
                    selectedCategory = category;
                  });
                },
              ),

              const SizedBox(height: 28),
              _buildSectionTitle(
                "Today's Specials",
                textTheme,
                colorScheme,
                trailing: _getTodayString(),
              ),
              const SizedBox(height: 12),
              _buildTodaySpecials(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(ColorScheme colorScheme, TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Happy Mug",
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(
    String title,
    TextTheme textTheme,
    ColorScheme colorScheme, {
    String? trailing,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        if (trailing != null)
          Text(
            trailing,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
      ],
    );
  }

  Widget _buildTodaySpecials() {
    return Consumer<MenuProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final now = DateTime.now();
        final todayItems =
            provider.menuItems
                .where(
                  (item) =>
                      item.specialDate != null &&
                      item.specialDate!.day == now.day &&
                      item.specialDate!.month == now.month &&
                      item.specialDate!.year == now.year &&
                      (selectedCategory == 'All' ||
                          item.category == selectedCategory),
                )
                .toList();

        if (todayItems.isEmpty) {
          return const Center(child: Text("No specials today"));
        }

        return Column(
          children:
              todayItems.map((item) => SpecialItemCard(item: item)).toList(),
        );
      },
    );
  }

  String _getTodayString() {
    final now = DateTime.now();
    return "${now.month}/${now.day}/${now.year}";
  }
}
