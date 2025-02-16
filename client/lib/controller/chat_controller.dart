import 'package:flutter/material.dart';
import '../entity/user.dart';
import '../utils/mvc.dart';
import '../dao/model/message.dart';
import '../dao/model/conversation.dart';
import '../service/chat_service.dart';
import '../service/user_service.dart';
import '../dao/message_dao.dart';
import '../api/chat_api.dart';

class ChatController extends MvcContextController {
  final _chatService = ChatService();
  final _messageDao = MessageDao();
  final _chatApi = ChatApi();
  final Conversation conversation;
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  List<Message> messages = [];
  bool isLoading = false;

  // 用户信息缓存
  final Map<int, User> _userCache = {};

  ChatController(this.conversation);

  @override
  void initState(BuildContext context) {
    super.initState(context);

    // 监听新消息
    _chatService.messagesStream.listen((message) {
      if (message.receiverId == conversation.targetId ||
          message.senderId == conversation.targetId) {
        messages.insert(0, message);
        refreshView();

        // 获取发送者信息
        if (!_userCache.containsKey(message.senderId)) {
          _fetchUserInfo(message.senderId);
        }
      }
    });

    setupScrollListener();
    loadMessages();
  }

  void setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        loadMoreMessages();
      }
    });
  }

  Future<void> loadMessages() async {
    isLoading = true;
    refreshView();

    try {
      final newMessages = await _messageDao.getMessages(conversation.targetId);
      messages = newMessages;

      // 获取所有消息发送者的用户信息
      final senderIds = messages.map((m) => m.senderId).toSet();
      for (final senderId in senderIds) {
        if (!_userCache.containsKey(senderId)) {
          _fetchUserInfo(senderId);
        }
      }

      refreshView();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('加载消息失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      isLoading = false;
      refreshView();
    }
  }

  Future<void> loadMoreMessages() async {
    if (messages.isEmpty) return;
    try {
      messages = await _messageDao.findAll();
      refreshView();
    } catch (e) {
      print('加载更多消息失败: $e');
    }
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    textController.clear();

    final currentUser = UserService().currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('未登录'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final message = Message(
      senderId: currentUser.id!,
      receiverId: conversation.targetId!,
      content: text,
      contentType: MessageContentType.TEXT,
    );

    try {
      await _chatService.sendMessage(message);
      await _messageDao.insert(message);
      messages.insert(0, message);
      refreshView();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('发送消息失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchUserInfo(int userId) async {
    try {
      final user = await _chatApi.getUser(userId);
      _userCache[userId] = user;
      refreshView();
    } catch (e) {
      print('获取用户信息失败: $e');
    }
  }

  String? getAvatar(int senderId) {
    return _userCache[senderId]?.avatarUrl;
  }

  String? getUsername(int senderId) {
    return _userCache[senderId]?.nickname ?? _userCache[senderId]?.nickname;
  }

  @override
  void dispose() {
    textController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
