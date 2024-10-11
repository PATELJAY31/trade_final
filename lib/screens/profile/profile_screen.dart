// lib/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

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
          child: Text('No user is currently signed in.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Avatar
            CircleAvatar(
              radius: 50,
              backgroundImage: user.photoURL != null && user.photoURL!.isNotEmpty
                  ? NetworkImage(user.photoURL!)
                  : AssetImage('assets/images/default_avatar.png')
                      as ImageProvider,
              backgroundColor: Colors.grey[300],
            ),
            SizedBox(height: 20),
            // User Name
            Text(
              user.displayName ?? 'No Name',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // User Email
            Text(
              user.email ?? 'No Email',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 10),
            // User UID
            Text(
              'User ID: ${user.uid}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 30),
            // Edit Profile Button
            ElevatedButton(
              onPressed: () {
                // Navigate to Edit Profile Screen if you have one
                // For example: Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen()));
              },
              child: Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // Updated from 'primary'
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            // Add more profile-related widgets here
          ],
        ),
      ),
    );
  }
}