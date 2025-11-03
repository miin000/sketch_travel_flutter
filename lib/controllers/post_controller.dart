import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '/constants.dart';
import '/models/post.dart';
import '/models/app_notification.dart';

class PostController extends GetxController {
  final Rx<List<Post>> _postList = Rx<List<Post>>([]);

  List<Post> get postList => _postList.value;

  @override
  void onInit() {
    super.onInit();
    // Lắng nghe thay đổi trong collection 'posts'
    _postList.bindStream(
      firestore
          .collection('posts')
          .orderBy('createdAt', descending: true) // Sắp xếp mới nhất lên đầu
          .snapshots()
          .map((QuerySnapshot query) {
        List<Post> retVal = [];
        for (var element in query.docs) {
          retVal.add(Post.fromSnap(element));
        }
        return retVal;
      }),
    );
  }

  /// Hàm like / unlike bài viết
  Future<void> likePost(String postId) async {
    try {
      DocumentSnapshot doc = await firestore.collection('posts').doc(postId).get();
      var postData = doc.data() as Map<String, dynamic>;
      String uid = authController.userAccount.uid;
      String postOwnerId = postData['uid']; // ID của chủ bài viết

      if ((postData['likes'] as List).contains(uid)) {
        // Bỏ like
        await firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        // Thêm like
        await firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });

        if (uid != postOwnerId) {
          await _createLikeNotification(postOwnerId, postId);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Lỗi khi thích bài viết: ${e.toString()}');
    }
  }

  //Hàm xóa bài
  Future<void> deletePost(String postId) async {
    try {
      await firestore.collection('posts').doc(postId).delete();
      Get.snackbar('Thành công', 'Đã xóa bài viết');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xóa bài viết: $e');
    }
  }


  // Hàm private để tạo thông báo
  Future<void> _createLikeNotification(String postOwnerId, String postId) async {
    try {
      DocumentSnapshot userDoc = await firestore.collection('users').doc(authController.userAccount.uid).get();
      var userData = userDoc.data() as Map<String, dynamic>;

      String notifId = 'like_${authController.userAccount.uid}_${postId}';

      AppNotification notif = AppNotification(
          id: notifId,
          receiverId: postOwnerId, // Người nhận là chủ post
          senderId: authController.userAccount.uid,
          senderName: userData['username'] ?? 'Một người',
          senderAvatar: userData['avatarUrl'] ?? '',
          type: NotificationType.like,
          message: 'đã thích bài viết của bạn.',
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
      print('Lỗi tạo thông báo like: $e');
    }
  }
}