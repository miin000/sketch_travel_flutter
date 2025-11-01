import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteLocation {
  final String id;
  final String userId;
  final String locationId;
  final Timestamp createdAt;

  FavoriteLocation({
    required this.id,
    required this.userId,
    required this.locationId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'locationId': locationId,
    'createdAt': createdAt,
  };

  factory FavoriteLocation.fromJson(Map<String, dynamic> json) => FavoriteLocation(
    id: json['id'],
    userId: json['userId'],
    locationId: json['locationId'],
    createdAt: json['createdAt'],
  );
}