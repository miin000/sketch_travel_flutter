import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '/constants.dart';
import '/controllers/cloudinary_controller.dart';
import '/models/osm_location.dart';
import '/models/post.dart';
import '/views/screens/home_screen.dart';
import 'package:flutter/widgets.dart';

class UploadPostController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  /// Ảnh mới chọn
  RxList<Uint8List> pickedImageBytesList = <Uint8List>[].obs;

  /// Ảnh cũ khi chỉnh sửa
  RxList<String> existingImageUrls = <String>[].obs;

  /// Địa điểm
  Rxn<OsmLocation> selectedLocation = Rxn<OsmLocation>();

  /// Loading
  RxBool isLoading = false.obs;

  /// --- CHỌN ẢNH ---
  Future<void> pickImages() async {
    try {
      final pickedFiles = await _picker.pickMultiImage(imageQuality: 85);
      if (pickedFiles == null || pickedFiles.isEmpty) return;

      pickedImageBytesList.clear();
      for (final file in pickedFiles) {
        final bytes = await file.readAsBytes();
        pickedImageBytesList.add(bytes);
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể chọn ảnh: $e');
    }
  }

  /// --- LOAD ẢNH CŨ KHI CHỈNH SỬA ---
  void loadExistingImages(List<String> urls) {
    existingImageUrls.assignAll(urls);
  }

  /// --- XÓA ẢNH ---
  void clearImages() {
    pickedImageBytesList.clear();
    existingImageUrls.clear();
  }

  // Xóa 1 ảnh mới (ảnh vừa chọn, chưa upload)
  void removePickedImageAt(int index) {
    if (index >= 0 && index < pickedImageBytesList.length) {
      pickedImageBytesList.removeAt(index);
      if (Get.isRegistered<UploadPostController>()) {
        pickedImageBytesList.refresh();
      }
    }
  }

  // Xóa 1 ảnh cũ (đang chỉnh sửa bài viết)
  void removeExistingImageAt(int index) {
    if (index >= 0 && index < existingImageUrls.length) {
      existingImageUrls.removeAt(index);
      if (Get.isRegistered<UploadPostController>()) {
        existingImageUrls.refresh();
      }
    }
  }

  /// --- CHỌN / XÓA ĐỊA ĐIỂM ---
  void selectLocation(OsmLocation location) {
    selectedLocation.value = location;
  }

  void clearSelectedLocation() {
    selectedLocation.value = null;
  }

  /// --- LẤY DANH SÁCH ẢNH HIỆN TẠI ---
  List<String> getCurrentImageUrls() {
    // Nếu không có ảnh mới → dùng ảnh cũ
    if (pickedImageBytesList.isEmpty) {
      return existingImageUrls.toList();
    }
    return [];
  }

  //TẢI BÀI VIẾT MỚI LÊN CLOUDINARY + FIRESTORE
  Future<void> uploadPost(
    String description,
    List<String> oldImages,
    String locationName,
  ) async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;

      if (pickedImageBytesList.isEmpty) {
        Get.snackbar('Thiếu ảnh', 'Vui lòng chọn ít nhất 1 ảnh');
        return;
      }

      final user = firebaseAuth.currentUser;
      if (user == null) throw Exception('Chưa đăng nhập');

      final userDoc = await firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() as Map<String, dynamic>? ?? {};
      final username = userData['username'] ?? '';
      final avatarUrl = userData['avatarUrl'] ?? '';

      // Upload ảnh mới lên Cloudinary
      List<String> uploadedUrls = [];
      for (final bytes in pickedImageBytesList) {
        final url = await CloudinaryController.instance.uploadImage(bytes);
        uploadedUrls.add(url);
      }

      final imageUrls = [...uploadedUrls, ...oldImages];

      final postId = firestore.collection('posts').doc().id;

      final newPost = Post(
        id: postId,
        uid: user.uid,
        username: username,
        avatarUrl: avatarUrl,
        locationName: locationName,
        description: description,
        imageUrls: imageUrls,
        createdAt: Timestamp.now(),
        likes: [],
        commentCount: 0,
      );

      await firestore.collection('posts').doc(postId).set(newPost.toJson());

      Get.snackbar(
        'Thành công',
        'Bài viết mới đã được đăng!',
        snackPosition: SnackPosition.BOTTOM,
      );

      clearImages();
      clearSelectedLocation();

      Get.offAll(() => const HomeScreen());

    } catch (e) {
      Get.snackbar('Lỗi', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// --- CẬP NHẬT BÀI VIẾT ---
  Future<void> updatePost(
    String postId,
    String description,
    List<String> existingImages,
    String locationName,
  ) async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;

      // Upload thêm ảnh mới nếu có
      List<String> uploadedUrls = [];
      for (final bytes in pickedImageBytesList) {
        final url = await CloudinaryController.instance.uploadImage(bytes);
        uploadedUrls.add(url);
      }

      final allImages = [...existingImages, ...uploadedUrls];

      await firestore.collection('posts').doc(postId).update({
        'description': description,
        'imageUrls': allImages,
        'locationName': locationName,
        'updatedAt': Timestamp.now(),
      });

      Get.snackbar(
        'Thành công',
        'Bài viết đã được cập nhật',
        snackPosition: SnackPosition.BOTTOM,
      );

      clearImages();
      clearSelectedLocation();

      await Future.delayed(const Duration(seconds: 1));
      if (Get.isOverlaysOpen == false && Get.isDialogOpen != true) {
        Future.microtask(() {
          if (Get.context != null) {
            Get.offAll(() => const HomeScreen());
          }
        });
      }

    } catch (e) {
      Get.snackbar('Lỗi cập nhật', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
