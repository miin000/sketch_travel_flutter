import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String locationId;
  final String userId;
  final String username; // <-- THÊM
  final String avatarUrl; // <-- THÊM
  final double rating;
  final String? content;
  final Timestamp createdAt;

  Review({
    required this.id,
    required this.locationId,
    required this.userId,
    required this.username,
    required this.avatarUrl,
    required this.rating,
    this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'locationId': locationId,
    'userId': userId,
    'username': username,
    'avatarUrl': avatarUrl,
    'rating': rating,
    'content': content,
    'createdAt': createdAt,
  };

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json['id'],
    locationId: json['locationId'],
    userId: json['userId'],
    username: json['username'] ?? '',
    avatarUrl: json['avatarUrl'] ?? '',
    rating: (json['rating'] ?? 0).toDouble(),
    content: json['content'],
    createdAt: json['createdAt'],
  );
}