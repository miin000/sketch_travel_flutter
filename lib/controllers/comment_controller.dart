import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '/constants.dart';
import '/models/comment.dart';

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
          .collection('posts')
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
        // 1. Lấy thông tin user (username, avatar)
        DocumentSnapshot userDoc = await firestore
            .collection('users')
            .doc(authController.user.uid)
            .get();
        var userData = userDoc.data() as Map<String, dynamic>;

        var allDocs = await firestore
            .collection('posts')
            .doc(_postId)
            .collection('comments')
            .get();

        int len = allDocs.docs.length;
        String commentId = 'Comment $len';

        Comment comment = Comment(
          id: commentId,
          postId: _postId,
          userId: authController.user.uid,
          username: userData['username'] ?? '',
          avatarUrl: userData['avatarUrl'] ?? '',
          content: commentText.trim(),
          createdAt: Timestamp.now(),
        );

        await firestore
            .collection('posts')
            .doc(_postId)
            .collection('comments')
            .doc(commentId)
            .set(comment.toJson());

        // Tăng số lượng comment cho bài viết (post)
        DocumentSnapshot doc =
        await firestore.collection('posts').doc(_postId).get();
        await firestore.collection('posts').doc(_postId).update({
          'commentCount': (doc.data()! as dynamic)['commentCount'] + 1,
        });
      }
    } catch (e) {
      Get.snackbar('Error While Commenting', e.toString());
    }
  }
}