import 'package:flutter/material.dart';
import '/constants.dart';
import '/views/screens/post_feed_screen.dart';
import '/views/screens/profile_screen.dart';
import '/views/screens/search_screen.dart';
import '/views/widgets/custom_icon.dart';
import '/views/screens/add_post_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int pageIdx = 0;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      PostFeedScreen(),
      SearchScreen(),
      const AddPostScreen(),
      const Center(child: Text('Messages Screen')), // Placeholder for messages
      ProfileScreen(uid: authController.user.uid),
    ];
  }


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
        items: const [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                size: 30,
              ),
              label: 'Home'),

          // === SỬA LỖI TẠI ĐÂY ===
          BottomNavigationBarItem(
              icon: Icon(
                Icons.search, // Đổi từ notifications -> search
                size: 30,
              ),
              label: 'Search'), // Đổi từ Notification -> Search
          // =======================

          BottomNavigationBarItem(icon: CustomIcon(), label: ''),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.message,
                size: 30,
              ),
              label: 'Messages'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                size: 30,
              ),
              label: 'Profile')
        ],
      ),
      body: pages[pageIdx],
    );
  }
}