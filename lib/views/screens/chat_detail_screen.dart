import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/constants.dart';
import '/controllers/chat_detail_controller.dart';
import '/models/message.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatDetailScreen extends StatefulWidget {
  final String roomId;
  final String receiverId;
  final String receiverName;
  final String receiverAvatar;
  // Truyền thông tin 2 user để GHI vào CSDL khi gửi tin nhắn
  final Map<String, dynamic> myInfo;
  final Map<String, dynamic> receiverInfo;

  const ChatDetailScreen({
    Key? key,
    required this.roomId,
    required this.receiverId,
    required this.receiverName,
    required this.receiverAvatar,
    required this.myInfo,
    required this.receiverInfo,
  }) : super(key: key);

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ChatDetailController _controller = Get.put(ChatDetailController());
  final TextEditingController _textController = TextEditingController();
  final String myUid = authController.userAccount.uid;

  void _sendMessage() {
    _controller.sendMessage(
      roomId: widget.roomId,
      content: _textController.text,
      receiverId: widget.receiverId,
      myInfo: widget.myInfo,
      receiverInfo: widget.receiverInfo,
    );
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: CachedNetworkImageProvider(widget.receiverAvatar),
              backgroundColor: Colors.grey[800],
            ),
            SizedBox(width: 10),
            Text(widget.receiverName),
          ],
        ),
      ),
      body: Column(
        children: [
          // 1. Danh sách tin nhắn
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _controller.getMessageStream(widget.roomId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Hãy gửi tin nhắn đầu tiên'));
                }
                final messages = snapshot.data!;
                return ListView.builder(
                  reverse: true, // Hiển thị tin nhắn mới nhất ở dưới cùng
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final bool isMe = message.senderId == myUid;
                    return _buildMessageBubble(message, isMe);
                  },
                );
              },
            ),
          ),
          // 2. Ô nhập tin nhắn
          _buildTextInput(),
        ],
      ),
    );
  }

  // Bong bóng chat
  Widget _buildMessageBubble(Message message, bool isMe) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? buttonColor : Colors.grey[800],
          borderRadius: BorderRadius.circular(20),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Text(
          message.content,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  // Ô nhập
  Widget _buildTextInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -1),
            blurRadius: 2,
            color: Colors.black.withOpacity(0.1),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Nhắn tin...',
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send, color: buttonColor),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}