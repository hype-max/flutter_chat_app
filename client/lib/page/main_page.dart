import 'package:flutter/material.dart';
import '../controller/main_controller.dart';
import '../controller/conversation_list_controller.dart';
import '../controller/friend_list_controller.dart';
import '../utils/mvc.dart';
import 'conversation_list_page.dart';
import 'friend_list_page.dart';

class MainPage extends MvcView<MainController> {
  const MainPage({
    super.key,
    required super.controller,
  });

  @override
  Widget build(BuildContext context) {
    final user = controller.currentUser;

    return Scaffold(
      key: controller.scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: controller.openDrawer,
        ),
        title: Text(
          controller.currentIndex == 0 ? '消息' : '联系人',
          style: const TextStyle(fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 实现搜索功能
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundImage: user?.avatarUrl != null
                    ? NetworkImage(user!.avatarUrl!)
                    : null,
                child: user?.avatarUrl == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              accountName: Text(user?.nickname ?? user?.username ?? ''),
              accountEmail: Text(user?.email ?? ''),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('个人资料'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('设置'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 实现设置页面
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('退出登录'),
              onTap: controller.logout,
            ),
          ],
        ),
      ),
      body: PageView(
        controller: controller.pageController,
        onPageChanged: controller.onPageChanged,
        children: [
          ConversationListPage(
            controller: controller.conversationListController,
          ),
          FriendListPage(
            controller: FriendListController(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: controller.currentIndex,
        onTap: controller.switchTab,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: '消息',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '联系人',
          ),
        ],
      ),
    );
  }
}
