import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'intro_page.dart';
import 'auth/login_screen.dart';
import 'menu/menu_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      Future.delayed(Duration(milliseconds: 500), () {
        _navigateToNextScreen();
      });
    });
  }

  void _navigateToNextScreen() {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    // Check if it's the first launch
    // You can implement this check using shared preferences
    bool isFirstLaunch = true; // Replace with actual first launch check

    if (isFirstLaunch) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => IntroPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: Duration(milliseconds: 800),
        ),
      );
    } else {
      // Check authentication state
      if (authService.currentUser != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => MainScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart,
                      size: 100,
                      color: Colors.white,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Campus',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Your Shopping Assistant',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 