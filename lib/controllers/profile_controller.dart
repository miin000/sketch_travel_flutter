import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '/constants.dart';
import '/models/post.dart';
import '/models/favorite_location.dart';
import '/models/app_notification.dart';

class ProfileController extends GetxController {
  // === SỬA LỖI UI KHÔNG UPDATE ===
  // Thay vì Rx<Map?>, chúng ta dùng RxMap.
  // RxMap là một Map "thông minh" tự thông báo khi có thay đổi.
  final RxMap<String, dynamic> _user = RxMap<String, dynamic>();
  Map<String, dynamic> get user => _user;
  // ===============================

  final Rx<String> _uid = "".obs;
  final Rx<List<Post>> _postedList = Rx<List<Post>>([]);
  final Rx<List<Post>> _likedList = Rx<List<Post>>([]);
  final Rx<List<FavoriteLocation>> _favoritedLocationsList =
  Rx<List<FavoriteLocation>>([]);
  List<Post> get postedList => _postedList.value;
  List<Post> get likedList => _likedList.value;
  List<FavoriteLocation> get favoritedLocationsList =>
      _favoritedLocationsList.value;

  final Rx<bool> _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final Rx<bool> _isFetchingTabs = true.obs;
  bool get isFetchingTabs => _isFetchingTabs.value;

  updateUserId(String uid) {
    if (uid.isEmpty) {
      return;
    }
    _uid.value = uid;
    // Xóa dữ liệu cũ (nếu có) trước khi tải
    _user.clear();
    getUserData();
    fetchTabContent();
  }

  getUserData() async {
    List<String> postThumbnails = [];
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

    final data = userDoc.data();
    if (data == null || data is! Map) {
      print('ProfileController: Không tìm thấy user document (uid: ${_uid.value}).');
      return;
    }
    final userData = Map<String, dynamic>.from(data as Map<dynamic, dynamic>);

    String name = userData['name'] ?? userData['username'];
    String profilePhoto = userData['profilePhoto'] ?? userData['avatarUrl'];
    int followers = 0;
    int following = 0;
    int friends = 0;

    var friendsList = userData['friends'] as List? ?? [];
    friends = friendsList.length;

    List followersList = List.from(userData['followers'] ?? []);
    bool isFollowing = followersList.contains(authController.userAccount.uid);

    DocumentSnapshot myUserDoc = await firestore
        .collection('users')
        .doc(authController.userAccount.uid)
        .get();

    final myData = myUserDoc.data() as Map<String, dynamic>? ?? {};
    List followingList = List.from(myData['following'] ?? []);
    bool isFollowedBy = followingList.contains(_uid.value);

    followers = followersList.length;
    following = followingList.length;

    _user.addAll({
      'followers': followers.toString(),
      'following': following.toString(),
      'isFollowing': isFollowing,
      'isFollowedBy': isFollowedBy,
      'friends': friends.toString(),
      'likes': likes.toString(),
      'profilePhoto': profilePhoto,
      'name': name,
      'username': userData['username'] ?? '',
      'postThumbnails': postThumbnails,
    });
    _user.refresh();
  }

  fetchTabContent() async {
    _isFetchingTabs.value = true;
    try {
      var likedPostsQuery = await firestore
          .collection('posts')
          .where('likes', arrayContains: _uid.value)
          .get();
      _likedList.value =
          likedPostsQuery.docs.map((doc) => Post.fromSnap(doc)).toList();

      var favLocationsQuery = await firestore
          .collection('favoriteLocations')
          .where('userId', isEqualTo: _uid.value)
          .get();

      _favoritedLocationsList.value = favLocationsQuery.docs
          .map((doc) {
        final data = doc.data();
        if (data == null || data is! Map) return null;
        return FavoriteLocation.fromJson(
            Map<String, dynamic>.from(data as Map<dynamic, dynamic>));
      })
          .whereType<FavoriteLocation>()
          .toList();
    } catch (e) {
      print('Lỗi fetchTabContent: $e');
      Get.snackbar('Lỗi tải Tab', e.toString());
    }
    _isFetchingTabs.value = false;
  }

