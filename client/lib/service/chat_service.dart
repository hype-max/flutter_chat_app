import 'dart:async';
import 'package:chat_client/dao/conversation_dao.dart';
import 'package:chat_client/dao/friend_dao.dart';
import 'package:chat_client/dao/message_dao.dart';

import '../dao/model/conversation.dart';
import '../dao/model/message.dart';
import '../dao/model/user.dart';
import '../dao/model/friend.dart';

class ChatService {
  // 单例实现
  static final ChatService _instance = ChatService._internal();

  factory ChatService() => _instance;

  ChatService._internal();

  // 会话列表流
  final _conversationsController =
      StreamController<List<Conversation>>.broadcast();

  Stream<List<Conversation>> get conversationsStream =>
      _conversationsController.stream;

  // 消息列表流（按会话ID分组）
  final _messagesControllers = <String, StreamController<List<Message>>>{};

  // 好友列表流
  final _friendsController = StreamController<List<User>>.broadcast();

  Stream<List<User>> get friendsStream => _friendsController.stream;

  // 好友请求列表流
  final _friendRequestsController = StreamController<List<Friend>>.broadcast();

  Stream<List<Friend>> get friendRequestsStream =>
      _friendRequestsController.stream;

  // 当前会话列表缓存
  List<Conversation> _conversations = [];

  // 消息缓存（按会话ID分组）
  final _messages = <String, List<Message>>{};

  // 好友列表缓存
  List<User> _friends = [];

  // 好友请求缓存
  List<Friend> _friendRequests = [];

  // 获取会话列表
  Future<List<Conversation>> getConversations() async {
    _conversations = await ConversationDao().getConversations();
    _conversationsController.add(_conversations);
    return _conversations;
  }

  // 获取会话消息列表
  Future<List<Message>> getMessages(String conversationId,
      {int? beforeTime}) async {
    return await MessageDao().findAll();
  }

  // 发送消息
  Future<void> sendMessage(Message message) async {
    // TODO: 发送消息到服务器
    message.status = MessageStatus.SENT;
    message.sendTime = DateTime.now().millisecondsSinceEpoch;

    // 更新消息列表
    final messages = _messages[message.conversationId] ?? [];
    messages.add(message);
    _messages[message.conversationId] = messages;
    _getMessagesController(message.conversationId).add(messages);

    // 更新会话列表
    final conversation = _conversations.firstWhere(
      (conv) => conv.conversationId == message.conversationId,
      orElse: () => Conversation(
        conversationId: message.conversationId,
        conversationType: 1,
        targetId: message.conversationId,
      ),
    );

    conversation.lastMessage = message.content;
    conversation.lastMessageTime = message.sendTime;
    if (!_conversations.contains(conversation)) {
      _conversations.add(conversation);
    }
    _conversationsController.add(_conversations);
  }

  // 获取好友列表
  Future<List<Friend>> getFriends() async {

    return await FriendDao().findAll();
  }

  // 获取好友请求列表
  Future<List<Friend>> getFriendRequests() async {
    // TODO: 从数据库或网络加载好友请求
    _friendRequests = [
      Friend(
        id: 1,
        userId: 'currentUserId',
        friendId: '3',
        status: 0,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: null,
      ),
    ];
    _friendRequestsController.add(_friendRequests);
    return _friendRequests;
  }

  // 处理好友请求
  Future<void> handleFriendRequest(String friendId, bool accept) async {
    // TODO: 发送请求到服务器
    final request = _friendRequests.firstWhere(
      (req) => req.friendId == friendId,
    );
    request.status = accept ? 1 : 2;
    _friendRequestsController.add(_friendRequests);

    if (accept) {
      // 添加到好友列表
      _friends.add(User(
        userId: friendId,
        nickname: '新好友',
      ));
      _friendsController.add(_friends);
    }
  }

  // 获取指定会话的消息流
  Stream<List<Message>> getMessageStream(String conversationId) {
    return _getMessagesController(conversationId).stream;
  }

  // 获取或创建消息流控制器
  StreamController<List<Message>> _getMessagesController(
      String conversationId) {
    if (!_messagesControllers.containsKey(conversationId)) {
      _messagesControllers[conversationId] =
          StreamController<List<Message>>.broadcast();
    }
    return _messagesControllers[conversationId]!;
  }

  // 清理资源
  void dispose() {
    _conversationsController.close();
    _friendsController.close();
    _friendRequestsController.close();
    for (final controller in _messagesControllers.values) {
      controller.close();
    }
    _messagesControllers.clear();
  }
}
