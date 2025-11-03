import 'package:flutter/material.dart';

class PostGridItem extends StatelessWidget {
  final String imageUrl;
  final int likeCount;
  final bool showDelete;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const PostGridItem({
    Key? key,
    required this.imageUrl,
    required this.likeCount,
    this.showDelete = false,
    this.onDelete,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.network(imageUrl, fit: BoxFit.cover),
        ),
        Positioned(
          bottom: 5,
          left: 5,
          child: Row(
            children: [
              const Icon(Icons.favorite, color: Colors.white, size: 16),
              Text('$likeCount', style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
        if (showDelete) ...[
          Positioned(
            top: 5,
            right: 5,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: onDelete,
            ),
          ),
          Positioned(
            top: 5,
            right: 45, // đặt lệch qua trái chút để không đè lên nút delete
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: onEdit,
            ),
          ),
        ],
      ],
    );
  }
}
