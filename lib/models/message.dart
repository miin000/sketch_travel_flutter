import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String senderId;
  final String content;
  final Timestamp createdAt;

  Message({
    required this.id,
    required this.senderId,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'senderId': senderId,
    'content': content,
    'createdAt': createdAt,
  };

  factory Message.fromSnap(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;
    return Message(
      id: snap.id,
      senderId: data['senderId'],
      content: data['content'],
      createdAt: data['createdAt'],
    );
  }
}