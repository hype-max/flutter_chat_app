import 'package:flutter/material.dart';
import '../utils/mvc.dart';
import '../controller/user_info_controller.dart';

class UserInfoPage extends MvcView<UserInfoController> {

  const UserInfoPage({
    super.key,
    required super.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户信息'),
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // 头像
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: controller.user.avatarUrl != null
                          ? NetworkImage(controller.user.avatarUrl!)
                          : null,
                      child: controller.user.avatarUrl == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 用户信息列表
                  ListTile(
                    title: const Text('昵称'),
                    subtitle: Text(controller.user.nickname ?? ''),
                  ),
                  const Divider(height: 1),
                  if (controller.user.email != null) ...[
                    ListTile(
                      title: const Text('邮箱'),
                      subtitle: Text(controller.user.email!),
                    ),
                    const Divider(height: 1),
                  ],
                  if (controller.user.signature != null) ...[
                    ListTile(
                      title: const Text('个性签名'),
                      subtitle: Text(controller.user.signature!),
                    ),
                    const Divider(height: 1),
                  ],
                  const SizedBox(height: 20),
                  // 操作按钮
                  if (!controller.isSelf) Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: controller.sendFriendRequest,
                            child: const Text('添加好友'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
