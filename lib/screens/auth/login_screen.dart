// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool isLoading = false;

  // Temporarily bypass the login process
  void _login() async {
    setState(() {
      isLoading = true;
    });

    // Simulate a short delay
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      isLoading = false;
    });

    // Navigate directly to the Menu Screen
    Navigator.pushReplacementNamed(context, '/menu');
  }

  void _loginWithGoogle() async {
    setState(() {
      isLoading = true;
    });

    try {
      print('Attempting to sign in with Google');
      bool success = await Provider.of<AuthService>(context, listen: false)
          .signInWithGoogle();
      if (success) {
        print('Google sign in successful, navigating to Menu Screen');
        Navigator.pushReplacementNamed(context, '/menu');
      } else {
        // Handle sign-in cancellation
        print('Google sign in cancelled');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google sign in cancelled'),
            backgroundColor: Colors.orangeAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Failed to sign in with Google: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign in with Google: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildEmailField() {
    return TextFormField(
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.email),
        labelText: 'Email',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blueAccent),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) =>
          value != null && value.contains('@') ? null : 'Enter a valid email',
      onChanged: (value) => email = value,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock),
        labelText: 'Password',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blueAccent),
        ),
      ),
      obscureText: true,
      validator: (value) =>
          value != null && value.length >= 6 ? null : 'Minimum 6 characters',
      onChanged: (value) => password = value,
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: isLoading ? null : _login, // Bypassed login
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent, // Primary button color
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5, // Adds a shadow
      ),
      child: isLoading
          ? CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
          : Text(
              'Login',
              style: TextStyle(fontSize: 18),
            ),
    );
  }

  Widget _buildGoogleLoginButton() {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : _loginWithGoogle, // Properly linked to _loginWithGoogle
      icon: Icon(Icons.login, color: Colors.white),
      label: Text(
        'Login with Google',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent, // Google button color
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5, // Adds a shadow
      ),
    );
  }

  Widget _buildRegisterText() {
    return TextButton(
      onPressed: () {
        Navigator.pushNamed(context, '/signup');
      },
      child: Text(
        'Don\'t have an account? Register here.',
        style: TextStyle(color: Colors.blueAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Email Field
              _buildEmailField(),
              SizedBox(height: 20),
              // Password Field
              _buildPasswordField(),
              SizedBox(height: 30),
              // Login Button
              _buildLoginButton(),
              SizedBox(height: 20),
              // Google Login Button
              _buildGoogleLoginButton(),
              SizedBox(height: 20),
              // Register Text
              _buildRegisterText(),
            ],
          ),
        ),
      ),
    );
  }
}