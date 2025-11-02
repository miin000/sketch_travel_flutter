import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '/constants.dart';
import '/controllers/cloudinary_controller.dart';
import '/models/post.dart';
import '/views/screens/home_screen.dart';
import '/models/osm_location.dart';

class UploadPostController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  // Dùng để lưu trữ byte của các ảnh đã chọn
  final Rx<List<Uint8List>> _pickedImageBytesList = Rx<List<Uint8List>>([]);
  List<Uint8List> get pickedImageBytesList => _pickedImageBytesList.value;

  final Rx<OsmLocation?> _selectedLocation = Rx<OsmLocation?>(null);
  OsmLocation? get selectedLocation => _selectedLocation.value;

  final Rx<bool> isLoading = false.obs;

  void selectLocation(OsmLocation location) {
    _selectedLocation.value = location;
  }

  void clearSelectedLocation() {
    _selectedLocation.value = null;
  }

  // Hàm chọn nhiều ảnh
  Future<void> pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      List<Uint8List> bytesList = [];
      for (var file in pickedFiles) {
        bytesList.add(await file.readAsBytes());
      }
      _pickedImageBytesList.value = bytesList;
    }
  }

  // Hàm xóa danh sách ảnh đã chọn
  void clearImages() {
    _pickedImageBytesList.value = [];
  }

  // Hàm tải bài viết
  Future<void> uploadPost(String description) async {
    // Chống spam click
    if (isLoading.value) return;

    try {
      isLoading.value = true;

      if (pickedImageBytesList.isEmpty) {
        Get.snackbar('Lỗi', 'Vui lòng chọn ít nhất một ảnh');
        isLoading.value = false; // Tắt loading nếu lỗi
        return;
      }
      if (_selectedLocation.value == null) {
        Get.snackbar('Lỗi', 'Vui lòng chọn một địa điểm');
        isLoading.value = false; // Tắt loading nếu lỗi
        return;
      }

      String uid = firebaseAuth.currentUser!.uid;
      DocumentSnapshot userDoc =
      await firestore.collection('users').doc(uid).get();
      var userData = userDoc.data() as Map<String, dynamic>;
      String username = userData['username'] ?? '';
      String avatarUrl = userData['avatarUrl'] ?? '';

      List<String> imageUrls = [];
      for (var bytes in pickedImageBytesList) {
        String url = await CloudinaryController.instance.uploadImage(bytes);
        imageUrls.add(url);
      }

      var allPosts = await firestore.collection('posts').get();
      int len = allPosts.docs.length;
      String postId = 'Post $len';

      Post newPost = Post(
        id: postId,
        uid: uid,
        username: username,
        avatarUrl: avatarUrl,
        locationName: _selectedLocation.value!.name,
        description: description,
        imageUrls: imageUrls,
        createdAt: Timestamp.now(),
        likes: [],
        commentCount: 0,
      );

      await firestore.collection('posts').doc(postId).set(newPost.toJson());

      clearImages();
      clearSelectedLocation();
      Get.offAll(() => const HomeScreen());
      Get.snackbar('Thành công', 'Bài viết đã được đăng!');

    } catch (e) {
      Get.snackbar('Lỗi khi đăng bài', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}