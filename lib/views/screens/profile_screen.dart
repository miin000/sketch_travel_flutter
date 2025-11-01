import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/constants.dart';
import '/controllers/profile_controller.dart';
import '/models/post.dart';
import '/views/screens/settings_screen.dart'; // Import màn hình Cài đặt
import '/views/screens/location_screen.dart'; // Import màn hình Location

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController profileController = Get.put(ProfileController());
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    profileController.updateUserId(widget.uid);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Hàm hiển thị Dialog Sửa tên
  _showEditNameDialog() {
    _nameController.text = profileController.user['name'] ?? '';
    Get.dialog(
      AlertDialog(
        title: Text('Chỉnh sửa tên'),
        content: TextField(
          controller: _nameController,
          decoration: InputDecoration(hintText: 'Nhập tên mới'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              profileController.updateUserName(_nameController.text.trim());
            },
            child: Text('Cập nhật'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dùng DefaultTabController để quản lý 3 tab
    return DefaultTabController(
      length: 3,
      child: GetBuilder<ProfileController>(
        init: ProfileController(),
        builder: (controller) {
          if (controller.user.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          bool isCurrentUser = widget.uid == authController.user.uid;

          return Scaffold(
            appBar: AppBar(
              // Lấy username (Biệt danh/id)
              title: Text(
                controller.user['username'] ?? 'Profile',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: [
                // Nút Cài đặt (thay cho nút logout)
                IconButton(
                  onPressed: () {
                    // Chỉ chủ sở hữu mới thấy Cài đặt
                    if (isCurrentUser) {
                      Get.to(() => const SettingsScreen());
                    } else {
                      // (Tùy chọn) Báo cáo người dùng khác
                      Get.snackbar('Thông báo', 'Báo cáo người dùng (sắp có)');
                    }
                  },
                  // Đổi icon tùy theo chủ sở hữu
                  icon: Icon(isCurrentUser ? Icons.menu : Icons.more_horiz),
                )
              ],
            ),
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  // Phần 1: Thông tin Header
                  SliverToBoxAdapter(
                    child: _buildHeaderInfo(controller, isCurrentUser),
                  ),
                  // Phần 2: Thanh Tab dính
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      // === SỬA LỖI TẠI ĐÂY ===
                      // Xóa 'const' vì buttonColor không phải là const
                      TabBar(
                        indicatorColor: buttonColor,
                        tabs: const [ // 'tabs' có thể là const
                          Tab(icon: Icon(Icons.grid_on)), // Bài đã đăng
                          Tab(icon: Icon(Icons.favorite)), // Bài đã thích
                          Tab(icon: Icon(Icons.bookmark)), // Địa điểm
                        ],
                      ),
                    ),
                    pinned: true,
                  ),
                ];
              },
              // Phần 3: Nội dung các Tab
              body: Obx(() {
                if (controller.isFetchingTabs) {
                  return const Center(child: CircularProgressIndicator());
                }
                return TabBarView(
                  children: [
                    // Tab 1: Bài đã đăng
                    _buildPostedGrid(controller),
                    // Tab 2: Bài đã thích
                    _buildLikedGrid(controller),
                    // Tab 3: Địa điểm đã yêu thích
                    _buildFavoritedList(controller),
                  ],
                );
              }),
            ),
          );
        },
      ),
    );
  }

  // --- CÁC WIDGET PHỤ ---

  // Header Info (Avatar, Tên, Stats)
  Widget _buildHeaderInfo(ProfileController controller, bool isCurrentUser) {
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
                backgroundImage: CachedNetworkImageProvider(
                  controller.user['profilePhoto'] ?? '',
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Đổi tên stats
                    _buildStatColumn('Bài đăng', controller.postedList.length.toString()),
                    _buildStatColumn('Followers', controller.user['followers'] ?? '0'),
                    _buildStatColumn('Following', controller.user['following'] ?? '0'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Tên và Nút Sửa
          Row(
            children: [
              Text(
                controller.user['name'] ?? '',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // Chỉ chủ sở hữu mới thấy nút Sửa
              if (isCurrentUser)
                IconButton(
                  icon: Icon(Icons.edit, size: 20),
                  onPressed: _showEditNameDialog,
                )
            ],
          ),
          const SizedBox(height: 10),
          // Nút Follow/Unfollow
          if (!isCurrentUser)
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (controller.isLoading) return;
                  controller.followUser();
                },
                child: controller.isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : Text(
                  controller.user['isFollowing'] ? 'Đang Follow' : 'Follow',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.user['isFollowing']
                      ? Colors.grey
                      : buttonColor,
                ),
              ),
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
        Post post = controller.postedList[index];
        return _buildGridPostItem(
          imageUrl: post.imageUrls.first, // Chỉ lấy ảnh đầu
          likeCount: post.likes.length,
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
        Post post = controller.likedList[index];
        return _buildGridPostItem(
          imageUrl: post.imageUrls.first,
          likeCount: post.likes.length,
        );
      },
    );
  }

  // Widget cho mỗi ô ảnh trong Grid (có số tim)
  Widget _buildGridPostItem({required String imageUrl, required int likeCount}) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
        ),
        // Hiển thị số lượng tim
        Positioned(
          bottom: 5,
          left: 5,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.favorite, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(
                  likeCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Tab 3: List các địa điểm đã yêu thích
  Widget _buildFavoritedList(ProfileController controller) {
    if (controller.favoritedLocationsList.isEmpty) {
      return const Center(child: Text('Chưa yêu thích địa điểm nào'));
    }
    return ListView.builder(
      itemCount: controller.favoritedLocationsList.length,
      itemBuilder: (context, index) {
        var favLocation = controller.favoritedLocationsList[index];
        return ListTile(
          leading: const Icon(Icons.location_on),
          title: Text(favLocation.locationId), // locationId chính là Tên
          onTap: () {
            // Điều hướng đến trang LocationScreen
            Get.to(() => LocationScreen(locationName: favLocation.locationId));
          },
        );
      },
    );
  }
}

// Class hỗ trợ cho TabBar dính (pinned)
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Dùng Theme.of(context).scaffoldBackgroundColor để tự động đổi màu Sáng/Tối
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}