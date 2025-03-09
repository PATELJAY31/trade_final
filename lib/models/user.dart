// lib/models/user.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String? photoURL;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.photoURL,
    required this.createdAt,
  });

  factory AppUser.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoURL: data['photoURL'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoURL': photoURL,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}