import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/constants.dart';
import '/views/screens/post_feed_screen.dart';
import '/views/screens/profile_screen.dart';
import '/views/screens/search_screen.dart';
import '/views/widgets/custom_icon.dart';
import 'add_post_screen.dart';
import '/views/screens/mailbox_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int pageIdx = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: (idx) {
          setState(() {
            pageIdx = idx;
          });
        },
        backgroundColor: backgroundColor,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: buttonColor,
        unselectedItemColor: Colors.white,
        currentIndex: pageIdx,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              pageIdx == 0 ? Icons.home : Icons.home_outlined,
              size: 30,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              pageIdx == 1 ? Icons.search : Icons.search_outlined,
              size: 30,
            ),
            label: 'Search',
          ),
          const BottomNavigationBarItem(
            icon: CustomIcon(),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              pageIdx == 3 ? Icons.mail : Icons.mail_outline,
              size: 30,
            ),
            label: 'Mailbox',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              pageIdx == 4 ? Icons.person : Icons.person_2_outlined,
              size: 30,
            ),
            label: 'Profile',
          ),
        ],
      ),
      body: IndexedStack(
        index: pageIdx,
        children: [
          PostFeedScreen(),
          SearchScreen(),
          const AddPostScreen(),
          const MailboxScreen(),
          // Bọc bằng Obx để lắng nghe authController.user
          Obx(() {
            // Lắng nghe biến 'user' (reactive) từ AuthController
            final user = authController.user.value;

            // Chỉ build ProfileScreen khi đã có user (không còn là null)
            if (user == null) {
              // Hiển thị loading trong khi chờ Auth
              return const Center(child: CircularProgressIndicator());
            }
            // Khi đã có user, truyền uid thật
            return ProfileScreen(uid: user.uid);
          }),
        ],
      ),
    );
  }
}