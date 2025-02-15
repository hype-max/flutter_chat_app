import 'package:flutter/material.dart';
import '../utils/mvc.dart';
import '../dao/model/message.dart';
import '../dao/model/conversation.dart';
import '../service/chat_service.dart';

class ChatController extends MvcContextController {
  final _chatService = ChatService();
  Conversation? conversation;
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  List<Message> messages = [];
  bool isLoading = false;

  ChatController(this.conversation);

  @override
  void initState(BuildContext context) {
    super.initState(context);
    if (conversation != null) {
      _chatService.getMessageStream(conversation!.conversationId).listen((messages) {
        this.messages = messages;
        refreshView();
      });
    }
    setupScrollListener();
    loadMessages();
  }

  void setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        loadMoreMessages();
      }
    });
  }

  Future<void> loadMessages() async {
    if (conversation == null) return;
    isLoading = true;
    refreshView();

    try {
      await _chatService.getMessages(conversation!.conversationId);
    } finally {
      isLoading = false;
      refreshView();
    }
  }

  Future<void> loadMoreMessages() async {
    if (conversation == null || messages.isEmpty) return;
    
    final beforeTime = messages.last.sendTime;
    await _chatService.getMessages(
      conversation!.conversationId,
      beforeTime: beforeTime,
    );
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty || conversation == null) return;

    textController.clear();

    final message = Message(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversation!.conversationId,
      senderId: 'currentUserId', // TODO: 获取当前用户ID
      contentType: MessageContentType.TEXT,
      content: text,
      status: MessageStatus.SENDING,
      sendTime: DateTime.now().millisecondsSinceEpoch,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _chatService.sendMessage(message);
  }

  @override
  void dispose() {
    textController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
