import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cafe/components/customer_menu_card.dart';
import 'package:cafe/helper/date_helpers.dart';
import 'package:cafe/models/category_model.dart';
import 'package:cafe/models/menu_items.dart';
import 'package:cafe/provider/auth_provider.dart';
import 'package:cafe/provider/menu_provider.dart';
import 'package:cafe/provider/user_provider.dart';
import 'package:cafe/widget/category_chips.dart';
import 'package:cafe/view/notification_screen/customer_notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth =
          Provider.of<AuthenticationProvider>(context, listen: false);
      final uid = auth.user?.uid;
      if (uid != null) {
        Provider.of<UserProvider>(context, listen: false).loadUser(uid);
      }
      Provider.of<MenuProvider>(context, listen: false).fetchMenuItems();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _searchQuery = value.trim());
    });
  }

  List<MenuItem> _filtered(List<MenuItem> all) {
    var items = all;
    if (_selectedCategory != 'All') {
      items = items.where((i) => i.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      items = items.where((i) => i.name.toLowerCase().contains(q)).toList();
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    // No Scaffold here — MainScreen already provides it.
    // Consumer is at the top level so it is always inside MultiProvider.
    return Consumer<MenuProvider>(
      builder: (context, menuProvider, _) {
        final items = _filtered(menuProvider.menuItems);

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 48, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopBar(cs: cs, tt: tt),
                    const SizedBox(height: 10),
                    Selector<UserProvider, String>(
                      selector: (_, p) => p.user?.name ?? '',
                      builder: (_, name, __) => Text(
                        '${getGreetingMessage()}, $name',
                        style: tt.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      'What would you like today?',
                      style: tt.bodyMedium?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(height: 16),
                    _SearchBar(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      cs: cs,
                      tt: tt,
                    ),
                    const SizedBox(height: 12),
                    CategoryChips(
                      categories: cafeCategories,
                      selected: _selectedCategory,
                      onSelected: (c) =>
                          setState(() => _selectedCategory = c),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            if (menuProvider.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (menuProvider.error != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(menuProvider.error!, style: tt.bodyMedium),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: menuProvider.fetchMenuItems,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (items.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'No items found',
                    style: tt.bodyMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.6)),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        CustomerMenuCard(item: items[index]),
                    childCount: items.length,
                  ),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.70,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  final ColorScheme cs;
  final TextTheme tt;
  const _TopBar({required this.cs, required this.tt});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Happy Mug',
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        IconButton(
          icon: Icon(Icons.notifications_none, size: 24, color: cs.onSurface),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const CustomerNotificationScreen()),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ColorScheme cs;
  final TextTheme tt;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.cs,
    required this.tt,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(24),
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: cs.onSurfaceVariant),
          hintText: 'Search for coffee, pastries...',
          hintStyle: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          filled: true,
          fillColor: cs.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
