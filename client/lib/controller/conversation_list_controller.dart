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
    
    // 监听会话列表变化
    _chatService.conversationsStream.listen((conversations) {
      this.conversations = conversations;
      refreshView();
    });
    
    // 连接WebSocket
    _chatService.connect().then((_) {
      loadConversations();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('连接失败: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  Future<void> onRefresh() async {
    await loadConversations();
  }

  Future<void> loadConversations() async {
    isLoading = true;
    refreshView();

    try {
      await _chatService.getConversations();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('加载会话列表失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      isLoading = false;
      refreshView();
    }
  }

  void openChat(Conversation conversation) {
    // 打开聊天页面时清除未读消息数
    conversation.unreadCount = 0;
    _chatService.upsertConversation(conversation);
    refreshView();
    
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
