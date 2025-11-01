import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '/constants.dart';
import '/controllers/upload_post_controller.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final UploadPostController _uploadPostController = Get.put(UploadPostController());
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đăng bài viết mới'),
        backgroundColor: backgroundColor,
        actions: [
          IconButton(
            onPressed: () {
              if (_descriptionController.text.isNotEmpty &&
                  _locationController.text.isNotEmpty) {
                _uploadPostController.uploadPost(
                  _descriptionController.text.trim(),
                  _locationController.text.trim(),
                );
              } else {
                Get.snackbar(
                    'Lỗi', 'Vui lòng nhập đủ Mô tả và Địa điểm');
              }
            },
            icon: Icon(Icons.check),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Vùng chọn ảnh và preview
              Obx(() {
                if (_uploadPostController.pickedImageBytesList.isEmpty) {
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
                } else {
                  // Hiển thị carousel preview ảnh
                  return Column(
                    children: [
                      Container(
                        height: 300,
                        child: PageView.builder(
                          controller: _pageController,

                          physics: const ClampingScrollPhysics(),

                          itemCount: _uploadPostController.pickedImageBytesList.length,
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                _uploadPostController.pickedImageBytesList[index],
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      // Dấu chấm tròn
                      SmoothPageIndicator(
                        controller: _pageController,
                        count: _uploadPostController.pickedImageBytesList.length,
                        effect: WormEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          activeDotColor: buttonColor ?? Colors.red,
                          dotColor: Colors.grey,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _uploadPostController.clearImages(),
                        icon: Icon(Icons.delete_outline, color: Colors.grey),
                        label: Text('Xóa ảnh', style: TextStyle(color: Colors.grey)),
                      )
                    ],
                  );
                }
              }),
              SizedBox(height: 20),
              // TextField cho Mô tả
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
              SizedBox(height: 20),
              // TextField cho Địa điểm
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'Thêm địa điểm (ví dụ: Vịnh Hạ Long)',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: buttonColor!),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}