import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String confirmPassword = '';
  bool isLoading = false;

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      setState(() {
        isLoading = true;
      });

      try {
        print('Attempting to sign up with email: $email');
        await Provider.of<AuthService>(context, listen: false)
            .signUpWithEmail(email, password);
        print('Signup successful, navigating to Menu Screen');
        Navigator.pushReplacementNamed(context, '/menu');
      } catch (e) {
        print('Signup failed: $e');
        String errorMessage = e.toString();
        if (errorMessage.contains('email-already-in-use')) {
          // Prompt user to link accounts or log in
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'This email is already registered. Please log in or link your accounts.',
                style: TextStyle(fontSize: 16),
              ),
              backgroundColor: Colors.orangeAccent,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Log In',
                textColor: Colors.white,
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                errorMessage,
                style: TextStyle(fontSize: 16),
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _signupWithGoogle() async {
    setState(() {
      isLoading = true;
    });

    try {
      print('Attempting to sign up with Google');
      bool success = await Provider.of<AuthService>(context, listen: false)
          .signInWithGoogle();
      if (success) {
        print('Google signup successful, navigating to Menu Screen');
        Navigator.pushReplacementNamed(context, '/menu');
      } else {
        // Handle sign-in cancellation
        print('Google sign up cancelled');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google sign up cancelled'),
            backgroundColor: Colors.orangeAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Failed to sign up with Google: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign up with Google: $e'),
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
        hintText: 'Enter your email',
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
        hintText: 'Enter your password',
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

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock_outline),
        labelText: 'Confirm Password',
        hintText: 'Re-enter your password',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blueAccent),
        ),
      ),
      obscureText: true,
      validator: (value) =>
          value != null && value.length >= 6 ? null : 'Minimum 6 characters',
      onChanged: (value) => confirmPassword = value,
    );
  }

  Widget _buildSignupButton() {
    return ElevatedButton(
      onPressed: _signup,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent, // Primary button color
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5, // Adds a shadow
      ),
      child: Text(
        'Register',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildGoogleSignupButton() {
    return ElevatedButton.icon(
      onPressed: _signupWithGoogle,
      icon: Icon(Icons.login, color: Colors.white),
      label: Text(
        'Register with Google',
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

  Widget _buildLoginText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Already have an account? "),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/login');
          },
          child: Text(
            "Login",
            style: TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient Background
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
                Image.asset(
                  'assets/images/logo.png',
                  height: 150,
                ),
                SizedBox(height: 40),
                // Signup Form Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildEmailField(),
                          SizedBox(height: 20),
                          _buildPasswordField(),
                          SizedBox(height: 20),
                          _buildConfirmPasswordField(),
                          SizedBox(height: 30),
                          // Register Button or Loading Indicator
                          isLoading
                              ? CircularProgressIndicator()
                              : _buildSignupButton(),
                          SizedBox(height: 20),
                          // Google Signup Button or Loading Indicator
                          isLoading
                              ? SizedBox.shrink()
                              : _buildGoogleSignupButton(),
                          SizedBox(height: 30),
                          // Login Text
                          _buildLoginText(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}