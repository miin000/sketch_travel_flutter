import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '/constants.dart';
import '/controllers/cloudinary_controller.dart';
import '/models/post.dart';
import '/views/screens/home_screen.dart';

class UploadPostController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  // Dùng để lưu trữ byte của các ảnh đã chọn
  final Rx<List<Uint8List>> _pickedImageBytesList = Rx<List<Uint8List>>([]);
  List<Uint8List> get pickedImageBytesList => _pickedImageBytesList.value;

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

  // Hàm tải bài viết (gồm nhiều ảnh)
  Future<void> uploadPost(String description, String locationName) async {
    try {
      if (pickedImageBytesList.isEmpty) {
        Get.snackbar('Lỗi', 'Vui lòng chọn ít nhất một ảnh');
        return;
      }

      String uid = firebaseAuth.currentUser!.uid;

      // Lấy thông tin user (username, avatarUrl)
      DocumentSnapshot userDoc =
      await firestore.collection('users').doc(uid).get();
      var userData = userDoc.data() as Map<String, dynamic>;
      String username = userData['username'] ?? '';
      String avatarUrl = userData['avatarUrl'] ?? '';

      // Tải từng ảnh lên Cloudinary và lấy URL
      List<String> imageUrls = [];
      for (var bytes in pickedImageBytesList) {
        String url = await CloudinaryController.instance.uploadImage(bytes);
        imageUrls.add(url);
      }

      // Lấy ID bài viết mới
      var allPosts = await firestore.collection('posts').get();
      int len = allPosts.docs.length;
      String postId = 'Post $len';

      // Tạo đối tượng Post
      Post newPost = Post(
        id: postId,
        uid: uid,
        username: username,
        avatarUrl: avatarUrl,
        locationName: locationName,
        description: description,
        imageUrls: imageUrls,
        createdAt: Timestamp.now(),
        likes: [],
        commentCount: 0,
      );

      // Lưu vào Firestore
      await firestore.collection('posts').doc(postId).set(newPost.toJson());

      // Xóa ảnh đã chọn và quay về HomeScreen
      clearImages();
      Get.offAll(() => const HomeScreen());
      Get.snackbar('Thành công', 'Bài viết đã được đăng!');
    } catch (e) {
      Get.snackbar('Lỗi khi đăng bài', e.toString());
    }
  }
}