// lib/models/user.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
  });

  // Factory constructor to create a UserModel from Firestore data
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
    );
  }

  // Method to convert UserModel to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
    };
  }

  // Method to create a copy with updated fields
  UserModel copyWith({
    String? name,
    String? phone,
  }) {
    return UserModel(
      uid: this.uid,
      name: name ?? this.name,
      email: this.email,
      phone: phone ?? this.phone,
    );
  }
}