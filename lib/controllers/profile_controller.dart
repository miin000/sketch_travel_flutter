import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '/constants.dart';
import '/models/post.dart';
import '/models/favorite_location.dart';

class ProfileController extends GetxController {
  // Dữ liệu User (cho header)
  final Rx<Map<String, dynamic>> _user = Rx<Map<String, dynamic>>({});
  Map<String, dynamic> get user => _user.value;
  Rx<String> _uid = "".obs;

  // Dữ liệu cho 3 tab
  final Rx<List<Post>> _postedList = Rx<List<Post>>([]);
  final Rx<List<Post>> _likedList = Rx<List<Post>>([]);
  final Rx<List<FavoriteLocation>> _favoritedLocationsList = Rx<List<FavoriteLocation>>([]);

  List<Post> get postedList => _postedList.value;
  List<Post> get likedList => _likedList.value;
  List<FavoriteLocation> get favoritedLocationsList => _favoritedLocationsList.value;

  // Trạng thái loading
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  final Rx<bool> _isFetchingTabs = true.obs;
  bool get isFetchingTabs => _isFetchingTabs.value;

  updateUserId(String uid) {
    _uid.value = uid;
    // Tải đồng thời tất cả dữ liệu
    getUserData(); // Lấy thông tin header
    fetchTabContent(); // Lấy nội dung cho cả 3 tab
  }

  // Lấy thông tin Header (Stats: Following, Followers, Likes)
  getUserData() async {
    List<String> postThumbnails = []; // Chỉ ảnh đầu tiên của mỗi bài post
    var myPosts = await firestore
        .collection('posts')
        .where('uid', isEqualTo: _uid.value)
        .get();

    int likes = 0;
    for (int i = 0; i < myPosts.docs.length; i++) {
      var postData = myPosts.docs[i].data();
      likes += (postData['likes'] as List).length;
      List<String> postImages = List.from(postData['imageUrls'] ?? []);
      if (postImages.isNotEmpty) {
        postThumbnails.add(postImages[0]);
      }
    }

    _postedList.value = myPosts.docs.map((doc) => Post.fromSnap(doc)).toList();

    DocumentSnapshot userDoc =
    await firestore.collection('users').doc(_uid.value).get();
    final userData = userDoc.data() as Map<String, dynamic>?;

    if (userData == null) {
      print('ProfileController: Không tìm thấy user document (uid: ${_uid.value}).');
      return;
    }

    String name = userData['name'] ?? userData['username'];
    String profilePhoto = userData['profilePhoto'] ?? userData['avatarUrl'];
    int followers = 0;
    int following = 0;
    bool isFollowing =false;

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

    var isFollowingDoc = await firestore
        .collection('users')
        .doc(_uid.value)
        .collection('followers')
        .doc(authController.user.uid)
        .get();
    isFollowing = isFollowingDoc.exists;

    _user.value={
      'followers':followers.toString(),
      'following':following.toString(),
      'isFollowing':isFollowing,
      'likes':likes.toString(),
      'profilePhoto':profilePhoto,
      'name':name,
      'username': userData['username'] ?? '',
      'postThumbnails': postThumbnails,
    };
    update();
  }

  // Tải nội dung cho các tab (Đã thích, Đã yêu thích)
  fetchTabContent() async {
    _isFetchingTabs.value = true;

    // 1. Tải các bài viết đã thích
    var likedPostsQuery = await firestore
        .collection('posts')
    // === SỬA LỖI TẠI ĐÂY (Dòng 111) ===
        .where('likes', arrayContains: _uid.value)
    // ===================================
        .get();
    _likedList.value = likedPostsQuery.docs.map((doc) => Post.fromSnap(doc)).toList();

    // 2. Tải các địa điểm đã yêu thích
    var favLocationsQuery = await firestore
        .collection('favoriteLocations')
        .where('userId', isEqualTo: _uid.value)
        .get();
    _favoritedLocationsList.value = favLocationsQuery.docs
        .map((doc) => FavoriteLocation.fromJson(doc.data()))
        .toList();

    _isFetchingTabs.value = false;
  }

  // Hàm Follow (đã sửa lỗi spam)
  followUser() async {
    if (_isLoading) return;
    try {
      _isLoading = true;
      update();

      var doc = await firestore.collection('users').doc(_uid.value).collection('followers')
          .doc(authController.user.uid).get();

      if(!doc.exists){
        await firestore.collection('users').doc(_uid.value).collection('followers')
            .doc(authController.user.uid).set({});
        await firestore.collection('users').doc(authController.user.uid).collection('following')
            .doc(_uid.value).set({});
      }else{
        await firestore.collection('users').doc(_uid.value).collection('followers')
            .doc(authController.user.uid).delete();
        await firestore.collection('users').doc(authController.user.uid).collection('following')
            .doc(_uid.value).delete();
      }
      await getUserData(); // Tải lại stats
    } catch (e) {
      Get.snackbar('Lỗi', e.toString());
    } finally {
      _isLoading = false;
      update();
    }
  }

  // Hàm để Sửa tên
  Future<void> updateUserName(String newName) async {
    if (newName.isEmpty) {
      Get.snackbar('Lỗi', 'Tên không thể để trống');
      return;
    }
    try {
      // === TẠO TỪ KHÓA MỚI ===
      String newUsername = newName.toLowerCase().replaceAll(' ', '');
      List<String> nameParts = newName.toLowerCase().split(' ');
      List<String> keywords = [newUsername, ...nameParts];

      await firestore.collection('users').doc(_uid.value).update({
        'name': newName,
        'username': newUsername,
        'displayName': newName,
        'searchKeywords': keywords, // <-- Cập nhật mảng từ khóa
      });
      // =======================

      await getUserData(); // Tải lại
      Get.back(); // Đóng dialog
      Get.snackbar('Thành công', 'Đã cập nhật tên');
    } catch (e) {
      Get.snackbar('Lỗi', e.toString());
    }
  }
}