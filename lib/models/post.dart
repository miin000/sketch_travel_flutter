import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String locationId;
  final String description;
  final List<String> imageUrls;
  final Timestamp createdAt;
  final int likeCount;
  final int commentCount;

  Post({
    required this.id,
    required this.userId,
    required this.locationId,
    required this.description,
    required this.imageUrls,
    required this.createdAt,
    this.likeCount = 0,
    this.commentCount = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'locationId': locationId,
    'description': description,
    'imageUrls': imageUrls,
    'createdAt': createdAt,
    'likeCount': likeCount,
    'commentCount': commentCount,
  };

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json['id'],
    userId: json['userId'],
    locationId: json['locationId'],
    description: json['description'],
    imageUrls: List<String>.from(json['imageUrls']),
    createdAt: json['createdAt'],
    likeCount: json['likeCount'] ?? 0,
    commentCount: json['commentCount'] ?? 0,
  );
}
