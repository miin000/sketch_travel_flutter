import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _box = GetStorage();
  final _key = 'isDarkMode';

  // === SỬA LỖI TẠI ĐÂY ===
  // 1. Tạo một biến .obs thực sự
  final Rx<bool> isDarkMode = true.obs; // Mặc định là Tối

  // 2. Hàm này chỉ dùng khi khởi động app
  ThemeMode get theme => _loadTheme() ? ThemeMode.dark : ThemeMode.light;
  bool _loadTheme() => _box.read(_key) ?? true; // Mặc định là Tối (true)

  // 3. Tải trạng thái đã lưu khi controller khởi động
  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _loadTheme();
  }

  // 4. Hàm toggleTheme giờ sẽ cập nhật biến .obs
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value; // Cập nhật biến reactive
    _box.write(_key, isDarkMode.value); // Lưu trạng thái mới
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

// (Chúng ta không cần getter `bool get isDarkMode` nữa, vì đã có biến .obs)
}