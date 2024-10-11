// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Ensure this import is present
import 'services/auth_service.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/menu/menu_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/product/product_detail_screen.dart';
import 'screens/product/add_product_screen.dart';
import 'screens/messaging/messaging_screen.dart';
import 'screens/messaging/conversations_screen.dart'; // Import ConversationsScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.initializeFirebase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: MaterialApp(
        title: 'College Buy & Sell',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SplashScreen(), // Initial screen based on auth state
        routes: {
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/menu': (context) => MenuScreen(),
          '/profile': (context) => ProfileScreen(),
          '/search': (context) => SearchScreen(),
          '/conversations': (context) => ConversationsScreen(),
          '/add_product': (context) => AddProductScreen(),
          // Add more routes as needed
        },
      ),
    );
  }
}