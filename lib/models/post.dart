import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String uid; // Đổi tên từ userId để nhất quán
  final String username;
  final String avatarUrl;
  final String locationName; // Lưu tên địa điểm dưới dạng String
  final String description;
  final List<String> imageUrls;
  final Timestamp createdAt;
  final List likes;
  final int commentCount;

  Post({
    required this.id,
    required this.uid,
    required this.username,
    required this.avatarUrl,
    required this.locationName,
    required this.description,
    required this.imageUrls,
    required this.createdAt,
    required this.likes,
    this.commentCount = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'uid': uid,
    'username': username,
    'avatarUrl': avatarUrl,
    'locationName': locationName,
    'description': description,
    'imageUrls': imageUrls,
    'createdAt': createdAt,
    'likes': likes,
    'commentCount': commentCount,
  };

  factory Post.fromSnap(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;
    return Post(
      id: data['id'] ?? '',
      uid: data['uid'] ?? '',
      username: data['username'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      locationName: data['locationName'] ?? '',
      description: data['description'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      likes: data['likes'] ?? [],
      commentCount: data['commentCount'] ?? 0,
    );
  }
}