import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '/constants.dart';

class ProfileController extends GetxController {
  final Rx<Map<String, dynamic>> _user = Rx<Map<String, dynamic>>({});

  Map<String, dynamic> get user => _user.value;

  final Rx<String> _uid = "".obs;

  updateUserId(String uid) {
    _uid.value = uid;
    getUserData();
  }

  getUserData() async {
    List<String> thumbnails = [];
    var myPhotos = await firestore // Đổi tên biến
    // Thay 'videos' bằng 'photos'
        .collection('photos')
        .where('uid', isEqualTo: _uid.value)
        .get();

    for (int i = 0; i < myPhotos.docs.length; i++) {
      // Thay 'thumbnail' bằng 'imageUrl' để khớp model Photo
      thumbnails.add((myPhotos.docs[i].data() as dynamic)['imageUrl']);
    }
    DocumentSnapshot userDoc =
    await firestore.collection('users').doc(_uid.value).get();
    final userData = userDoc.data()! as dynamic;

    // Sửa tên trường để khớp model User (models/user.dart)
    String name = userData['username']; // Thay 'name' bằng 'username'
    String profilePhoto = userData['avatarUrl']; // Thay 'profilePhoto' bằng 'avatarUrl'
    int likes = 0;
    int followers = 0;
    int following = 0;
    bool isFollowing = false;

    // Tính tổng likes từ collection 'photos'
    for (var item in myPhotos.docs) {
      likes += (item.data()['likes'] as List).length;
    }

    // Logic follow/following giữ nguyên
    var followerDoc = await firestore
        .collection('users')
        .doc(_uid.value)
        .collection('followers')
        .get();
    var followingDoc = await firestore
        .collection('users')
        .doc(_uid.value)
        .collection('following')
        .get();
    followers = followerDoc.docs.length;
    following = followingDoc.docs.length;
    await firestore
        .collection('users')
        .doc(_uid.value)
        .collection('followers')
        .doc(authController.user.uid)
        .get()
        .then((value) {
      if (value.exists) {
        isFollowing = true;
      } else {
        isFollowing = false;
      }
    });

    _user.value = {
      'followers': followers.toString(),
      'following': following.toString(),
      'isFollowing': isFollowing,
      'likes': likes.toString(),
      'profilePhoto': profilePhoto, // Key này được ProfileScreen sử dụng
      'name': name, // Key này được ProfileScreen sử dụng
      'thumbnails': thumbnails,
    };
    update();
  }

  followUser() async {
    var doc = await firestore
        .collection('users')
        .doc(_uid.value)
        .collection('followers')
        .doc(authController.user.uid)
        .get();
    if (!doc.exists) {
      await firestore
          .collection('users')
          .doc(_uid.value)
          .collection('followers')
          .doc(authController.user.uid)
          .set({});
      await firestore
          .collection('users')
          .doc(authController.user.uid)
          .collection('following')
          .doc(_uid.value)
          .set({});
      _user.value.update('followers', (value) => (int.parse(value) + 1).toString());
    } else {
      await firestore
          .collection('users')
          .doc(_uid.value)
          .collection('followers')
          .doc(authController.user.uid)
          .delete();
      await firestore
          .collection('users')
          .doc(authController.user.uid)
          .collection('following')
          .doc(_uid.value)
          .delete();
      _user.value.update('followers', (value) => (int.parse(value) - 1).toString());
    }
    _user.value.update('isFollowing', (value) => !value);
    update();
  }
}