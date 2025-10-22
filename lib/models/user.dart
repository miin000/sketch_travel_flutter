import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String email;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final Timestamp createdAt;

  User({
    required this.uid,
    required this.email,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.bio,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'username': username,
    'displayName': displayName,
    'avatarUrl': avatarUrl,
    'bio': bio,
    'createdAt': createdAt,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    uid: json['uid'],
    email: json['email'],
    username: json['username'],
    displayName: json['displayName'],
    avatarUrl: json['avatarUrl'],
    bio: json['bio'],
    createdAt: json['createdAt'],
  );
}
