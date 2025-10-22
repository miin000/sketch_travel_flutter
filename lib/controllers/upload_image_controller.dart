import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import '/constants.dart';
import '/models/photo.dart'; // tạo model Photo tương tự như Video

class UploadImageController extends GetxController {
  // Upload ảnh lên Firebase Storage
  Future<String> _uploadImageToStorage(String id, File imageFile) async {
    try {
      Reference ref = firebaseStorage.ref().child('images').child(id);
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snap = await uploadTask;
      String downloadUrl = await snap.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }

  // Upload bài đăng ảnh (ảnh + caption)
  Future<void> uploadImage(String caption, File imageFile) async {
    try {
      String uid = firebaseAuth.currentUser!.uid;

      // Lấy thông tin user
      DocumentSnapshot userDoc =
      await firestore.collection('users').doc(uid).get();

      // Lấy số lượng bài đăng hiện có để tạo ID mới
      var allDocs = await firestore.collection('photos').get();
      int len = allDocs.docs.length;

      // Upload ảnh lên Storage
      String imageUrl = await _uploadImageToStorage('Photo $len', imageFile);

      // Tạo object Photo (model riêng)
      Photo photo = Photo(
        id: 'Photo $len',
        uid: uid,
        username: (userDoc.data()! as Map<String, dynamic>)['username'],
        caption: caption,
        imageUrl: imageUrl,
        likes: [],
        commentCount: 0,
        createdAt: Timestamp.now(),
        avatarUrl: (userDoc.data()! as Map<String, dynamic>)['avatarUrl'],
      );

      // Lưu vào Firestore
      await firestore.collection('photos').doc('Photo $len').set(photo.toJson());

      Get.back();
      Get.snackbar('Thành công', 'Ảnh đã được tải lên!');
    } catch (e) {
      Get.snackbar('Lỗi tải ảnh', e.toString());
    }
  }
}
