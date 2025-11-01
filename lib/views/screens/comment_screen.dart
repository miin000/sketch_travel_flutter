import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/constants.dart';
import '/controllers/comment_controller.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';

class CommentScreen extends StatelessWidget {
  final String postId; // <-- LỖI CỦA BẠN LÀ DO THIẾU DÒNG NÀY
  CommentScreen({
    Key? key,
    required this.postId, // <-- Constructor phải yêu cầu 'postId'
  }) : super(key: key);

  final CommentController commentController = Get.put(CommentController());
  final TextEditingController _commentTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Thêm thư viện timeago vào pubspec.yaml nếu bạn chưa có
    // (flutter pub add timeago)
    timeago.setLocaleMessages('vi', timeago.ViMessages()); // (Tùy chọn: hiển thị tiếng Việt)

    commentController.updatePostId(postId); // Cập nhật Post ID cho controller

    return Scaffold(
      appBar: AppBar(
        title: Text('Bình luận'),
        backgroundColor: backgroundColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
                  () {
                if (commentController.comments.isEmpty) {
                  return Center(child: Text('Hãy là người đầu tiên bình luận!'));
                }
                return ListView.builder(
                  itemCount: commentController.comments.length,
                  itemBuilder: (context, index) {
                    final comment = commentController.comments[index];

                    // Giờ chúng ta có thể dùng username/avatarUrl từ comment
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(comment.avatarUrl),
                        backgroundColor: Colors.grey,
                      ),
                      title: Text(
                        comment.username,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comment.content,
                            style: TextStyle(fontSize: 15),
                          ),
                          SizedBox(height: 4),
                          Text(
                            timeago.format(comment.createdAt.toDate(), locale: 'vi'), // Hiển thị "5 phút trước"
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      isThreeLine: true,
                    );
                  },
                );
              },
            ),
          ),
          Divider(),
          // Vùng nhập comment
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: CircleAvatar(
                // Tạm thời dùng placeholder cho avatar của user hiện tại
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: TextField(
                controller: _commentTextController,
                decoration: InputDecoration(
                  hintText: 'Thêm bình luận...',
                  border: InputBorder.none,
                ),
              ),
              trailing: IconButton(
                icon: Icon(Icons.send, color: buttonColor),
                onPressed: () {
                  if (_commentTextController.text.isNotEmpty) {
                    commentController.postComment(_commentTextController.text.trim());
                    _commentTextController.clear();
                    FocusScope.of(context).unfocus(); // Ẩn bàn phím
                  }
                },
              ),
            ),
          ),
          // Đệm để bàn phím không che mất
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}