import 'dart:typed_data'; // Đảm bảo dùng Uint8List
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart'; // <-- KHÔNG CẦN NỮA
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/constants.dart';
import '/models/user.dart' as model;
import '/views/screens/auth/login_screen.dart';
import '/views/screens/home_screen.dart';
import 'cloudinary_controller.dart'; // <-- THÊM IMPORT NÀY

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  late Rx<User?> _user;

  final Rx<Uint8List?> _pickedImageBytes = Rx<Uint8List?>(null);
  Uint8List? get profilePhoto => _pickedImageBytes.value;
  User get user => _user.value!;

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(firebaseAuth.currentUser);
    _user.bindStream(firebaseAuth.authStateChanges());
    print("AuthController: Bắt đầu lắng nghe trạng thái đăng nhập...");
    ever(_user, _setInitialScreen);
  }

  void _setInitialScreen(User? user) {
    print("AuthController: Trạng thái đăng nhập thay đổi. User là: ${user?.uid ?? 'null'}");
    if (user == null) {
      print("AuthController: Điều hướng đến LoginScreen.");
      Get.offAll(() => LoginScreen());
    } else {
      print("AuthController: Điều hướng đến HomeScreen.");
      Get.offAll(() => const HomeScreen());
    }
  }

  void pickImage() async {
    final pickedImage =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      Get.snackbar("Profile picture",
          "You have successfully selected your profile picture");
      _pickedImageBytes.value = await pickedImage.readAsBytes();
    }
  }

  // === HÀM NÀY KHÔNG CẦN NỮA ===
  // Future<String> _uploadToStorage(Uint8List imageBytes) async {
  //   Reference ref = firebaseStorage
  //       .ref()
  //       ...
  // }
  // ===============================

  Future<void> registerUser(
      String username, String email, String password, Uint8List? imageBytes) async {

    UserCredential? cred;

    try {
      if (username.isNotEmpty &&
          email.isNotEmpty &&
          password.isNotEmpty &&
          imageBytes != null) {

        cred = await firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // === SỬA TẠI ĐÂY ===
        // Tải ảnh lên Cloudinary thay vì Firebase Storage
        print('AuthController: Đang tải ảnh lên Cloudinary...');
        String downloadUrl = await CloudinaryController.instance.uploadImage(imageBytes);
        print('AuthController: Đã tải lên. URL: $downloadUrl');
        // ==================

        model.User newUser = model.User(
          uid: cred.user!.uid,
          email: email,
          username: username,
          displayName: username,
          avatarUrl: downloadUrl, // Dùng URL từ Cloudinary
          bio: '',
          createdAt: Timestamp.now(),
        );

        await firestore
            .collection('users')
            .doc(cred.user!.uid)
            .set(newUser.toJson());

      } else {
        Get.snackbar('Error creating account', "Please fill in all fields");
      }
    } catch (e) {
      Get.snackbar('Error creating account', e.toString());
      print("AuthController: Đã xảy ra lỗi khi đăng ký (Lỗi: ${e.toString()})");

      if (cred != null) {
        User? user = cred.user;
        if (user != null) {
          print("AuthController: Đang xóa user Auth bị hỏng: ${user.uid}");
          await user.delete();
          print("AuthController: Đã xóa user Auth.");
        }
      }
    }
  }

  Future<void> loginUser(String email, String password) async {
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password);
      } else {
        Get.snackbar('Error logging in', "Please enter all the fields");
      }
    } catch (e) {
      Get.snackbar('Error logging in', e.toString());
    }
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }
}