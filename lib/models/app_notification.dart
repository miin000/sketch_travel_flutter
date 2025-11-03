import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType { follow, like, comment, post, message }

class AppNotification {
  final String id;
  final String receiverId;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final NotificationType type;
  final String message;
  final Timestamp createdAt;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.receiverId,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.type,
    required this.message,
    required this.createdAt,
    required this.isRead, required String targetId,
  });

  factory AppNotification.fromJson(dynamic data) {
    if (data == null) {
      throw Exception("AppNotification.fromJson: data is null");
    }

    // Nếu là LinkedMap -> ép kiểu trước
    final map = Map<String, dynamic>.from(data as Map<dynamic, dynamic>);

    return AppNotification(
      id: map['id'] ?? '',
      receiverId: map['receiverId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderAvatar: map['senderAvatar'] ?? '',
      type: _parseType(map['type']),
      message: map['message'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      isRead: map['isRead'] ?? false,
      targetId: map['targetId'] ?? '',
    );
  }

  static NotificationType _parseType(dynamic value) {
    if (value is String) {
      switch (value) {
        case 'follow':
          return NotificationType.follow;
        case 'like':
          return NotificationType.like;
        case 'comment':
          return NotificationType.comment;
        case 'message':
          return NotificationType.message;
      }
    }
    return NotificationType.follow;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'receiverId': receiverId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'type': type.name,
      'message': message,
      'createdAt': createdAt,
      'isRead': isRead,
    };
  }
}
