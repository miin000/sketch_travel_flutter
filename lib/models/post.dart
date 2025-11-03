import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String uid;
  final String username;
  final String avatarUrl;
  final String locationName;
  final String description;
  final List<String> imageUrls;
  final Timestamp createdAt;
  final List<dynamic> likes;
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

  ///Hàm xử lý mọi trường hợp imageUrls
  static List<String> _parseImageUrls(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) {
      // Trường hợp Firestore lưu dạng [["url1", "url2"]] (lồng list)
      if (raw.isNotEmpty && raw.first is List) {
        return List<String>.from(raw.first.whereType<String>());
      }
      // Trường hợp chuẩn ["url1", "url2"]
      return List<String>.from(raw.whereType<String>());
    }
    return [];
  }

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
    final data = snap.data();
    if (data == null || data is! Map) {
      throw Exception('Dữ liệu bài đăng không hợp lệ: ${snap.id}');
    }

    final map = Map<String, dynamic>.from(data as Map<dynamic, dynamic>);

    print('🔥 imageUrls: ${map['imageUrls']} (${map['imageUrls'].runtimeType})'); // debug log

    return Post(
      id: map['id'] ?? snap.id,
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      locationName: map['locationName'] ?? '',
      description: map['description'] ?? '',
      imageUrls: _parseImageUrls(map['imageUrls']),
      createdAt: map['createdAt'] ?? Timestamp.now(),
      likes: List<dynamic>.from(map['likes'] ?? []),
      commentCount: map['commentCount'] ?? 0,
    );
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    print('🔥 imageUrls: ${json['imageUrls']} (${json['imageUrls'].runtimeType})'); // debug log

    return Post(
      id: json['id'] ?? '',
      uid: json['uid'] ?? '',
      username: json['username'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      locationName: json['locationName'] ?? '',
      description: json['description'] ?? '',
      imageUrls: _parseImageUrls(json['imageUrls']),
      createdAt: json['createdAt'] ?? Timestamp.now(),
      likes: List<dynamic>.from(json['likes'] ?? []),
      commentCount: json['commentCount'] ?? 0,
    );
  }

  factory Post.empty() {
    return Post(
      id: '',
      uid: '',
      username: '',
      avatarUrl: '',
      locationName: '',
      description: '',
      imageUrls: const [],
      createdAt: Timestamp.now(),
      likes: const [],
      commentCount: 0,
    );
  }
}
