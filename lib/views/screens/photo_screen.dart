import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/constants.dart';
import '/controllers/photo_controller.dart'; // Đổi sang PhotoController
import '/views/screens/comment_screen.dart';
import '/views/widgets/circle_animation.dart';
// Xóa import VideoPlayerItem vì không dùng nữa

// Đổi tên class từ VideoScreen thành PhotoScreen
class PhotoScreen extends StatelessWidget {
  PhotoScreen({Key? key}) : super(key: key);

  // Đổi VideoController thành PhotoController
  final PhotoController photoController = Get.put(PhotoController());

  buildProfile(String avatarUrl) { // Đổi tên tham số cho rõ nghĩa
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        children: [
          Positioned(
              left: 5,
              child: Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image(
                    image: NetworkImage(avatarUrl), // Sử dụng avatarUrl
                    fit: BoxFit.cover,
                  ),
                ),
              ))
        ],
      ),
    );
  }

  buildMusicAlbum(String avatarUrl) { // Đổi tên tham số
    return SizedBox(
      width: 60,
      height: 60,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              gradient:
              const LinearGradient(colors: [Colors.grey, Colors.white]),
              borderRadius: BorderRadius.circular(25),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image(
                image: NetworkImage(avatarUrl), // Sử dụng avatarUrl
                fit: BoxFit.cover,
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Obx(() {
        // Kiểm tra nếu photoList rỗng
        if (photoController.photoList.isEmpty) {
          return const Center(
            child: Text(
              'Chưa có ảnh nào',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          );
        }

        return PageView.builder(
          // Sử dụng photoController
            itemCount: photoController.photoList.length,
            controller: PageController(initialPage: 0, viewportFraction: 1),
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              // Lấy dữ liệu từ photoList
              final data = photoController.photoList[index];
              return Stack(
                children: [
                  // Thay thế VideoPlayerItem bằng Image.network
                  Container(
                    width: double.infinity,
                    height: size.height,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      image: DecorationImage(
                        image: NetworkImage(data.imageUrl), // Hiển thị ảnh
                        fit: BoxFit.contain, // Hiển thị toàn bộ ảnh
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      const SizedBox(
                        height: 100,
                      ),
                      Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(left: 20, bottom: 20), // Thêm padding bottom
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        data.username,
                                        style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        data.caption,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                      // Xóa phần hiển thị songname
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                width: 100,
                                margin: EdgeInsets.only(bottom: size.height / 10), // Điều chỉnh margin
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end, // Căn chỉnh xuống dưới
                                  children: [
                                    // Sử dụng data.avatarUrl
                                    buildProfile(data.avatarUrl),
                                    const SizedBox(height: 20),
                                    Column(
                                      children: [
                                        InkWell(
                                          // Sử dụng photoController.likePhoto
                                          onTap: () =>
                                              photoController.likePhoto(data.id),
                                          child: Icon(
                                            Icons.favorite,
                                            size: 40,
                                            color: data.likes.contains(
                                                authController.user.uid)
                                                ? Colors.red
                                                : Colors.white,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 7,
                                        ),
                                        Text(
                                          data.likes.length.toString(),
                                          style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Column(
                                      children: [
                                        InkWell(
                                          onTap: ()=>Navigator.of(context).push(
                                              MaterialPageRoute(builder: (context)=>CommentScreen(
                                                id: data.id,
                                              ))
                                          ),
                                          child: const Icon(
                                            Icons.comment,
                                            size: 40,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 7,
                                        ),
                                        Text(
                                          data.commentCount.toString(),
                                          style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    // Xóa phần Share
                                    // Thêm CircleAnimation nếu muốn
                                    CircleAnimation(
                                      child: buildMusicAlbum(data.avatarUrl),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ))
                    ],
                  ),
                ],
              );
            });
      }),
    );
  }
}