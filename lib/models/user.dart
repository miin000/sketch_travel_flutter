import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String email;
  final String username;
  final String? displayName;
  final String? name;
  final String? avatarUrl;
  final String? bio;
  final Timestamp createdAt;
  final List<String> searchKeywords;

  User({
    required this.uid,
    required this.email,
    required this.username,
    this.displayName,
    this.name,
    this.avatarUrl,
    this.bio,
    required this.createdAt,
    this.searchKeywords = const [],
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'username': username,
    'displayName': displayName,
    'name': name,
    'avatarUrl': avatarUrl,
    'bio': bio,
    'createdAt': createdAt,
    'searchKeywords': searchKeywords,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    uid: json['uid'],
    email: json['email'],
    username: json['username'],
    displayName: json['displayName'],
    name: json['name'],
    avatarUrl: json['avatarUrl'],
    bio: json['bio'],
    createdAt: json['createdAt'],
    searchKeywords: List<String>.from(json['searchKeywords'] ?? []),
  );
}