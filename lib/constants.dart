import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/controllers/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '/views/screens/add_post_screen.dart';
import '/views/screens/profile_screen.dart';
import '/views/screens/search_screen.dart';
import '/views/screens/post_feed_screen.dart';


// SỬA LỖI: Di chuyển danh sách 'pages' vào home_screen.dart
List pages=[
  PostFeedScreen(), // <-- ĐÃ THAY ĐỔI
  SearchScreen(),
  AddPostScreen(), // <-- ĐÃ THAY ĐỔI
  Text('Message Screen'),
  ProfileScreen(uid: authController.user.uid),

];

// COLORS
const backgroundColor = Colors.black;
var buttonColor = Colors.red[400];
const borderColor = Colors.grey;

// FIREBASE
var firebaseAuth = FirebaseAuth.instance;
var firebaseStorage = FirebaseStorage.instance;
var firestore = FirebaseFirestore.instance;

// SỬA LỖI: Thay đổi cách truy cập controller để tránh lỗi khởi tạo
AuthController get authController => Get.find<AuthController>();
