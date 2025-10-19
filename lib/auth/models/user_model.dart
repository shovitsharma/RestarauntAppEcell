import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String phoneNumber;
  final String? name; // Optional name
  final String role; // e.g., 'admin', 'staff'
  final Timestamp createdAt;

  UserModel({
    required this.uid,
    required this.phoneNumber,
    this.name,
    this.role = 'admin', // Default role for the admin app
    required this.createdAt,
  });

  /// Factory constructor to create a UserModel from a Firestore document
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      phoneNumber: data['phoneNumber'],
      name: data['name'],
      role: data['role'],
      createdAt: data['createdAt'],
    );
  }

  /// Method to convert a UserModel instance to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'name': name,
      'role': role,
      'createdAt': createdAt,
    };
  }
}