import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '/constants.dart';
import '/controllers/post_controller.dart';
import '/models/post.dart';
import '/views/screens/comment_screen.dart';
import '/views/screens/profile_screen.dart';
import '/views/screens/location_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PostFeedScreen extends StatelessWidget {
  PostFeedScreen({Key? key}) : super(key: key);

  final PostController postController = Get.put(PostController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
            () {
          if (postController.postList.isEmpty) {
            return Center(
              child: Text('Chưa có bài viết nào. Hãy đăng bài!'),
            );
          }
          // 1. CUỘN DỌC (Giống TikTok)
          return PageView.builder(
            itemCount: postController.postList.length,
            controller: PageController(initialPage: 0, viewportFraction: 1),
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              final post = postController.postList[index];
              return _buildPostPage(context, post);
            },
          );
        },
      ),
    );
  }

  // Widget build mỗi trang (mỗi bài post)
  Widget _buildPostPage(BuildContext context, Post post) {
    final size = MediaQuery.of(context).size;
    final currentUid = authController.userAccount.uid;
    // Controller cho carousel ảnh
    final PageController _imageCarouselController = PageController();

    return Stack(
      children: [
        PageView.builder(
          controller: _imageCarouselController,

          physics: const ClampingScrollPhysics(),

          itemCount: post.imageUrls.length,
          itemBuilder: (context, imageIndex) {
            return Container(
              width: size.width,
              height: size.height,
              decoration: BoxDecoration(color: Colors.black),
              child: CachedNetworkImage(
                imageUrl: post.imageUrls[imageIndex],
                fit: BoxFit.cover, // Dùng cover để ảnh lấp đầy
                placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Center(child: Icon(Icons.error, color: Colors.red)),
              ),
            );
          },
        ),

        // 3. Giao diện (Buttons, Text) đè lên
        // Container chứa các nút và text
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Hàng dưới cùng (Username, Location, ...)
              _buildBottomInfo(context, post),
            ],
          ),
        ),

        // 4. Thanh Buttons bên phải (Like, Comment)
        Positioned(
          right: 10,
          bottom: size.height * 0.15, // Đẩy lên trên thanh info
          child: _buildSideButtons(context, post, currentUid),
        ),

        // 5. Dấu chấm tròn (Page Indicator)
        // Chỉ hiển thị nếu có nhiều hơn 1 ảnh
        if (post.imageUrls.length > 1)
          Positioned(
            bottom: size.height * 0.12, // Vị trí ngay trên thanh info
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _imageCarouselController,
                count: post.imageUrls.length,
                effect: ScrollingDotsEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  activeDotColor: Colors.white,
                  dotColor: Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Widget cho các nút bên phải
  Widget _buildSideButtons(BuildContext context, Post post, String currentUid) {
    return Column(
      children: [
        // Nút Like
        Column(
          children: [
            IconButton(
              onPressed: () => postController.likePost(post.id),
              icon: Icon(
                Icons.favorite,
                size: 35,
                color: post.likes.contains(currentUid) ? buttonColor : Colors.white,
                shadows: [Shadow(blurRadius: 4, color: Colors.black.withOpacity(0.5))],
              ),
            ),
            Text(
              post.likes.length.toString(),
              style: TextStyle(fontSize: 16, color: Colors.white, shadows: [Shadow(blurRadius: 4, color: Colors.black.withOpacity(0.5))]),
            ),
          ],
        ),
        SizedBox(height: 15),

        // Nút Comment
        Column(
          children: [
            IconButton(
              onPressed: () {
                Get.to(() => CommentScreen(postId: post.id));
              },
              icon: Icon(Icons.comment, size: 35, color: Colors.white, shadows: [Shadow(blurRadius: 4, color: Colors.black.withOpacity(0.5))]),
            ),
            Text(
              post.commentCount.toString(),
              style: TextStyle(fontSize: 16, color: Colors.white, shadows: [Shadow(blurRadius: 4, color: Colors.black.withOpacity(0.5))]),
            ),
          ],
        ),
        // Có thể thêm nút Share ở đây nếu muốn
      ],
    );
  }

  // Widget cho thông tin dưới cùng
  Widget _buildBottomInfo(BuildContext context, Post post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nút Location (Theo thiết kế của bạn)
        GestureDetector(
          onTap: () {
            Get.to(() => LocationScreen(locationName: post.locationName));
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  post.locationName,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 8),

        // Tên người dùng và Mô tả
        Row(
          children: [
            GestureDetector(
              onTap: () => Get.to(() => ProfileScreen(uid: post.uid)),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: CachedNetworkImageProvider(post.avatarUrl),
                    backgroundColor: Colors.grey[800],
                  ),
                  SizedBox(width: 8),
                  Text(
                    '@${post.username}', // Figma của bạn ghi "Name"
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black.withOpacity(0.5))],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 5),
        Text(
          post.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
            shadows: [Shadow(blurRadius: 4, color: Colors.black.withOpacity(0.5))],
          ),
        ),
      ],
    );
  }
}