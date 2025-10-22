import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '/constants.dart';
import '/models/comment.dart'; // Model Comment đã có postId nên dùng chung được

class CommentController extends GetxController {
  final Rx<List<Comment>> _comments = Rx<List<Comment>>([]);
  List<Comment> get comments => _comments.value;

  String _postId = "";
  updatePostId(String id) {
    _postId = id;
    getComment();
  }

  getComment() async {
    _comments.bindStream(
      firestore
      // Thay 'videos' bằng 'photos'
          .collection('photos')
          .doc(_postId)
          .collection('comments')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((QuerySnapshot query) {
        return query.docs
            .map((doc) => Comment.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
      }),
    );
  }

  postComment(String commentText) async {
    try {
      if (commentText.isNotEmpty) {
        // DocumentSnapshot userDoc = await firestore // Dòng này không cần thiết nếu bạn không dùng username/avatar trong model Comment
        //     .collection('users')
        //     .doc(authController.user.uid)
        //     .get();

        var allDocs = await firestore
        // Thay 'videos' bằng 'photos'
            .collection('photos')
            .doc(_postId)
            .collection('comments')
            .get();

        int len = allDocs.docs.length;
        String commentId = 'Comment $len';

        Comment comment = Comment(
          id: commentId,
          postId: _postId,
          userId: authController.user.uid,
          content: commentText.trim(),
          createdAt: Timestamp.now(),
        );
        // (Model Comment của bạn không lưu username và avatar, nếu muốn hiển thị ở CommentScreen, bạn cần sửa model và logic ở đây)

        await firestore
        // Thay 'videos' bằng 'photos'
            .collection('photos')
            .doc(_postId)
            .collection('comments')
            .doc(commentId)
            .set(comment.toJson());

        // Tăng số lượng comment cho bài viết (ảnh)
        DocumentSnapshot doc =
        // Thay 'videos' bằng 'photos'
        await firestore.collection('photos').doc(_postId).get();
        await firestore.collection('photos').doc(_postId).update({
          // Đảm bảo model Photo có trường 'commentCount'
          'commentCount': (doc.data()! as dynamic)['commentCount'] + 1,
        });
      }
    } catch (e) {
      Get.snackbar('Error While Commenting', e.toString());
    }
  }

// Lưu ý: Model Comment của bạn (models/comment.dart) không có trường 'likes'.
// File comment_screen.dart đang cố gắng truy cập 'comment.likes'.
// Bạn cần thêm logic cho 'likeComment' nếu muốn giữ chức năng đó.
}