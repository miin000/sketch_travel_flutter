import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '/constants.dart';
import '/models/app_notification.dart';

class NotificationController extends GetxController {
  final Rx<List<AppNotification>> _notifications = Rx<List<AppNotification>>([]);
  List<AppNotification> get notifications => _notifications.value;

  @override
  void onInit() {
    super.onInit();
    String currentUserId = authController.userAccount.uid;
    _notifications.bindStream(
      firestore
          .collection('notifications')
          .doc(currentUserId) // Đọc document của user
          .collection('userNotifications') // Từ sub-collection của họ
          .orderBy('createdAt', descending: true)
          .limit(50) // Giới hạn 50 thông báo mới nhất
          .snapshots()
          .map((QuerySnapshot query) {
        return query.docs
            .map((doc) => AppNotification.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
      }),
    );
  }

  // (Tùy chọn) Hàm đánh dấu đã đọc
  Future<void> markAsRead(String notificationId) async {
    String currentUserId = authController.userAccount.uid;
    await firestore
        .collection('notifications')
        .doc(currentUserId)
        .collection('userNotifications')
        .doc(notificationId)
        .update({'isRead': true});
  }
}