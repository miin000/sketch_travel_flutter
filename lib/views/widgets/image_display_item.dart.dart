import 'package:flutter/material.dart';

// Đổi tên class (tùy chọn) và chuyển thành StatelessWidget
class ImageDisplayItem extends StatelessWidget {
  final String imageUrl; // Đổi tên biến từ videoUrl

  const ImageDisplayItem({
    Key? key,
    required this.imageUrl, // Đổi tham số
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height,
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      // Thay thế VideoPlayer bằng Image.network
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain, // Hiển thị toàn bộ ảnh

        // (Tùy chọn) Thêm chỉ báo đang tải:
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        },

        // (Tùy chọn) Hiển thị lỗi nếu không tải được ảnh:
        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
          return const Center(
            child: Icon(
              Icons.error,
              color: Colors.red,
              size: 50,
            ),
          );
        },
      ),
    );
  }
}