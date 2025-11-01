import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '/constants.dart';
import '/models/favorite_location.dart';

class LocationFavoriteController extends GetxController {
  final Rx<bool> _isFavorite = false.obs;
  bool get isFavorite => _isFavorite.value;
  String _locationId = "";

  // Hàm này được gọi từ LocationScreen
  Future<void> updateLocationId(String locationName) async {
    _locationId = locationName;
    checkIfFavorite();
  }

  // Kiểm tra xem user đã yêu thích địa điểm này chưa
  Future<void> checkIfFavorite() async {
    if (_locationId.isEmpty) return;

    var query = await firestore
        .collection('favoriteLocations') // Collection yêu thích riêng
        .where('userId', isEqualTo: authController.user.uid)
        .where('locationId', isEqualTo: _locationId)
        .get();

    _isFavorite.value = query.docs.isNotEmpty;
  }

  // Hàm nhấn nút Yêu thích / Bỏ yêu thích
  Future<void> toggleFavorite() async {
    try {
      String uid = authController.user.uid;

      if (_isFavorite.value) {
        // Nếu đã thích -> Bỏ thích
        var query = await firestore
            .collection('favoriteLocations')
            .where('userId', isEqualTo: uid)
            .where('locationId', isEqualTo: _locationId)
            .get();

        for (var doc in query.docs) {
          await firestore.collection('favoriteLocations').doc(doc.id).delete();
        }
        _isFavorite.value = false;
      } else {
        // Nếu chưa thích -> Thêm yêu thích
        String id = 'FavLoc_${uid}_$_locationId'; // Tạo ID duy nhất

        FavoriteLocation fav = FavoriteLocation(
          id: id,
          userId: uid,
          locationId: _locationId,
          createdAt: Timestamp.now(),
        );

        await firestore.collection('favoriteLocations').doc(id).set(fav.toJson());
        _isFavorite.value = true;
      }
    } catch (e) {
      Get.snackbar('Lỗi', e.toString());
    }
  }
}