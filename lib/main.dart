import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'provider/auth_provider.dart';
import 'provider/cart_provider.dart';
import 'provider/menu_provider.dart';
import 'provider/order_provider.dart';
import 'provider/user_provider.dart';
import 'theme/app_theme.dart';
import 'view/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);

  // Enable Firestore offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        // RatingProvider is intentionally NOT global —
        // it is scoped per-screen in rate_order_screen.dart
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Happy Mug',
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
