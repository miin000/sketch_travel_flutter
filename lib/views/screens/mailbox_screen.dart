import 'package:flutter/material.dart';
import '/constants.dart';
import 'tabs/conversations_screen.dart';
import 'tabs/notifications_screen.dart';

class MailboxScreen extends StatelessWidget {
  const MailboxScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          bottom: TabBar(
            indicatorColor: buttonColor,
            labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'Tin nhắn'),
              Tab(text: 'Thông báo'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Tin nhắn
            ConversationsScreen(),
            // Tab 2: Thông báo
            NotificationsScreen(),
          ],
        ),
      ),
    );
  }
}