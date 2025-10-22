import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/constants.dart';
import '/controllers/comment_controller.dart';
import 'package:timeago/timeago.dart' as tego;

class CommentScreen extends StatelessWidget {
  final String id; // Đây là Post ID (Photo ID)
  CommentScreen({Key? key, required this.id}) : super(key: key);

  final TextEditingController _commentController = TextEditingController();
  final CommentController commentController = Get.put(CommentController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Cập nhật PostId cho controller để nó biết load comment của bài nào
    commentController.updatePostId(id);

    return Scaffold(
      // Thêm AppBar để người dùng có thể quay lại
        appBar: AppBar(
          title: const Text('Comments'),
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        body: SizedBox(
          width: size.width,
          height: size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Obx(() {
                  // Thêm kiểm tra nếu không có comment
                  if (commentController.comments.isEmpty) {
                    return const Center(
                      child: Text(
                        'No comments yet.',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: commentController.comments.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        // Lấy dữ liệu comment
                        final comment = commentController.comments[index];
                        return ListTile(
                          // Thay vì ảnh, dùng Icon vì model không có avatarUrl
                          leading: const CircleAvatar(
                            backgroundColor: Colors.white30,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          // Bỏ username, chỉ hiển thị nội dung
                          title: Text(
                            comment.content, // Dùng 'content'
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            // Dùng 'createdAt'
                            tego.format(comment.createdAt.toDate()),
                            style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          // Xóa trailing (phần like comment)
                        );
                      },
                    ),
                  );
                }),
              ),
              // Phần nhập comment
              Column(
                children: [
                  const Divider(color: Colors.grey),
                  ListTile(
                    title: TextFormField(
                      controller: _commentController,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                      ),
                    ),
                    trailing: TextButton(
                      onPressed: () {
                        // Gọi hàm postComment từ controller
                        if (_commentController.text.trim().isNotEmpty) {
                          commentController.postComment(_commentController.text.trim());
                          _commentController.clear(); // Xóa text sau khi gửi
                          FocusScope.of(context).unfocus(); // Ẩn bàn phím
                        }
                      },
                      child: const Text(
                        'Send',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ));
  }
}