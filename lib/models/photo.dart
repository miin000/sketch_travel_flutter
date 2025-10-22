import 'package:cloud_firestore/cloud_firestore.dart';

class Photo {
  final String id;
  final String uid;
  final String username;
  final String caption;
  final String imageUrl;
  final String avatarUrl;
  final List likes;
  final int commentCount;
  final Timestamp createdAt;

  Photo({
    required this.id,
    required this.uid,
    required this.username,
    required this.caption,
    required this.imageUrl,
    required this.avatarUrl,
    required this.likes,
    required this.commentCount,
    required this.createdAt,
  });

  // Convert từ Firestore snapshot sang model
  factory Photo.fromSnap(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;
    return Photo(
      id: data['id'] ?? '',
      uid: data['uid'] ?? '',
      username: data['username'] ?? '',
      caption: data['caption'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      likes: data['likes'] ?? [],
      commentCount: data['commentCount'] ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  // Convert sang JSON để lưu lên Firestore
  Map<String, dynamic> toJson() => {
    'id': id,
    'uid': uid,
    'username': username,
    'caption': caption,
    'imageUrl': imageUrl,
    'avatarUrl': avatarUrl,
    'likes': likes,
    'commentCount': commentCount,
    'createdAt': createdAt,
  };
}
