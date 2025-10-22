import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart'; // Thêm import material để dùng context
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/constants.dart';
import '/models/user.dart' as model;
import '/views/screens/auth/login_screen.dart';
import '/views/screens/home_screen.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  late Rx<User?> _user;
  final Rx<File?> _pickedImage = Rx<File?>(null);

  File? get profilePhoto => _pickedImage.value;
  User get user => _user.value!;

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(firebaseAuth.currentUser);
    _user.bindStream(firebaseAuth.authStateChanges());
    // In ra thông báo khi bắt đầu lắng nghe thay đổi trạng thái đăng nhập
    print("AuthController: Bắt đầu lắng nghe trạng thái đăng nhập...");
    ever(_user, _setInitialScreen);
  }

  void _setInitialScreen(User? user) {
    // In ra trạng thái người dùng mỗi khi có thay đổi
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
      _pickedImage.value = File(pickedImage.path);
    }
  }

  Future<String> _uploadToStorage(File image) async {
    Reference ref = firebaseStorage
        .ref()
        .child('profilePics')
        .child(firebaseAuth.currentUser!.uid);

    UploadTask uploadTask = ref.putFile(image);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> registerUser(
      String username, String email, String password, File? image) async {
    try {
      if (username.isNotEmpty &&
          email.isNotEmpty &&
          password.isNotEmpty &&
          image != null) {
        UserCredential cred = await firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        String downloadUrl = await _uploadToStorage(image);
        model.User newUser = model.User(
          uid: cred.user!.uid,
          email: email,
          username: username,
          displayName: username,
          avatarUrl: downloadUrl,
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
