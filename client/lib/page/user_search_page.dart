import 'package:flutter/material.dart';
import '../utils/mvc.dart';
import '../controller/user_search_controller.dart';
import '../entity/user.dart';

class UserSearchPage extends MvcView<UserSearchController> {
  const UserSearchPage({super.key,required super.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('搜索用户'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: '搜索用户名、昵称或邮箱',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.searchController.clear();
                    controller.searchUsers();
                  },
                ),
              ),
              onChanged: (_) => controller.searchUsers(),
            ),
          ),
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '搜索失败: ${controller.error}',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.searchUsers,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (controller.searchResults.isEmpty) {
      if (controller.searchController.text.trim().isEmpty) {
        return const Center(
          child: Text('输入关键字开始搜索'),
        );
      }
      return const Center(
        child: Text('未找到相关用户'),
      );
    }

    return ListView.builder(
      itemCount: controller.searchResults.length,
      itemBuilder: (context, index) {
        final user = controller.searchResults[index];
        return _buildUserListItem(user);
      },
    );
  }

  Widget _buildUserListItem(User user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.avatarUrl != null
            ? NetworkImage(user.avatarUrl!)
            : null,
        child: user.avatarUrl == null
            ? const Icon(Icons.person)
            : null,
      ),
      title: Text(user.nickname ?? user.username),
      subtitle: Text(user.signature ?? ''),
      onTap: () => controller.viewUserProfile(user),
    );
  }
}
