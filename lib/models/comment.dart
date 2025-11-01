import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String postId;
  final String userId;
  final String username; // <-- THÊM
  final String avatarUrl; // <-- THÊM
  final String content;
  final Timestamp createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.username, // <-- THÊM
    required this.avatarUrl, // <-- THÊM
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'postId': postId,
    'userId': userId,
    'username': username, // <-- THÊM
    'avatarUrl': avatarUrl, // <-- THÊM
    'content': content,
    'createdAt': createdAt,
  };

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    id: json['id'],
    postId: json['postId'],
    userId: json['userId'],
    username: json['username'] ?? '', // <-- THÊM
    avatarUrl: json['avatarUrl'] ?? '', // <-- THÊM
    content: json['content'],
    createdAt: json['createdAt'],
  );
}