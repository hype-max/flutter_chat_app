import 'dart:async';
import 'dart:convert';
import 'package:chat_client/dao/friend_dao.dart';
import 'package:chat_client/dao/model/friend.dart';
import 'package:chat_client/service/user_service.dart';

import '../api/chat_api.dart';
import '../dao/model/conversation.dart';
import '../dao/model/message.dart';
import '../dao/conversation_dao.dart';
import '../dao/message_dao.dart';
import '../service/message_service.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  final _chatApi = ChatApi();
  final _messageService = MessageService();
  final _conversationDao = ConversationDao();
  final _messageDao = MessageDao();
  final _friendDao = FriendDao();

  final _conversationsController =
      StreamController<List<Conversation>>.broadcast();
  final _messagesController = StreamController<Message>.broadcast();
  final _friendRequestController = StreamController<Friend>.broadcast();

  factory ChatService() {
    return _instance;
  }

  ChatService._internal() {
    _initMessageListener();
  }

  Stream<List<Conversation>> get conversationsStream =>
      _conversationsController.stream;

  Stream<Message> get messagesStream => _messagesController.stream;

  Stream<Friend> get friendStream => _friendRequestController.stream;

  void _initMessageListener() {
    _messageService.messageStream.listen((data) async {
      final message = Message.fromMap(data);
      message.userId = UserService().currentUser?.id;
      var id = await _messageDao.insert(message);
      message.id = id;
      _messagesController.add(message);

      // 更新最新消息
      final currentUserId = UserService().currentUser?.id;
      final targetId = message.senderId == currentUserId
          ? message.receiverId
          : message.senderId;

      // 获取聊天窗口信息进行更新
      var conversation = await _conversationDao.findByTargetId(targetId!) ??
          Conversation(
            conversationType: ConversationType.PRIVATE,
            targetId: targetId,
            userId: currentUserId,
            unreadCount: 0,
          );

      // 更新会话信息
      conversation.lastMessage = message.content;
      conversation.lastMessageTime = message.sendTime;
      if (message.senderId != currentUserId) {
        conversation.unreadCount = (conversation.unreadCount ?? 0) + 1;
      }

      // 通知更新窗口
      await _conversationDao.upsertConversation(conversation);
      await getConversations();
    });
  }

  Future<void> connect() async {
    await _messageService.connect();
  }

  Future<void> getConversations() async {
    final conversations =
        await _conversationDao.findByUserId(UserService().currentUser?.id);
    _conversationsController.add(conversations);
  }

  Future<void> sendMessage(Message message) async {
    _messageService.sendMessage(message.toMap());
  }

  void dispose() {
    _conversationsController.close();
    _messagesController.close();
    _messageService.dispose();
  }

  Future handleFriendRequest(Friend request, bool accept) async {
    await _chatApi.handleFriendRequest(request.id!, accept);
    await _friendDao.updateFriendStatus(request.id!, accept ? 1 : 2);
    sendMessage(
      Message(
        senderId: UserService().currentUser!.id!,
        receiverId: request.friendId,
        content: jsonEncode({
          'requestId': request.id!,
          'accept': accept,
        }),
        contentType: MessageContentType.FRIEND_RESPONSE,
      ),
    );
  }

  Future upsertConversation(Conversation conversation) async {
    conversation.userId = UserService().currentUser?.id;
    await _conversationDao.upsertConversation(conversation);
    await getConversations();
  }

  Future<List<Friend>> getFriendRequest() async {
    try {
      final requests = await _chatApi.getFriendRequests();
      final friends = requests.map((data) {
        final friend = Friend.fromMap(data);
        return friend;
      }).toList();
      return friends;
    } catch (e) {
      // Fallback to local cache if network request fails
      print('Failed to get friend requests from server: $e');
      return _friendDao.findAll();
    }
  }

  Future<void> markConversationRead(int targetId) async {
    var conversation = await _conversationDao.findByTargetId(targetId);
    if (conversation != null) {
      conversation.unreadCount = 0;
      await _conversationDao.upsertConversation(conversation);
      await getConversations();
    }
  }
}
