import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/constants.dart';
import '/views/screens/confirm_photo_screen.dart';

class AddPhotoScreen extends StatelessWidget {
  const AddPhotoScreen({Key? key}) : super(key: key);

  // Chọn ảnh từ camera hoặc gallery
  pickImage(ImageSource src, BuildContext context) async {
    final image = await ImagePicker().pickImage(source: src);
    if (image != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ConfirmPhotoScreen(
            imageFile: File(image.path),
            imagePath: image.path,
          ),
        ),
      );
    }
  }

  // Hiển thị hộp thoại chọn nguồn ảnh
  showOptionDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text(
          'Chọn ảnh từ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              pickImage(ImageSource.gallery, context);
            },
            child: Row(
              children: const [
                Icon(Icons.image),
                Padding(
                  padding: EdgeInsets.all(7.0),
                  child: Text(
                    'Thư viện',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              pickImage(ImageSource.camera, context);
            },
            child: Row(
              children: const [
                Icon(Icons.camera_alt),
                Padding(
                  padding: EdgeInsets.all(7.0),
                  child: Text(
                    'Máy ảnh',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context),
            child: Row(
              children: const [
                Icon(Icons.cancel),
                Padding(
                  padding: EdgeInsets.all(7.0),
                  child: Text(
                    'Hủy',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: InkWell(
          onTap: () => showOptionDialog(context),
          child: Container(
            width: 190,
            height: 50,
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Thêm ảnh',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