  Future<void> followUser() async {
    if (_isLoading.value || _uid.value.isEmpty) return;

    try {
      _isLoading.value = true;

      final String currentUid = authController.userAccount.uid;
      final String targetUid = _uid.value;

      final userRef = firestore.collection('users').doc(targetUid);
      final currentUserRef = firestore.collection('users').doc(currentUid);

      final userSnap = await userRef.get();
      final currentSnap = await currentUserRef.get();

      final userData = userSnap.data() != null
          ? Map<String, dynamic>.from(userSnap.data() as Map)
          : {};
      final myData = currentSnap.data() != null
          ? Map<String, dynamic>.from(currentSnap.data() as Map)
          : {};

      List followers = List.from(userData['followers'] ?? []);
      List following = List.from(myData['following'] ?? []);

      if (followers.contains(currentUid)) {
        //Unfollow
        await userRef.update({
          'followers': FieldValue.arrayRemove([currentUid])
        });
        await currentUserRef.update({
          'following': FieldValue.arrayRemove([targetUid])
        });

        // xóa bạn bè
        await currentUserRef.update({'friends': FieldValue.arrayRemove([targetUid])});
        await userRef.update({'friends': FieldValue.arrayRemove([currentUid])});
      } else {
        //Follow
        await userRef.set({
          'followers': FieldValue.arrayUnion([currentUid])
        }, SetOptions(merge: true));

        await currentUserRef.set({
          'following': FieldValue.arrayUnion([targetUid])
        }, SetOptions(merge: true));

        bool isFollowedBy = false;
        if (userData['following'] != null &&
            (userData['following'] as List).contains(currentUid)) {
          isFollowedBy = true;
        }

        if (isFollowedBy) {
          await currentUserRef.set({
            'friends': FieldValue.arrayUnion([targetUid])
          }, SetOptions(merge: true));

          await userRef.set({
            'friends': FieldValue.arrayUnion([currentUid])
          }, SetOptions(merge: true));
        }

        await _createFollowNotification(targetUid);
      }

      await getUserData();
      _user.refresh();
    } catch (e, st) {
      print('❌ followUser error: $e');
      print(st);
      Get.snackbar('Lỗi', e.toString());
    } finally {
      _isLoading.value = false; // Luôn tắt loading
    }
  }

  //Xóa bài viết
  Future<void> deletePostAndRefresh(String postId) async {
    try {
      await firestore.collection('posts').doc(postId).delete();
      _postedList.value.removeWhere((p) => p.id == postId);
      _postedList.refresh(); // 🔹 Cập nhật UI
      Get.snackbar('Thành công', 'Bài viết đã bị xóa');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xóa bài viết: $e');
    }
  }


  Future<void> _createFollowNotification(String targetUid) async {
    try {
      final String myUid = authController.userAccount.uid;
      final userDoc = await firestore.collection('users').doc(myUid).get();

      final raw = userDoc.data();
      if (raw == null) return;

      final myData = Map<String, dynamic>.from(raw as Map<dynamic, dynamic>);

      final notif = {
        'id': 'follow_${myUid}_$targetUid',
        'receiverId': targetUid,
        'senderId': myUid,
        'senderName': myData['username'] ?? 'Một người',
        'senderAvatar': myData['avatarUrl'] ?? '',
        'type': 'follow',
        'message': 'đã bắt đầu theo dõi bạn',
        'createdAt': Timestamp.now(),
        'isRead': false,
      };

      await firestore
          .collection('notifications')
          .doc(targetUid)
          .collection('userNotifications')
          .doc(notif['id'])
          .set(notif);

      print('✅ Follow notification created for $targetUid');
    } catch (e, st) {
      print('❌ Lỗi tạo thông báo follow: $e');
      print(st);
    }
  }

  Future<void> updateUserName(String newName) async {
    if (newName.isEmpty) {
      Get.snackbar('Lỗi', 'Tên không thể để trống');
      return;
    }
    try {
      String newUsername = newName.toLowerCase().replaceAll(' ', '');
      List<String> nameParts = newName.toLowerCase().split(' ');
      List<String> keywords = [newUsername, ...nameParts];

      await firestore.collection('users').doc(_uid.value).update({
        'name': newName,
        'username': newUsername,
        'displayName': newName,
        'searchKeywords': keywords,
      });

      await getUserData();
      Get.back();
      Get.snackbar('Thành công', 'Đã cập nhật tên');
    } catch (e) {
      Get.snackbar('Lỗi', e.toString());
    }
  }

  Future<String> findOrCreateChatRoom(String otherUserId) async {
    String myUid = authController.userAccount.uid;
    String roomId = (myUid.hashCode <= otherUserId.hashCode)
        ? '${myUid}_${otherUserId}'
        : '${otherUserId}_${myUid}';

    DocumentReference roomRef = firestore.collection('chatRooms').doc(roomId);
    DocumentSnapshot roomSnap = await roomRef.get();

    if (roomSnap.exists) {
      return roomId;
    } else {
      Timestamp now = Timestamp.now();

      DocumentSnapshot myUserDoc =
      await firestore.collection('users').doc(myUid).get();
      DocumentSnapshot otherUserDoc =
      await firestore.collection('users').doc(otherUserId).get();

      final myDataRaw = myUserDoc.data();
      final otherDataRaw = otherUserDoc.data();

      if (myDataRaw == null || myDataRaw is! Map)
        throw Exception('Không tìm thấy dữ liệu user của tôi');
      if (otherDataRaw == null || otherDataRaw is! Map)
        throw Exception('Không tìm thấy dữ liệu user kia');

      var myData = Map<String, dynamic>.from(myDataRaw as Map);
      var otherData = Map<String, dynamic>.from(otherDataRaw as Map);

      Map<String, dynamic> participantInfo = {
        myUid: {
          'name': myData['username'] ?? '',
          'avatar': myData['avatarUrl'] ?? '',
        },
        otherUserId: {
          'name': otherData['username'] ?? '',
          'avatar': otherData['avatarUrl'] ?? '',
        }
      };

      await roomRef.set({
        'participants': [myUid, otherUserId],
        'participantInfo': participantInfo,
        'lastMessage': 'Đã bắt đầu cuộc trò chuyện',
        'lastMessageAt': now,
        'lastMessageSenderId': myUid,
      });
      return roomId;
    }
  }
}