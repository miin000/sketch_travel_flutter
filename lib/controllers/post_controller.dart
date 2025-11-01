import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '/constants.dart';
import '/models/post.dart';

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
  Future<void> likePost(String id) async {
    try {
      DocumentSnapshot doc = await firestore.collection('posts').doc(id).get();
      var uid = authController.user.uid;

      if ((doc.data()! as dynamic)['likes'].contains(uid)) {
        // Nếu đã like -> bỏ like
        await firestore.collection('posts').doc(id).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        // Nếu chưa like -> thêm like
        await firestore.collection('posts').doc(id).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Lỗi khi thích bài viết: ${e.toString()}');
    }
  }
}