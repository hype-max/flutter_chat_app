import 'package:flutter/material.dart';
import '../controller/main_controller.dart';
import '../controller/user_controller.dart';
import '../utils/mvc.dart';

class MainPage extends MvcView<MainController> {

  const MainPage({
    super.key,
    required super.controller,
  });

  @override
  Widget build(BuildContext context) {
    final user = controller.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('聊天'),
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
              onTap: () {
                // TODO: 实现退出登录
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('聊天列表'),
      ),
    );
  }
}
