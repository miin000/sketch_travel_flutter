import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String id;
  final List<String> participants; // [uid1, uid2]
  final Map<String, dynamic> participantInfo; // { uid1: { name: 'A', avatar: '...' }, uid2: { ... } }
  final String lastMessage;
  final Timestamp lastMessageAt;
  final String lastMessageSenderId;

  ChatRoom({
    required this.id,
    required this.participants,
    required this.participantInfo,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.lastMessageSenderId,
  });

  factory ChatRoom.fromSnap(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;
    return ChatRoom(
      id: snap.id,
      participants: List<String>.from(data['participants']),
      participantInfo: Map<String, dynamic>.from(data['participantInfo']),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageAt: data['lastMessageAt'] ?? Timestamp.now(),
      lastMessageSenderId: data['lastMessageSenderId'] ?? '',
    );
  }
}