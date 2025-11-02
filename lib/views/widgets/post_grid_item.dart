import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PostGridItem extends StatelessWidget {
  final String imageUrl;
  final int likeCount;

  const PostGridItem({
    Key? key,
    required this.imageUrl,
    required this.likeCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(color: Colors.grey[850]),
          errorWidget: (context, url, error) => Icon(Icons.error),
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
}