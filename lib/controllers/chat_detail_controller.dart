import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '/constants.dart';
import '/models/app_notification.dart';
import '/models/message.dart';

class ChatDetailController extends GetxController {

  // Lấy stream tin nhắn cho một phòng chat
  Stream<List<Message>> getMessageStream(String roomId) {
    return firestore
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((QuerySnapshot query) {
      return query.docs.map((doc) => Message.fromSnap(doc)).toList();
    });
  }

  // Gửi tin nhắn VÀ thông báo
  Future<void> sendMessage({
    required String roomId,
    required String content,
    required String receiverId,
    required Map<String, dynamic> myInfo, // { 'name': '...', 'avatar': '...' }
    required Map<String, dynamic> receiverInfo, // { 'name': '...', 'avatar': '...' }
  }) async {
    if (content.trim().isEmpty) return;

    try {
      String myUid = authController.userAccount.uid;
      Timestamp now = Timestamp.now();

      // 1. Tạo tin nhắn mới
      Message newMessage = Message(
        id: '', // ID sẽ được tự tạo
        senderId: myUid,
        content: content.trim(),
        createdAt: now,
      );

      // 2. Tạo thông báo mới (cho tab "Thông báo")
      String notifId = 'message_${myUid}_${now.millisecondsSinceEpoch}';
      AppNotification notif = AppNotification(
        id: notifId,
        receiverId: receiverId, // Người nhận
        senderId: myUid,
        senderName: myInfo['name'] ?? 'Một người',
        senderAvatar: myInfo['avatar'] ?? '',
        type: NotificationType.message,
        message: 'đã gửi cho bạn một tin nhắn.',
        targetId: roomId, // ID của phòng chat
        createdAt: now,
        isRead: false,
      );

      // 3. Dùng Batch Write để gửi cả 3 một lúc
      WriteBatch batch = firestore.batch();

      // Ghi 1: Thêm tin nhắn vào sub-collection
      DocumentReference msgRef = firestore
          .collection('chatRooms')
          .doc(roomId)
          .collection('messages')
          .doc(); // ID tự động
      batch.set(msgRef, newMessage.toJson());

      // Ghi 2: Cập nhật tin nhắn cuối cùng của phòng chat (cho Inbox)
      DocumentReference roomRef = firestore.collection('chatRooms').doc(roomId);
      batch.update(roomRef, {
        'lastMessage': content.trim(),
        'lastMessageAt': now,
        'lastMessageSenderId': myUid,
        // Đảm bảo participantInfo được cập nhật (nếu chưa có)
        'participantInfo.$myUid': myInfo,
        'participantInfo.$receiverId': receiverInfo,
      });

      // Ghi 3: Thêm thông báo vào hòm thư của người nhận
      DocumentReference notifRef = firestore
          .collection('notifications')
          .doc(receiverId)
          .collection('userNotifications')
          .doc(notifId);
      batch.set(notifRef, notif.toJson());

      // 4. Gửi
      await batch.commit();

    } catch (e) {
      Get.snackbar('Lỗi gửi tin nhắn', e.toString());
    }
  }
}