// lib/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/gradients.dart'; // Import the gradients utility

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
        ),
        body: Center(
          child: Text(
            'No user is currently signed in.',
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
          ),
        ),
      );
    }

    return Scaffold(
      // Make the AppBar transparent to blend with the gradient
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (route) => false);
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.backgroundGradient, // Apply the background gradient
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Card(
              color: Colors.white.withOpacity(0.85), // Semi-transparent card
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              elevation: 8,
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // User Avatar
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: user.photoURL != null && user.photoURL!.isNotEmpty
                          ? NetworkImage(user.photoURL!)
                          : AssetImage('assets/images/default_avatar.png') as ImageProvider,
                      backgroundColor: Colors.grey[300],
                    ),
                    SizedBox(height: 30),
                    // User Name
                    Text(
                      user.displayName ?? 'No Name',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: 10),
                    // User Email
                    Text(
                      user.email ?? 'No Email',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 10),
                    // User UID
                    Text(
                      'User ID: ${user.uid}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 30),
                    // Edit Profile Button
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to Edit Profile Screen if you have one
                        // For example:
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen()));
                      },
                      child: Text('Edit Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Additional Profile Options (Optional)
                    // Example: Change Password, Settings, etc.
                    // You can add more widgets here to enhance the profile screen.
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
