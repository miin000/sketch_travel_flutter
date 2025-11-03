import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '/constants.dart';
import '/controllers/upload_post_controller.dart';
import '/models/osm_location.dart';
import '/views/screens/search_screen.dart';
import '/models/post.dart';

class AddPostScreen extends StatefulWidget {
  final Post? existingPost;

  const AddPostScreen({Key? key, this.existingPost}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final UploadPostController _uploadPostController = Get.put(UploadPostController(), tag: UniqueKey().toString());

  final TextEditingController _descriptionController = TextEditingController();
  final PageController _pageController = PageController();

  List<String> existingImages = [];
  bool isEditing = false;

  @override
  void initState() {
    super.initState();

    // Nếu có bài viết cũ → chuyển sang chế độ chỉnh sửa
    if (widget.existingPost != null) {
      final post = widget.existingPost!;
      isEditing = true;

      _descriptionController.text = post.description;
      existingImages = List<String>.from(post.imageUrls);

      // Nạp lại địa điểm cũ
      if (post.locationName.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _uploadPostController.selectedLocation.value = OsmLocation(
            displayName: post.locationName,
            city: '',
            country: '',
            lat: 0,
            lon: 0,
          );
        });
      }

      // Nếu chưa có ảnh mới, hiển thị ảnh cũ
      if (_uploadPostController.pickedImageBytesList.isEmpty) {
        _uploadPostController.loadExistingImages(existingImages);
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _pageController.dispose();

    //Dọn sạch controller mỗi khi rời màn hình
    _uploadPostController.clearImages();
    _uploadPostController.clearSelectedLocation();

    super.dispose();
  }

  void _openLocationPicker() async {
    final result = await Get.to(() => SearchScreen(isPickerMode: true));
    if (result != null && result is OsmLocation) {
      _uploadPostController.selectLocation(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Chỉnh sửa bài viết' : 'Đăng bài viết mới',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: backgroundColor,
        actions: [
          Obx(() {
            if (_uploadPostController.isLoading.value) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                ),
              );
            }

            return IconButton(
              icon: const Icon(Icons.check),
              onPressed: () async {
                final desc = _descriptionController.text.trim();
                final images = _uploadPostController.getCurrentImageUrls();
                final locationName =
                    _uploadPostController.selectedLocation.value?.displayName ?? '';

                if (isEditing && widget.existingPost != null) {
                  await _uploadPostController.updatePost(
                    widget.existingPost!.id,
                    desc,
                    images,
                    locationName,
                  );
                } else {
                  await _uploadPostController.uploadPost(
                    desc,
                    images,
                    locationName,
                  );
                }
              },
            );
          }),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // === Khu vực ảnh ===
              Obx(() {
                final hasNewImages = _uploadPostController.pickedImageBytesList.isNotEmpty;
                final hasOldImages = _uploadPostController.existingImageUrls.isNotEmpty;

                if (!hasNewImages && !hasOldImages) {
                  return GestureDetector(
                    onTap: () => _uploadPostController.pickImages(),
                    child: Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.add_a_photo_outlined,
                          size: 60,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  );
                }

                // Combine hai danh sách ảnh
                final allImages = [
                  ..._uploadPostController.existingImageUrls,
                  ..._uploadPostController.pickedImageBytesList,
                ];

                return Column(
                  children: [
                    SizedBox(
                      height: 300,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: allImages.length,
                        itemBuilder: (context, index) {
                          final image = allImages[index];
                          final isOldImage = index < _uploadPostController.existingImageUrls.length;

                          return Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: isOldImage
                                      ? Image.network(image as String, fit: BoxFit.cover)
                                      : Image.memory(image as Uint8List, fit: BoxFit.cover),
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: GestureDetector(
                                  onTap: () {
                                    if (isOldImage) {
                                      _uploadPostController.removeExistingImageAt(index);
                                    } else {
                                      final newIndex =
                                          index - _uploadPostController.existingImageUrls.length;
                                      _uploadPostController.removePickedImageAt(newIndex);
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(6),
                                    child: const Icon(Icons.close, color: Colors.white, size: 18),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: allImages.length,
                      effect: WormEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        activeDotColor: buttonColor!,
                        dotColor: Colors.grey,
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 20),

              // === Mô tả ===
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Viết mô tả...',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: buttonColor!),
                  ),
                ),
                maxLines: 4,
              ),

              const SizedBox(height: 20),

              // === Địa điểm ===
              Obx(() {
                final selectedLocation =
                    _uploadPostController.selectedLocation.value;
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: BorderSide(
                      color: selectedLocation != null
                          ? buttonColor!
                          : borderColor,
                      width: selectedLocation != null ? 2 : 1,
                    ),
                  ),
                  leading: Icon(
                    Icons.location_on,
                    color:
                    selectedLocation != null ? buttonColor : Colors.grey,
                  ),
                  title: Text(
                    selectedLocation?.displayName ??
                        'Thêm địa điểm (ví dụ: Vịnh Hạ Long)',
                    style: TextStyle(
                      color: selectedLocation != null
                          ? (context.theme.brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black)
                          : Colors.grey,
                      fontWeight: selectedLocation != null
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: selectedLocation != null
                      ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => _uploadPostController
                        .clearSelectedLocation(),
                  )
                      : null,
                  onTap: _openLocationPicker,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
