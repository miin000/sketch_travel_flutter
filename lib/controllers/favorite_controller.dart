import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '/constants.dart';
import '/models/favorite.dart';

class FavoriteController extends GetxController {
  final Rx<List<Favorite>> _favorites = Rx<List<Favorite>>([]);
  List<Favorite> get favorites => _favorites.value;

  // Lấy danh sách bài viết yêu thích của user hiện tại
  void getUserFavorites() {
    _favorites.bindStream(
      firestore
          .collection('favorites')
          .where('userId', isEqualTo: authController.user.uid)
          .snapshots()
          .map((QuerySnapshot query) {
        return query.docs
            .map((doc) => Favorite.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
      }),
    );
  }

  // Kiểm tra user đã thích post này chưa
  Future<bool> isFavorite(String postId) async {
    var query = await firestore
        .collection('favorites')
        .where('userId', isEqualTo: authController.user.uid)
        .where('postId', isEqualTo: postId)
        .get();

    return query.docs.isNotEmpty;
  }

  // Thêm hoặc bỏ yêu thích
  Future<void> toggleFavorite(String postId) async {
    try {
      bool alreadyFavorite = await isFavorite(postId);

      if (alreadyFavorite) {
        // Xóa bản ghi yêu thích
        var query = await firestore
            .collection('favorites')
            .where('userId', isEqualTo: authController.user.uid)
            .where('postId', isEqualTo: postId)
            .get();

        for (var doc in query.docs) {
          await firestore.collection('favorites').doc(doc.id).delete();
        }

        // Giảm số lượng yêu thích của post (ảnh)
        DocumentSnapshot postDoc =
        // Thay 'videos' bằng 'photos'
        await firestore.collection('photos').doc(postId).get();
        // Thay 'favoriteCount' bằng 'likes' (list) nếu bạn dùng logic của PhotoController
        // Hoặc giữ 'favoriteCount' (int) nếu model Photo có
        // Giả sử model Photo không có 'favoriteCount', chúng ta sẽ bỏ qua bước này
        // vì PhotoController đã xử lý 'likes' (list)

        // await firestore.collection('photos').doc(postId).update({
        //   'favoriteCount':
        //   ((postDoc.data()! as dynamic)['favoriteCount'] ?? 1) - 1,
        // });
      } else {
        // Thêm mới bản ghi yêu thích
        String favoriteId =
            '${authController.user.uid}_${postId}_${DateTime.now().millisecondsSinceEpoch}';

        Favorite favorite = Favorite(
          id: favoriteId,
          userId: authController.user.uid,
          postId: postId,
          createdAt: Timestamp.now(),
        );

        await firestore
            .collection('favorites')
            .doc(favoriteId)
            .set(favorite.toJson());

        // Tăng số lượng yêu thích
        DocumentSnapshot postDoc =
        // Thay 'videos' bằng 'photos'
        await firestore.collection('photos').doc(postId).get();
        // Bỏ qua nếu dùng logic 'likes' (list) của PhotoController
        // await firestore.collection('photos').doc(postId).update({
        //   'favoriteCount':
        //   ((postDoc.data()! as dynamic)['favoriteCount'] ?? 0) + 1,
        // });
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}