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
      await _messageDao.insert(message);
      _messagesController.add(message);
      var targetId = message.senderId;
      await _conversationDao.upsertConversation(
          Conversation(conversationType: 1, targetId: targetId));
    });
  }

  Future<void> connect() async {
    await _messageService.connect();
  }

  Future<void> getConversations() async {
    final conversations = await _conversationDao.findAll();
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

  Future handleFriendRequest(int requestId, bool accept) async {
    await _chatApi.handleFriendRequest(requestId, accept);
    await _friendDao.updateFriendStatus(requestId, accept ? 1 : 2);

    sendMessage(
      Message(
        senderId: UserService().currentUser!.id!,
        content: jsonEncode({
          requestId: requestId,
          'accept': accept,
        }),
        contentType: MessageContentType.FRIEND_RESPONSE,
      ),
    );
  }

  Future upsertConversation(Conversation conversation) async {
    await _conversationDao.upsertConversation(conversation);
    await getConversations();
  }

  Future<List<Friend>> getFriendRequest() async {
    return _friendDao.findAll();
  }
}
