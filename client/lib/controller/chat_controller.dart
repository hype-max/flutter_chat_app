import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
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
  Map<int, Message> messageMap = {};
  bool isLoading = false;

  // 用户信息缓存
  final Map<int, User> _userCache = {};
  StreamSubscription? subscription;

  ChatController(this.conversation);

  @override
  void initState(BuildContext context) {
    super.initState(context);

    // 清除已读
    _chatService.markConversationRead(conversation.targetId!);

    // 监听新消息
    subscription = _chatService.messagesStream.listen((message) {
      if (message.receiverId == conversation.targetId ||
          message.senderId == conversation.targetId) {
        // 获取发送者信息
        if (!_userCache.containsKey(message.senderId)) {
          _fetchUserInfo(message.senderId);
        }
        // 将消息放入列表
        insertMessageToList(message);
        // Mark new messages as read immediately
        _chatService.markConversationRead(conversation.targetId!);
      }
    });

    setupScrollListener();
    loadMessages();
  }

  void insertMessageToList(Message message) {
    if (messageMap.containsKey(message.id)) {
      return;
    }
    messageMap[message.id!] = message;
    messages = messageMap.values.toList()
      ..sort(
        (a, b) => (b.createTime ?? 0).compareTo((a.createTime ?? 0)),
      );
    refreshView();
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
      final newMessages = await _messageDao.getMessages(
          UserService().currentUser?.id, conversation.targetId);
      messages = newMessages;
      for (var msg in messages) {
        messageMap[msg.id!] = msg;
      }
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
      userId: currentUser.id,
      senderId: currentUser.id!,
      receiverId: conversation.targetId!,
      content: text,
      contentType: MessageContentType.TEXT,
      createTime: DateTime.now().millisecondsSinceEpoch
    );

    try {
      await _chatService.sendMessage(message);
      var id = await _messageDao.insert(message);
      messages.insert(0, message);
      message.id = id;
      messageMap[id] = message;
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

  Future<void> uploadAndSendFile(File file, int contentType) async {
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

    // 创建一个临时消息，显示上传进度
    final tempMessage = Message(
      userId: currentUser.id,
      senderId: currentUser.id!,
      receiverId: conversation.targetId!,
      content: jsonEncode({
        'fileName': file.path.split('/').last,
        'progress': 0,
      }),
      contentType: contentType,
      createTime: DateTime.now().millisecondsSinceEpoch
    );

    messages.insert(0, tempMessage);
    refreshView();

    try {
      // 上传文件
      final result = await _chatApi.uploadFile(file, tempMessage.id??0);
      
      // 构建文件信息
      final fileInfo = {
        'fileName': file.path.split('/').last,
        'fileId': result['id'],
        'fileSize': await file.length(),
      };

      // 更新消息内容
      tempMessage.content = jsonEncode(fileInfo);

      // 发送消息
      await _chatService.sendMessage(tempMessage);
      var id = await _messageDao.insert(tempMessage);
      tempMessage.id = id;
      messageMap[id] = tempMessage;
      refreshView();
    } catch (e) {
      // 移除临时消息
      messages.remove(tempMessage);
      refreshView();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('发送文件失败: $e'),
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

  String? getUsername(int userId) {
    return _userCache[userId]?.nickname ?? _userCache[userId]?.username;
  }

  String? getAvatar(int userId) {
    return _userCache[userId]?.avatarUrl;
  }

  @override
  void onWidgetDispose() {
    super.onWidgetDispose();
    subscription?.cancel();
  }

  @override
  void dispose() {
    textController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
