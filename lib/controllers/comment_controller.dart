import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '/constants.dart';
import '/models/comment.dart';
import '/models/app_notification.dart';

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
        String currentUserId = authController.userAccount.uid;

        DocumentSnapshot userDoc = await firestore
            .collection('users')
            .doc(currentUserId)
            .get();
        var userData = userDoc.data() as Map<String, dynamic>;

        DocumentSnapshot postDoc =
        await firestore.collection('posts').doc(_postId).get();
        String postOwnerId = (postDoc.data()! as dynamic)['uid'];

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
          userId: currentUserId,
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

        // Tăng số lượng comment
        await firestore.collection('posts').doc(_postId).update({
          'commentCount': (postDoc.data()! as dynamic)['commentCount'] + 1,
        });

        if (currentUserId != postOwnerId) {
          await _createCommentNotification(postOwnerId, _postId, userData);
        }
      }
    } catch (e) {
      Get.snackbar('Error While Commenting', e.toString());
    }
  }

  Future<void> _createCommentNotification(String postOwnerId, String postId, Map<String, dynamic> senderData) async {
    try {
      String currentUserId = authController.userAccount.uid;
      String notifId = 'comment_${currentUserId}_${postId}_${Timestamp.now().millisecondsSinceEpoch}';

      AppNotification notif = AppNotification(
          id: notifId,
          receiverId: postOwnerId, // Người nhận là chủ post
          senderId: currentUserId,
          senderName: senderData['username'] ?? 'Một người',
          senderAvatar: senderData['avatarUrl'] ?? '',
          type: NotificationType.comment,
          message: 'đã bình luận bài viết của bạn.',
          targetId: postId, // ID của bài post
          createdAt: Timestamp.now(),
          isRead: false
      );

      // Ghi thông báo vào sub-collection của NGƯỜI NHẬN
      await firestore
          .collection('notifications')
          .doc(postOwnerId)
          .collection('userNotifications')
          .doc(notifId)
          .set(notif.toJson());

    } catch (e) {
      print('Lỗi tạo thông báo comment: $e');
    }
  }
}