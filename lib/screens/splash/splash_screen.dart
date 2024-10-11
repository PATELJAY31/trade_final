import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigate();
      }
    });
  }

  void _navigate() {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/menu');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set a background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with scaling animation
            ScaleTransition(
              scale: _animation,
              child: Image.asset(
                'assets/images/logo.png', // Ensure this path is correct
                width: 150,
                height: 150,
              ),
            ),
            SizedBox(height: 20),
            // Animated app name
            FadeTransition(
              opacity: _animation,
              child: Text(
                'College Buy & Sell',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent, // App name color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}