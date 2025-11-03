import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '/controllers/notification_controller.dart';
import '/models/app_notification.dart';
import '/constants.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NotificationController controller = Get.put(NotificationController());

    return Obx(() {
      if (controller.notifications.isEmpty) {
        return Center(
          child: Text(
            'Không có thông báo nào',
            style: TextStyle(fontSize: 18),
          ),
        );
      }
      return ListView.builder(
        itemCount: controller.notifications.length,
        itemBuilder: (context, index) {
          final notif = controller.notifications[index];
          return _buildNotificationTile(notif);
        },
      );
    });
  }

  Widget _buildNotificationTile(AppNotification notif) {
    IconData icon;
    Color iconColor;

    switch (notif.type) {
      case NotificationType.follow:
        icon = Icons.person_add;
        iconColor = Colors.blue;
        break;
      case NotificationType.like:
        icon = Icons.favorite;
        iconColor = buttonColor ?? Colors.redAccent; // Dùng màu button
        break;
      case NotificationType.comment:
        icon = Icons.comment;
        iconColor = Colors.green;
        break;
      case NotificationType.post:
        icon = Icons.article; // Icon cho bài viết mới
        iconColor = Colors.orange;
        break;
      case NotificationType.message:
        icon = Icons.chat_bubble_sharp;
        iconColor = Colors.purpleAccent;
        break;
      default:
        icon = Icons.notifications;
        iconColor = Colors.grey;
    }

    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: CachedNetworkImageProvider(notif.senderAvatar),
            backgroundColor: Colors.grey[800],
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: iconColor,
              child: Icon(icon, color: Colors.white, size: 12),
            ),
          )
        ],
      ),
      title: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Get.isDarkMode ? Colors.white : Colors.black,
            fontSize: 15,
          ),
          children: [
            TextSpan(
              text: notif.senderName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: ' ${notif.message}'),
          ],
        ),
      ),
      subtitle: Text(
        timeago.format(notif.createdAt.toDate(), locale: 'vi'),
        style: TextStyle(color: Colors.grey, fontSize: 12),
      ),
      onTap: () {
        // TODO: Điều hướng
        // Ví dụ: nếu là like -> đi đến bài post
        // if (notif.targetId != null) {
        //   Get.to(() => PostDetailScreen(postId: notif.targetId!));
        // }
      },
    );
  }
}