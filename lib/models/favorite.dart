import 'package:cloud_firestore/cloud_firestore.dart';

class Favorite {
  final String id; // ID của bản ghi "like"
  final String userId;
  final String postId;
  final Timestamp createdAt;

  Favorite({
    required this.id,
    required this.userId,
    required this.postId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'postId': postId,
    'createdAt': createdAt,
  };

  factory Favorite.fromJson(Map<String, dynamic> json) => Favorite(
    id: json['id'],
    userId: json['userId'],
    postId: json['postId'],
    createdAt: json['createdAt'],
  );
}
