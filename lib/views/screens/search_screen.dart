import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/controllers/search_controller.dart';
import '/models/user.dart';
import '/views/screens/profile_screen.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({Key? key}) : super(key: key);

  final Search_Controller searchController = Get.put(Search_Controller());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.red,
            title: TextFormField(
              decoration: const InputDecoration(
                  filled: false,
                  hintText: 'Search',
                  hintStyle: TextStyle(fontSize: 18, color: Colors.white)),
              onFieldSubmitted: (value) => searchController.searchUser(value),
            ),
          ),
          body: searchController.searchedUsers.isEmpty
              ? const Center( // Xóa 'child: const' ở đây
              child: Text(
                'Search for users!',
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ))
              : ListView.builder(
              itemCount: searchController.searchedUsers.length,
              itemBuilder: (context, index) {
                User user = searchController.searchedUsers[index];
                return InkWell(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ProfileScreen(uid: user.uid))),
                  child: ListTile(
                    leading: CircleAvatar(
                      // Sửa lỗi Model: 'profilePhoto' -> 'avatarUrl'
                      // Thêm xử lý null cho avatarUrl
                      backgroundImage: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    title: Text(
                      // Sửa lỗi Model: 'name' -> 'username'
                      user.username,
                      style: const TextStyle(
                          fontSize: 18, color: Colors.white),
                    ),
                  ),
                );
              }));
    });
  }
}