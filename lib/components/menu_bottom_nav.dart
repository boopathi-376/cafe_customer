import 'package:cafe/view/customer_menu.dart';
import 'package:flutter/material.dart';

import '../view/cart_screen.dart';
import '../view/home_screen.dart';
import '../view/view_orders_screen.dart';
import '../view/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  // Pages built inside build() so they always have correct context
  List<Widget> get _pages => [
    _TabScaffold(child: const HomeScreen()),
    _TabScaffold(child: const TodaysSpecialScreenState()),
    _TabScaffold(child: const CartScreen()),
    _TabScaffold(child: const ViewOrdersScreen()),
    _TabScaffold(child: const ProfileScreen()),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: _pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_fire_department_outlined),
              activeIcon: Icon(Icons.local_fire_department),
              label: "Today's"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              activeIcon: Icon(Icons.shopping_bag),
              label: 'Cart'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Orders'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
      ),
    );
  }
}

/// Wraps each tab content so Provider context is always available
/// inside PageView. No extra Scaffold or SafeArea — MainScreen
/// already provides both, avoiding the 1px overflow.
class _TabScaffold extends StatelessWidget {
  final Widget child;
  const _TabScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
