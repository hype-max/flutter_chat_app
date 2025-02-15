import 'package:flutter/material.dart';
import '../controller/chat_controller.dart';
import '../dao/model/conversation.dart';
import 'chat_page.dart';

class ChatPageContainer extends StatelessWidget {
  final Conversation conversation;

  const ChatPageContainer({
    super.key,
    required this.conversation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(conversation.conversationName ?? '聊天'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: 显示更多选项菜单
            },
          ),
        ],
      ),
      body: ChatPage(
        controller: ChatController(conversation),
      ),
    );
  }
}
