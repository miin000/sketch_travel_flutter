import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final Timestamp createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'postId': postId,
    'userId': userId,
    'content': content,
    'createdAt': createdAt,
  };

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    id: json['id'],
    postId: json['postId'],
    userId: json['userId'],
    content: json['content'],
    createdAt: json['createdAt'],
  );
}
