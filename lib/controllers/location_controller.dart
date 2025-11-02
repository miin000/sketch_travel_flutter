import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '/constants.dart';
import '/models/location.dart';
import '/models/review.dart';
import '/models/post.dart';

class LocationController extends GetxController {
  final Rx<Location?> _location = Rx<Location?>(null);
  Location? get location => _location.value;

  final Rx<List<Review>> _reviews = Rx<List<Review>>([]);
  List<Review> get reviews => _reviews.value;

  final Rx<bool> _isLoading = true.obs;
  bool get isLoading => _isLoading.value;

  final Rx<List<Post>> _posts = Rx<List<Post>>([]);
  List<Post> get posts => _posts.value;

  String _locationId = "";

  // Hàm này được gọi từ LocationScreen
  Future<void> updateLocationId(String locationName) async {
    try { // <-- THÊM TRY
      _locationId = locationName;
      _isLoading.value = true;

      DocumentSnapshot doc = await firestore.collection('locations').doc(_locationId).get();

      if (doc.exists) {
        _location.value = Location.fromJson(doc.data() as Map<String, dynamic>);
      } else {
        Location newLocation = Location(
          id: _locationId,
          name: _locationId,
          province: 'Chưa rõ',
          rating: 0,
          reviewCount: 0,
        );
        await firestore.collection('locations').doc(_locationId).set(newLocation.toJson());
        _location.value = newLocation;
      }

      _posts.bindStream(
        firestore
            .collection('posts')
            .where('locationName', isEqualTo: _locationId)
            .orderBy('createdAt', descending: true)
            .snapshots()
            .map((QuerySnapshot query) {
          return query.docs
              .map((doc) => Post.fromSnap(doc))
              .toList();
        }),
      );

      _reviews.bindStream(
        firestore
            .collection('locations')
            .doc(_locationId)
            .collection('reviews')
            .orderBy('createdAt', descending: true)
            .snapshots()
            .map((QuerySnapshot query) {
          return query.docs
              .map((doc) => Review.fromJson(doc.data() as Map<String, dynamic>))
              .toList();
        }),
      );
      _isLoading.value = false;

    } catch (e) {
      _isLoading.value = false;
      print('Lỗi nghiêm trọng khi tải LocationController: ${e.toString()}');
      Get.snackbar('Lỗi tải địa điểm', e.toString());
    }
  }

  // Hàm thêm đánh giá mới
  Future<void> postReview(double rating, String content) async {
    try {
      if (rating == 0) {
        Get.snackbar('Lỗi', 'Vui lòng chọn số sao đánh giá');
        return;
      }
      _isLoading.value = true;

      String uid = authController.user.uid;
      DocumentSnapshot userDoc = await firestore.collection('users').doc(uid).get();

      // Thêm kiểm tra an toàn
      if (!userDoc.exists) {
        Get.snackbar('Lỗi', 'Không tìm thấy thông tin user.');
        _isLoading.value = false;
        return;
      }
      var userData = userDoc.data() as Map<String, dynamic>;

      var allReviews = await firestore.collection('locations').doc(_locationId).collection('reviews').get();
      int len = allReviews.docs.length;
      String reviewId = 'Review $len';

      Review review = Review(
        id: reviewId,
        locationId: _locationId,
        userId: uid,
        username: userData['username'] ?? 'Người dùng',
        avatarUrl: userData['avatarUrl'] ?? '',
        rating: rating,
        content: content,
        createdAt: Timestamp.now(),
      );

      await firestore
          .collection('locations')
          .doc(_locationId)
          .collection('reviews')
          .doc(reviewId)
          .set(review.toJson());

      // Cập nhật rating trung bình
      var updatedReviewsSnapshot = await firestore
          .collection('locations')
          .doc(_locationId)
          .collection('reviews')
          .get();

      int newReviewCount = updatedReviewsSnapshot.docs.length;
      double totalRating = 0;
      for (var doc in updatedReviewsSnapshot.docs) {
        totalRating += (doc.data()['rating'] as double);
      }
      double newAverageRating = (newReviewCount > 0) ? totalRating / newReviewCount : 0;

      await firestore.collection('locations').doc(_locationId).update({
        'reviewCount': newReviewCount,
        'rating': double.parse(newAverageRating.toStringAsFixed(1)),
      });

      _isLoading.value = false;
      Get.snackbar('Thành công', 'Cảm ơn bạn đã đánh giá!');
    } catch (e) {
      Get.snackbar('Lỗi khi đăng đánh giá', e.toString());
      _isLoading.value = false;
    }
  }
}
