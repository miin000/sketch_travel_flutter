import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/controllers/auth_controller.dart';
import '/controllers/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: ListView(
        children: [
          // Chuyển đổi Theme Sáng/Tối
          Obx(() => ListTile(
            title: const Text('Chế độ tối'),
            trailing: Switch(
              // === SỬA LỖI TẠI ĐÂY ===
              value: themeController.isDarkMode.value, // Thêm .value
              // ========================
              onChanged: (value) {
                themeController.toggleTheme();
              },
            ),
          )),

          Divider(),

          // Nút Đăng xuất
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              // Hiển thị dialog xác nhận trước khi đăng xuất
              Get.dialog(
                AlertDialog(
                  title: Text('Đăng xuất'),
                  content: Text('Bạn có chắc chắn muốn đăng xuất?'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () {
                        AuthController.instance.signOut();
                      },
                      child: Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}