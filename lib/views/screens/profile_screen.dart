import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/constants.dart';
import '/controllers/profile_controller.dart';
import '/models/post.dart';
import '/views/screens/settings_screen.dart';
import '/views/screens/location_screen.dart';
import '/views/widgets/post_grid_item.dart';
import '/views/screens/chat_detail_screen.dart';
import 'add_post_screen.dart';
// import '/views/widgets/post_grid_item.dart'; // Import bị lặp, xóa 1 dòng
// import '/views/screens/chat_detail_screen.dart'; // Import bị lặp, xóa 1 dòng

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // === SỬA LỖI 3 (Logic) ===
  // Khởi tạo ProfileController với tag duy nhất là uid
  // để tránh xung đột khi mở nhiều profile
  late final ProfileController profileController;

  @override
  void initState() {
    super.initState();
    // Gán controller với tag
    profileController = Get.put(ProfileController(), tag: widget.uid);
    profileController.updateUserId(widget.uid);
  }
  // ========================

  @override
  void dispose() {
    _nameController.dispose();
    // Xóa controller bằng tag
    if (Get.isRegistered<ProfileController>(tag: widget.uid)) {
      Get.delete<ProfileController>(tag: widget.uid);
    }
    super.dispose();
  }

  final TextEditingController _nameController = TextEditingController();

  bool get isCurrentUser =>
      widget.uid == authController.userAccount.uid;

  void _showEditNameDialog() {
    _nameController.text = profileController.user['name'] ?? ''; // Bỏ '!'
    Get.dialog(
      AlertDialog(
        title: const Text('Chỉnh sửa tên'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(hintText: 'Nhập tên mới'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              profileController.updateUserName(_nameController.text.trim());
            },
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );
  }

  // 🔹 Helper an toàn (giữ nguyên)
  String _getFirstUrl(dynamic value) {
    if (value == null) return '';
    if (value is String && value.isNotEmpty) return value;
    if (value is List && value.isNotEmpty && value.first is String) {
      return value.first;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Obx(() {
        // 'user' bây giờ là RxMap, nó không bao giờ 'null'
        final user = profileController.user;

        // === SỬA LỖI UI KHÔNG UPDATE ===
        // Vì 'user' là RxMap, nó sẽ không 'null'.
        // Chúng ta kiểm tra 'isEmpty' để biết đã có dữ liệu hay chưa.
        if (user.isEmpty) {
          // ===============================
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        bool isCurrentUser = widget.uid == authController.userAccount.uid;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              user['username'] ?? 'Profile',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  if (isCurrentUser) {
                    Get.to(() => const SettingsScreen());
                  } else {
                    Get.snackbar('Thông báo', 'Báo cáo người dùng (sắp có)');
                  }
                },
                icon: Icon(isCurrentUser ? Icons.menu : Icons.more_horiz),
              ),
            ],
          ),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: _buildHeaderInfo(profileController, isCurrentUser),
                ),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      indicatorColor: buttonColor,
                      tabs: const [
                        Tab(icon: Icon(Icons.grid_on)),
                        Tab(icon: Icon(Icons.favorite)),
                        Tab(icon: Icon(Icons.bookmark)),
                      ],
                    ),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: Obx(() {
              if (profileController.isFetchingTabs) {
                return const Center(child: CircularProgressIndicator());
              }
              return TabBarView(
                children: [
                  _buildPostedGrid(profileController),
                  _buildLikedGrid(profileController),
                  _buildFavoritedList(profileController),
                ],
              );
            }),
          ),
        );
      }),
    );
  }

  // --- Header info ---
  Widget _buildHeaderInfo(ProfileController controller, bool isCurrentUser) {
    // 'controller.user' là RxMap, không cần '!'
    final profileUrl = _getFirstUrl(controller.user['profilePhoto']);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[300],
                backgroundImage: profileUrl.isNotEmpty
                    ? CachedNetworkImageProvider(profileUrl)
                    : null,
                child: profileUrl.isEmpty
                    ? const Icon(Icons.person, size: 40, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Đọc dữ liệu từ Map (bỏ '!')
                      _buildStatColumn(
                          'Bài đăng', controller.postedList.length.toString()),
                      const SizedBox(width: 20),
                      _buildStatColumn('Bạn bè', controller.user['friends'] ?? '0'),
                      const SizedBox(width: 20),
                      _buildStatColumn('Followers', controller.user['followers'] ?? '0'),
                      const SizedBox(width: 20),
                      _buildStatColumn('Following', controller.user['following'] ?? '0'),
                      const SizedBox(width: 20),
                      _buildStatColumn('Likes', controller.user['likes'] ?? '0'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                controller.user['name'] ?? '', // Bỏ '!'
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (isCurrentUser)
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: _showEditNameDialog,
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (!isCurrentUser)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (controller.isLoading) return;
                      controller.followUser();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.user['isFollowing'] == true
                          ? Colors.grey
                          : buttonColor,
                    ),
                    child: controller.isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      controller.user['isFollowing'] == true
                          ? 'Đang Follow'
                          : 'Follow',
                    ),
                  ),
                ),
                if (controller.user['isFollowing'] == true &&
                    controller.user['isFollowedBy'] == true) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        String roomId = await controller.findOrCreateChatRoom(widget.uid);
                        DocumentSnapshot myUserDoc = await firestore
                            .collection('users')
                            .doc(authController.userAccount.uid)
                            .get();

                        final myDataRaw = myUserDoc.data();
                        if (myDataRaw == null || myDataRaw is! Map) return;
                        var myData = Map<String, dynamic>.from(myDataRaw as Map);

                        Get.to(() => ChatDetailScreen(
                          roomId: roomId,
                          receiverId: widget.uid,
                          receiverName: controller.user['username'],
                          receiverAvatar: controller.user['profilePhoto'],
                          myInfo: {
                            'name': myData['username'] ?? '',
                            'avatar': myData['avatarUrl'] ?? '',
                          },
                          receiverInfo: {
                            'name': controller.user['username'] ?? '',
                            'avatar': controller.user['profilePhoto'] ?? '',
                          },
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                      ),
                      child: const Text('Nhắn tin'),
                    ),
                  ),
                ]
              ],
            ),
        ],
      ),
    );
  }

  // Cột thống kê
  Widget _buildStatColumn(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  // Tab 1: Grid các bài đã đăng
  Widget _buildPostedGrid(ProfileController controller) {
    if (controller.postedList.isEmpty) {
      return const Center(child: Text('Chưa đăng bài nào'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 1,
      ),
      itemCount: controller.postedList.length,
      itemBuilder: (context, index) {
        final Post post = controller.postedList[index];
        final imageUrl = _getFirstUrl(post.imageUrls);
        return PostGridItem(
          imageUrl: imageUrl,
          likeCount: post.likes.length,
          showDelete: isCurrentUser,
          onDelete: () => controller.deletePostAndRefresh(post.id),
          onEdit: () {
            Get.to(() => AddPostScreen(existingPost: post));
          },
        );
      },
    );
  }

  // Tab 2: Grid các bài đã thích
  Widget _buildLikedGrid(ProfileController controller) {
    if (controller.likedList.isEmpty) {
      return const Center(child: Text('Chưa thích bài viết nào'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 1,
      ),
      itemCount: controller.likedList.length,
      itemBuilder: (context, index) {
        final Post post = controller.likedList[index];
        final imageUrl = _getFirstUrl(post.imageUrls);
        return PostGridItem(
          imageUrl: imageUrl,
          likeCount: post.likes.length,
        );
      },
    );
  }

  // Tab 3: List các địa điểm yêu thích
  Widget _buildFavoritedList(ProfileController controller) {
    if (controller.favoritedLocationsList.isEmpty) {
      return const Center(child: Text('Chưa yêu thích địa điểm nào'));
    }
    return ListView.builder(
      itemCount: controller.favoritedLocationsList.length,
      itemBuilder: (context, index) {
        final favLocation = controller.favoritedLocationsList[index];
        return ListTile(
          leading: const Icon(Icons.location_on),
          title: Text(favLocation.locationId),
          onTap: () {
            Get.to(() => LocationScreen(locationName: favLocation.locationId));
          },
        );
      },
    );
  }
}

// Class hỗ trợ cho TabBar dính (pinned)
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}