import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/constants.dart';
import '/controllers/location_controller.dart';
import '/controllers/location_favorite_controller.dart';
import '/models/review.dart';
import '/models/post.dart';
import '/views/widgets/post_grid_item.dart';

class LocationScreen extends StatefulWidget {
  final String locationName; // Nhận tên địa điểm từ PostFeedScreen
  const LocationScreen({Key? key, required this.locationName}) : super(key: key);

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LocationController _locationController = Get.put(LocationController());
  final LocationFavoriteController _favController =
  Get.put(LocationFavoriteController());
  final TextEditingController _reviewContentController = TextEditingController();
  double _userRating = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Khởi động các controller với tên địa điểm
    _locationController.updateLocationId(widget.locationName);
    _favController.updateLocationId(widget.locationName);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reviewContentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.locationName),
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: Obx(() {
        if (_locationController.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        final location = _locationController.location;
        if (location == null) {
          return Center(child: Text('Không thể tải địa điểm'));
        }

        return NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            location.rating.toString(),
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.star, color: Colors.yellow[700], size: 20),
                          SizedBox(width: 8),
                          Text(
                            '(${location.reviewCount} người đánh giá)',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      _infoRow(Icons.location_on_outlined,
                          '${location.province}, Việt Nam'),
                      // TODO: Thêm thông tin khoảng cách (cần tính toán)
                      // _infoRow(Icons.map_outlined, '97.7 km'),
                      SizedBox(height: 16),
                      // Các nút Chia sẻ và Yêu thích
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelStyle:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: buttonColor,
                    tabs: [
                      Tab(text: 'Đánh giá'),
                      Tab(text: 'Bài đăng'),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Đánh giá
              _buildReviewsTab(),
              // Tab 2: Bài đăng
              _buildPostsTab(),
              Center(
                  child: Text(
                      'Danh sách bài đăng về ${widget.locationName} (Sắp có)')),
            ],
          ),
        );
      }),
    );
  }

  // Widget cho các nút "Chia sẻ" và "Yêu thích"
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: Logic chia sẻ
              Get.snackbar('Chia sẻ', 'Đã sao chép liên kết (chưa có)');
            },
            icon: Icon(Icons.ios_share, color: Colors.white),
            label: Text('Chia sẻ'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Obx(
                () => ElevatedButton.icon(
              onPressed: () {
                _favController.toggleFavorite();
              },
              icon: Icon(
                _favController.isFavorite ? Icons.bookmark : Icons.bookmark_border,
                color: _favController.isFavorite ? Colors.white : Colors.white,
              ),
              label: Text(_favController.isFavorite ? 'Đã thích' : 'Yêu thích'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _favController.isFavorite
                    ? buttonColor?.withOpacity(0.8)
                    : buttonColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget cho nội dung tab "Đánh giá"
  Widget _buildReviewsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Viết đánh giá
          Text(
            'Viết đánh giá',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          RatingBar.builder(
            initialRating: 0,
            minRating: 1,
            direction: Axis.horizontal,

            // === SỬA LỖI TẠI ĐÂY (Dòng 206) ===
            allowHalfRating: false, // Sửa từ 'allowHalfLogging'
            // ==================================

            itemCount: 5,
            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              _userRating = rating;
            },
          ),
          SizedBox(height: 16),
          TextField(
            controller: _reviewContentController,
            decoration: InputDecoration(
              hintText: 'Chia sẻ trải nghiệm của bạn...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 3,
          ),
          SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                _locationController.postReview(
                  _userRating,
                  _reviewContentController.text.trim(),
                );
                // Xóa nội dung sau khi gửi
                _reviewContentController.clear();
                setState(() {
                  _userRating = 0; // Reset sao
                });
              },
              child: Text('Gửi đánh giá'),
              style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
            ),
          ),
          Divider(height: 40),

          // 2. Danh sách đánh giá
          Text(
            'Đánh giá (${_locationController.reviews.length})',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Obx(() {
            if (_locationController.reviews.isEmpty) {
              return Center(child: Text('Chưa có đánh giá nào.'));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _locationController.reviews.length,
              itemBuilder: (context, index) {
                return _buildReviewItem(_locationController.reviews[index]);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPostsTab() {
    return Obx(() {
      if (_locationController.posts.isEmpty) {
        return Center(child: Text('Chưa có bài đăng nào về địa điểm này.'));
      }
      // Dùng GridView giống hệt ProfileScreen
      return GridView.builder(
        padding: const EdgeInsets.all(2),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          childAspectRatio: 1,
        ),
        itemCount: _locationController.posts.length,
        itemBuilder: (context, index) {
          Post post = _locationController.posts[index];
          return PostGridItem(
            imageUrl: post.imageUrls.first, // Chỉ lấy ảnh đầu
            likeCount: post.likes.length,
          );
        },
      );
    });
  }

  // Widget cho một item review
  Widget _buildReviewItem(Review review) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sửa Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[800],
            backgroundImage: review.avatarUrl.isNotEmpty
                ? CachedNetworkImageProvider(review.avatarUrl)
                : null,
            child: review.avatarUrl.isEmpty
                ? Icon(Icons.person, color: Colors.white)
                : null,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.username, // Lấy username thật
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                // ========================
                SizedBox(height: 4),
                RatingBar.builder(
                  initialRating: review.rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  ignoreGestures: true, // Chỉ hiển thị
                  itemCount: 5,
                  itemSize: 16,
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {},
                ),
                SizedBox(height: 8),
                Text(
                  review.content ?? 'Nice', // Mặc định nếu content null
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget cho hàng thông tin (Địa chỉ, Khoảng cách)
  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[400], size: 20),
        SizedBox(width: 12),
        Text(text, style: TextStyle(fontSize: 16)),
      ],
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
    return Container(
      color: backgroundColor, // Màu nền của tab bar
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}