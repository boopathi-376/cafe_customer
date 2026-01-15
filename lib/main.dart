import 'package:cafe/provider/rating_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'package:cafe/provider/auth_provider.dart';
import 'package:cafe/provider/cart_provider.dart';
import 'package:cafe/provider/menu_provider.dart';
import 'package:cafe/provider/order_provider.dart';
import 'package:cafe/provider/user_provider.dart';
import 'package:cafe/theme/app_theme.dart';
import 'package:cafe/view/auth_screen/verification_screen.dart';
import 'package:cafe/view/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // _handleDynamicLinks(); // Removed deprecated dynamic links
  }

  /*
  void _handleDynamicLinks() async {
     // Dynamic Links logic removed as the package is deprecated.
     // Migrate to App Links / Universal Links.
  }
  */

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => RatingProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Happy Mug',
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
        navigatorKey: _navigatorKey, // 🔑 For pushing navigation from initState
      ),
    );
  }
}
