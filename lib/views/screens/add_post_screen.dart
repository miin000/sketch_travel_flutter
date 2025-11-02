import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '/constants.dart';
import '/controllers/upload_post_controller.dart';
import '/models/osm_location.dart';
import '/views/screens/search_screen.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final UploadPostController _uploadPostController = Get.put(UploadPostController());
  final TextEditingController _descriptionController = TextEditingController();
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _descriptionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _openLocationPicker() async {
    // Đẩy SearchScreen ở chế độ picker
    final result = await Get.to(() => SearchScreen(isPickerMode: true));

    // Nhận kết quả trả về
    if (result != null && result is OsmLocation) {
      _uploadPostController.selectLocation(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đăng bài viết mới'),
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
                    // Dùng màu của theme (Trắng ở Dark mode, Đen ở Light mode)
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                ),
              );
            }

            return IconButton(
              onPressed: () {
                if (_descriptionController.text.isEmpty) {
                  Get.snackbar('Lỗi', 'Vui lòng nhập mô tả');
                  return;
                }
                // Controller sẽ tự kiểm tra location
                _uploadPostController.uploadPost(
                  _descriptionController.text.trim(),
                );
              },
              icon: Icon(Icons.check),
            );
          }),
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
              Obx(() {
                final selectedLocation = _uploadPostController.selectedLocation;
                return ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: BorderSide(
                        color: selectedLocation != null
                            ? (buttonColor ?? Colors.red)
                            : borderColor,
                        width: selectedLocation != null ? 2 : 1,
                      )
                  ),
                  leading: Icon(
                      Icons.location_on,
                      color: selectedLocation != null
                          ? buttonColor
                          : Colors.grey
                  ),
                  title: Text(
                    selectedLocation?.name ?? 'Thêm địa điểm (ví dụ: Vịnh Hạ Long)',
                    style: TextStyle(
                      color: selectedLocation != null
                          ? (context.theme.brightness == Brightness.dark ? Colors.white : Colors.black)
                          : Colors.grey,
                      fontWeight: selectedLocation != null
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: (selectedLocation != null)
                      ? IconButton( // Nút "X" để xóa địa điểm
                    icon: Icon(Icons.close),
                    onPressed: () => _uploadPostController.clearSelectedLocation(),
                  )
                      : null,
                  onTap: _openLocationPicker, // <-- Gọi hàm mở search
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}