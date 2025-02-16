import 'package:flutter/material.dart';
import '../api/chat_api.dart';
import '../entity/user.dart';

class UserInfoPage extends StatefulWidget {
  final User user;

  const UserInfoPage({
    super.key,
    required this.user,
  });

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final _chatApi = ChatApi();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户信息'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // 头像
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: widget.user.avatarUrl != null
                          ? NetworkImage(widget.user.avatarUrl!)
                          : null,
                      child: widget.user.avatarUrl == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 用户信息列表
                  ListTile(
                    title: const Text('昵称'),
                    subtitle: Text(widget.user.nickname ?? ''),
                  ),
                  const Divider(height: 1),
                  if (widget.user.email != null) ...[
                    ListTile(
                      title: const Text('邮箱'),
                      subtitle: Text(widget.user.email!),
                    ),
                    const Divider(height: 1),
                  ],
                  if (widget.user.signature != null) ...[
                    ListTile(
                      title: const Text('个性签名'),
                      subtitle: Text(widget.user.signature!),
                    ),
                    const Divider(height: 1),
                  ],
                  const SizedBox(height: 20),
                  // 操作按钮
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _sendFriendRequest,
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

  Future<void> _sendFriendRequest() async {
    setState(() => _isLoading = true);

    try {
      await _chatApi.sendFriendRequest(widget.user.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('好友请求已发送')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('发送好友请求失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
