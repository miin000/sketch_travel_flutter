import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '/constants.dart';
import '/controllers/conversation_controller.dart';
import '/models/chat_room.dart';
import '../chat_detail_screen.dart';

class ConversationsScreen extends StatefulWidget {
  ConversationsScreen({Key? key}) : super(key: key);

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final ConversationController convController = Get.put(ConversationController());

  @override
  void initState() {
    super.initState();
    convController.loadFriends();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bạn bè")),
      body: Obx(() {
        if (convController.friendsList.isEmpty) {
          return const Center(child: Text('Chưa có bạn bè để chat'));
        }
        return ListView.builder(
          itemCount: convController.friendsList.length,
          itemBuilder: (context, index) {
            final user = convController.friendsList[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: (user.avatarUrl ?? '').isNotEmpty
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                child: (user.avatarUrl ?? '').isEmpty
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text(user.displayName ?? user.name ?? 'Ẩn danh'),
              subtitle: Text(user.email),
              onTap: () async {
                String roomId =
                (authController.userAccount.uid.hashCode <= user.uid.hashCode)
                    ? '${authController.userAccount.uid}_${user.uid}'
                    : '${user.uid}_${authController.userAccount.uid}';
                Get.to(() => ChatDetailScreen(
                  roomId: roomId,
                  receiverId: user.uid,
                  receiverName: user.displayName ?? user.name ?? '',
                  receiverAvatar: user.avatarUrl ?? '',
                  myInfo: {
                    'name': authController.userAccount.displayName ?? '',
                    'avatar': authController.userAccount.photoURL ?? '',
                  },
                  receiverInfo: {
                    'name': user.displayName ?? user.name ?? '',
                    'avatar': user.avatarUrl ?? '',
                  },
                ));
              },
            );
          },
        );
      }),
    );
  }
}
