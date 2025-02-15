import 'package:flutter/material.dart';
import '../utils/mvc.dart';
import '../dao/model/user.dart';
import '../dao/model/friend.dart';
import '../page/friend_requests_page.dart';
import '../page/chat_page_container.dart';
import '../dao/model/conversation.dart';
import '../service/chat_service.dart';

class FriendListController extends MvcContextController {
  final _chatService = ChatService();
  List<Friend> friends = [];
  bool isLoading = false;

  @override
  void initState(BuildContext context) {
    super.initState(context);
    loadFriends();
  }

  Future<void> onRefresh() async {
    await loadFriends();
  }

  Future<void> loadFriends() async {
    isLoading = true;
    refreshView();

    try {
      await _chatService.getFriends();
    } finally {
      isLoading = false;
      refreshView();
    }
  }

  void openFriendRequests() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FriendRequestsPage()),
    );
  }

  void openChat(User friend) {
    final conversation = Conversation(
      conversationId: friend.userId,
      conversationType: 1,
      conversationName: friend.nickname,
      conversationAvatar: friend.avatar,
      targetId: friend.userId,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPageContainer(
          conversation: conversation,
        ),
      ),
    );
  }

  User? getUser(String friendId) {
    return null;
  }
}
