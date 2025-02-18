import 'package:flutter/material.dart';
import '../api/chat_api.dart';
import '../entity/user.dart';
import '../utils/mvc.dart';
import '../service/user_service.dart';

class UserInfoController extends MvcContextController {
  final User user;
  final _chatApi = ChatApi();
  final _userService = UserService();
  bool _isLoading = false;

  UserInfoController({required this.user});

  bool get isLoading => _isLoading;

  bool get isSelf => user.id == _userService.currentUser?.id;

  void _setLoading(bool loading) {
    _isLoading = loading;
    refreshView();
  }

  Future<void> sendFriendRequest() async {
    if (isSelf) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('不能添加自己为好友')),
        );
      }
      return;
    }

    _setLoading(true);

    try {
      await _chatApi.sendFriendRequest(user.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('好友请求已发送')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      _setLoading(false);
    }
  }
}
