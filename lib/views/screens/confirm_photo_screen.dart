import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/controllers/upload_image_controller.dart';
import '/constants.dart';

class ConfirmPhotoScreen extends StatefulWidget {
  final File imageFile;
  final String imagePath;

  const ConfirmPhotoScreen({
    Key? key,
    required this.imageFile,
    required this.imagePath,
  }) : super(key: key);

  @override
  State<ConfirmPhotoScreen> createState() => _ConfirmPhotoScreenState();
}

class _ConfirmPhotoScreenState extends State<ConfirmPhotoScreen> {
  final TextEditingController _captionController = TextEditingController();
  final UploadImageController uploadController = Get.put(UploadImageController());

  bool _isUploading = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  _uploadImage() async {
    if (_captionController.text.trim().isEmpty) {
      Get.snackbar("Thiếu thông tin", "Vui lòng nhập caption cho ảnh.");
      return;
    }

    setState(() => _isUploading = true);

    await uploadController.uploadImage(
      _captionController.text.trim(),
      widget.imageFile,
    );

    setState(() => _isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Xác nhận ảnh',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Ảnh preview
            Container(
              height: MediaQuery.of(context).size.height * 0.6,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: FileImage(widget.imageFile),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Caption input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _captionController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Viết caption cho ảnh...",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white12,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Nút đăng ảnh
            _isUploading
                ? const CircularProgressIndicator(color: Colors.white)
                : ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 15),
              ),
              onPressed: _uploadImage,
              icon: const Icon(Icons.cloud_upload, color: Colors.black),
              label: const Text(
                'Đăng ảnh',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
