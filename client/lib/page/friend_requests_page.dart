import 'package:flutter/material.dart';
import '../controller/friend_request_controller.dart';
import '../utils/mvc.dart';
import 'friend_request_page.dart';

class FriendRequestsPage extends StatelessWidget {
  const FriendRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('新的朋友'),
        centerTitle: true,
      ),
      body: FriendRequestPage(
        controller: FriendRequestController(),
      ),
    );
  }
}
