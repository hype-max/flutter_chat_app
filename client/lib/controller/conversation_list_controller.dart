import 'package:flutter/material.dart';
import '../utils/mvc.dart';
import '../dao/model/conversation.dart';
import '../page/chat_page_container.dart';
import '../service/chat_service.dart';

class ConversationListController extends MvcContextController {
  final _chatService = ChatService();
  List<Conversation> conversations = [];
  bool isLoading = false;

  @override
  void initState(BuildContext context) {
    super.initState(context);
    _chatService.conversationsStream.listen((conversations) {
      this.conversations = conversations;
      refreshView();
    });
    loadConversations();
  }

  Future<void> onRefresh() async {
    await loadConversations();
  }

  Future<void> loadConversations() async {
    isLoading = true;
    refreshView();

    try {
      await _chatService.getConversations();
    } finally {
      isLoading = false;
      refreshView();
    }
  }

  void openChat(Conversation conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPageContainer(
          conversation: conversation,
        ),
      ),
    );
  }
}
