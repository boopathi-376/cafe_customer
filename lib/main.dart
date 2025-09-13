import 'package:cafe/provider/ratingProvider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
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
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
    _handleDynamicLinks();
  }

  void _handleDynamicLinks() async {
    // Handle background or foreground links
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      final Uri deepLink = dynamicLinkData.link;
      if (deepLink.path.contains('/emailVerify')) {
        Future.delayed(Duration.zero, () {
          _navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => VerifiedScreen()),
          );
        });
      }
    });

    // Handle terminated state
    final PendingDynamicLinkData? initialLink =
    await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = initialLink?.link;
    if (deepLink != null && deepLink.path.contains('/emailVerify')) {
      Future.delayed(Duration.zero, () {
        _navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => VerifiedScreen()),
        );
      });
    }
  }

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
        title: 'Customer Café',
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
        navigatorKey: _navigatorKey, // 🔑 For pushing navigation from initState
      ),
    );
  }
}
