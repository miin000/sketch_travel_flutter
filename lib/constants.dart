import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Thêm Get
import '/controllers/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';


// SỬA LỖI: Di chuyển danh sách 'pages' vào home_screen.dart
// List pages = [...]; // Xóa dòng này

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
