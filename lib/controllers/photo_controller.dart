import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '/constants.dart';
import '/models/photo.dart';

class PhotoController extends GetxController {
  final Rx<List<Photo>> _photoList = Rx<List<Photo>>([]);

  List<Photo> get photoList => _photoList.value;

  @override
  void onInit() {
    super.onInit();
    // Lắng nghe thay đổi trong collection 'photos'
    _photoList.bindStream(
      firestore.collection('photos').snapshots().map((QuerySnapshot query) {
        List<Photo> retVal = [];
        for (var element in query.docs) {
          retVal.add(Photo.fromSnap(element));
        }
        return retVal;
      }),
    );
  }

  /// Hàm like / unlike ảnh
  Future<void> likePhoto(String id) async {
    try {
      DocumentSnapshot doc = await firestore.collection('photos').doc(id).get();
      var uid = authController.user.uid;

      if ((doc.data()! as dynamic)['likes'].contains(uid)) {
        // Nếu đã like -> bỏ like
        await firestore.collection('photos').doc(id).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        // Nếu chưa like -> thêm like
        await firestore.collection('photos').doc(id).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Lỗi khi thích ảnh: ${e.toString()}');
    }
  }
}
