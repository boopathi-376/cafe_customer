import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/customer_menu_card.dart';
import '../helper/date_helpers.dart';
import '../models/category_model.dart';
import '../models/menu_items.dart';
import '../provider/auth_provider.dart';
import '../provider/user_provider.dart';
import '../provider/menu_provider.dart';
import '../widget/category_chips.dart';
import 'notification_screen/customer_notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'All';
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthenticationProvider>(
        context,
        listen: false,
      );
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final menuProvider = Provider.of<MenuProvider>(context, listen: false);

      final uid = authProvider.user?.uid;
      if (uid != null) {
        userProvider.loadUser(uid);
      }
      menuProvider.fetchMenuItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final user = Provider.of<UserProvider>(context).user;
    final width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(colorScheme, textTheme),
              const SizedBox(height: 10),
              Text(
                "${getGreetingMessage()}, ${user?.name ?? ''}",
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "What would you like today?",
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 16),
              _buildSearchBar(theme),
              const SizedBox(height: 12),
              _buildCategoryFilters(theme),
              const SizedBox(height: 16),
              _buildMenuItems(theme, width),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(ColorScheme colorScheme, TextTheme textTheme) {
    bool hasNotification = true;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Happy Mug",
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications_none,
                size: 24,
                color: colorScheme.onSurface,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomerNotificationScreen(),
                  ),
                );
              },
            ),
            if (hasNotification)
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(24),
      shadowColor: Colors.black.withOpacity(0.1),
      child: TextField(
        controller: searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
          hintText: 'Search for coffee, pastries...',
          hintStyle: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          filled: true,
          fillColor: colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters(ThemeData theme) {
    return CategoryChips(
      categories: cafeCategories,
      selected: selectedCategory,
      onSelected: (category) {
        setState(() {
          selectedCategory = category;
        });
      },
    );
  }

  Widget _buildMenuItems(ThemeData theme, double width) {
    return Consumer<MenuProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<MenuItem> items = provider.menuItems;

        if (selectedCategory != 'All') {
          items =
              items.where((item) => item.category == selectedCategory).toList();
        }

        if (searchController.text.isNotEmpty) {
          items =
              items
                  .where(
                    (item) => item.name.toLowerCase().contains(
                      searchController.text.toLowerCase(),
                    ),
                  )
                  .toList();
        }

        if (items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Center(
              child: Text(
                "No items found",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          padding: const EdgeInsets.only(bottom: 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: width * 0.04,
            crossAxisSpacing: width * 0.04,
            childAspectRatio: 0.70,
          ),
          itemBuilder: (context, index) {
            return CustomerMenuCard(item: items[index]);
          },
        );
      },
    );
  }
}
