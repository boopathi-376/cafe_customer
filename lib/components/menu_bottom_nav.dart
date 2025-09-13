
import 'package:cafe/view/customer_menu.dart';
import 'package:flutter/material.dart';

import '../view/cart_screen.dart';
import '../view/home_screen.dart';
import '../view/myOrder_Screen.dart';
import '../view/profileScreen.dart';

 // Assuming you have a menu screen

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final PageController _pageController;


  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe
        children: [
          HomeScreen(),
          TodaysSpecialScreenState(),// Replace with your list
          CartScreen(),
          ViewOrdersScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.local_fire_department), label: "Today'S"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: 'Carts'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_food_beverage_outlined), label: 'Order'),
          BottomNavigationBarItem(icon: Icon(Icons.person_2_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}
