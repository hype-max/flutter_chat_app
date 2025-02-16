import 'package:flutter/material.dart';
import '../entity/user.dart';
import '../utils/mvc.dart';
import '../dao/model/friend.dart';
import '../page/friend_requests_page.dart';
import '../page/chat_page_container.dart';
import '../dao/model/conversation.dart';
import '../service/chat_service.dart';
import '../api/chat_api.dart';

class FriendListController extends MvcContextController {
  final _chatApi = ChatApi();
  List<Friend> friends = [];
  Map<int, User> _userCache = {};
  bool isLoading = false;

  @override
  void initState(BuildContext context) {
    super.initState(context);
    loadFriends();
  }

  @override
  void didUpdateWidget(covariant MvcView<FriendListController> oldWidget) {
    super.didUpdateWidget(oldWidget);
    friends = oldWidget.controller.friends;
    _userCache = oldWidget.controller._userCache;
    isLoading = oldWidget.controller.isLoading;
  }

  Future<void> onRefresh() async {
    await loadFriends();
  }

  Future<void> loadFriends() async {
    isLoading = true;
    refreshView();

    try {
      // 从服务器获取好友列表
      final friendUsers = await _chatApi.getFriends();
      // 更新好友数据库
      final newFriends = friendUsers
          .map((user) => Friend(
                id: user.id,
                userId: user.id,
                friendId: user.id,
                status: 1,
                createTime: DateTime.now().millisecondsSinceEpoch,
              ))
          .toList();
      // 更新界面数据
      friends = newFriends;
      for (var friend in newFriends) {
        var userId = friend.friendId!;
        var userInfo = await _chatApi.getUser(userId);
        _userCache[userId] = userInfo;
      }
      refreshView();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('加载好友列表失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      isLoading = false;
      refreshView();
    }
  }

  void openFriendRequests() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FriendRequestsPage(),
      ),
    ).then((_) => loadFriends()); // 返回时刷新好友列表
  }

  void openChat(User friend) {
    final conversation = Conversation(
      id: int.parse(friend.id.toString()),
      conversationType: 1,
      conversationName: friend.nickname,
      conversationAvatar: friend.avatarUrl,
      targetId: friend.id ?? 1,
    );
    ChatService().upsertConversation(conversation);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPageContainer(
          conversation: conversation,
        ),
      ),
    );
  }

  User? getUser(int friendId) {
    return _userCache[friendId];
  }
}
