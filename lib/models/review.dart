import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String locationId; // địa điểm được đánh giá
  final String userId;     // ai đánh giá
  final double rating;     // số sao 1-5
  final String? content;   // nội dung đánh giá (có thể bỏ trống)
  final Timestamp createdAt;

  Review({
    required this.id,
    required this.locationId,
    required this.userId,
    required this.rating,
    this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'locationId': locationId,
    'userId': userId,
    'rating': rating,
    'content': content,
    'createdAt': createdAt,
  };

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json['id'],
    locationId: json['locationId'],
    userId: json['userId'],
    rating: (json['rating'] ?? 0).toDouble(),
    content: json['content'],
    createdAt: json['createdAt'],
  );
}
