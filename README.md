☕ Cafe Customer App (Flutter)

A Flutter-based Cafe Customer Application that allows users to browse menus, manage carts, place orders, track order status, and provide ratings — powered by Firebase and Provider state management.

🚀 Features

🔐 User Authentication (Login / Register / Verification)

📋 Browse Cafe Menu & Products

🛒 Cart Management

💳 Checkout & Order Placement

📦 Order Tracking & Order History

⭐ Rate Orders & Provide Feedback

🔔 Notifications for Order Updates

🎨 Consistent UI using reusable components

🔥 Firebase Integration (Auth, Firestore)

🛠️ Tech Stack

Flutter (Dart)

Provider – State Management

Firebase

Firebase Authentication

Cloud Firestore

Material UI

## 📁 Project Structure

cafe_customer/
├── android/ # Android native project files
├── ios/ # iOS native project files
├── assets/ # Images, icons, and animations
├── lib/
│ ├── components/ # Reusable UI blocks (cards, tiles)
│ ├── helper/ # Helper utilities
│ ├── models/ # Data models
│ │ ├── cart_item.dart
│ │ ├── category_model.dart
│ │ ├── enums.dart
│ │ ├── menu_items.dart
│ │ ├── order.dart
│ │ ├── rating_model.dart
│ │ └── user.dart
│ ├── provider/ # State Management (Provider pattern)
│ │ ├── auth_provider.dart
│ │ ├── cart_provider.dart
│ │ ├── menu_provider.dart
│ │ ├── order_provider.dart
│ │ ├── rating_provider.dart
│ │ └── user_provider.dart
│ ├── service/ # Business logic & Firebase interactions
│ │ ├── auth_service.dart
│ │ ├── cart_service.dart
│ │ ├── menu_service.dart
│ │ ├── order_service.dart
│ │ ├── rating_service.dart
│ │ └── user_service.dart
│ ├── theme/ # App themes & colors
│ ├── view/ # UI Screens
│ │ ├── auth_screen/
│ │ ├── notification_screen/
│ │ ├── order_update_screen/
│ │ ├── cart_screen.dart
│ │ ├── checkout_screen.dart
│ │ ├── customer_menu.dart
│ │ ├── home_screen.dart
│ │ ├── product_screen.dart
│ │ ├── profile_screen.dart
│ │ ├── rate_order_screen.dart
│ │ ├── splash_screen.dart
│ │ └── view_orders_screen.dart
│ ├── widget/ # Small reusable widgets
│ ├── firebase_options.dart
│ └── main.dart # Application entry point
├── pubspec.yaml # Dependencies
└── README.md # Documentation


📌 Key Directories Explained
lib/view

Contains all UI screens such as Home, Menu, Cart, Checkout, Orders, Profile, and Authentication screens.

lib/provider

Implements state management using the Provider pattern to manage:

Authentication state

Cart state

Orders & ratings

User data

lib/service

Handles business logic and Firebase interactions, including:

Authentication

Firestore CRUD operations

Order processing

Ratings & feedback

lib/models

Defines all data models used throughout the app such as:

Cart items

Orders

Categories

Ratings

Users

lib/components & lib/widget

Reusable UI components and widgets to ensure UI consistency and cleaner code.

🔧 Setup Instructions
1️⃣ Clone the Repository
git clone https://github.com/your-username/cafe_customer.git
cd cafe_customer

2️⃣ Install Dependencies
flutter pub get

3️⃣ Configure Firebase

Create a Firebase project

Add Android & iOS apps

Download config files

Ensure firebase_options.dart is properly generated

4️⃣ Run the App
flutter run

🧠 Architecture Overview

MVVM-inspired architecture

UI → Provider → Service → Firebase

Clean separation of concerns

Scalable and maintainable structure

📈 Future Enhancements

💰 Online Payment Integration

📊 Admin Dashboard

📍 Location-based Cafes

🧾 Invoice Download

