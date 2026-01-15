import 'package:flutter/material.dart';

class CategoryModel {
  final String name;
  final IconData icon;
  final String id; // optional, useful if storing in Firestore

  CategoryModel({
    required this.name,
    required this.icon,
    this.id = '',
  });
}

final List<CategoryModel> cafeCategories = [
  CategoryModel(name: 'All', icon: Icons.grid_view),
  CategoryModel(name: 'Tea', icon: Icons.emoji_food_beverage),
  CategoryModel(name: 'Coffee', icon: Icons.local_cafe),
  CategoryModel(name: 'Cold Coffee', icon: Icons.icecream),
  CategoryModel(name: 'Snacks', icon: Icons.fastfood),
  CategoryModel(name: 'Sandwiches', icon: Icons.lunch_dining),
  CategoryModel(name: 'Wraps & Rolls', icon: Icons.flatware),
  CategoryModel(name: 'South Indian', icon: Icons.rice_bowl),
  CategoryModel(name: 'Maggie', icon: Icons.ramen_dining),
  CategoryModel(name: 'Burgers', icon: Icons.lunch_dining),
  CategoryModel(name: 'Fries', icon: Icons.soup_kitchen),
  CategoryModel(name: 'Pastries & Cakes', icon: Icons.cake),
  CategoryModel(name: 'Desserts', icon: Icons.icecream),
  CategoryModel(name: 'Shakes', icon: Icons.blender),
  CategoryModel(name: 'Juices', icon: Icons.local_bar),
  CategoryModel(name: 'Healthy', icon: Icons.eco),
];
