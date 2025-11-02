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

List pages=[
  PostFeedScreen(),
  SearchScreen(),
  AddPostScreen(),
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

AuthController get authController => Get.find<AuthController>();
