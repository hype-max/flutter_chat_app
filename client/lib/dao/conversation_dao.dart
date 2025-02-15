import 'base/base_dao.dart';
import 'model/conversation.dart';

class ConversationDao extends BaseDao<Conversation> {
  @override
  Conversation createModel(Map<String, dynamic> map) {
    return Conversation.fromMap(map);
  }

  @override
  Future<Conversation> getInstance() async {
    return Conversation(
      conversationId: '',
      conversationType: 0,
      targetId: '',
      conversationName: '',
      createdAt: 0,
      updatedAt: 0,
    );
  }

  Future<List<Conversation>> getConversations() async {
    return findWhere(
      orderBy: 'last_message_time DESC',
    );
  }

  Future<void> updateLastMessage(String conversationId, String message, int timestamp) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await rawUpdate(
      'UPDATE ${(await getInstance()).getTableName()} SET last_message = ?, last_message_time = ?, updated_at = ? WHERE conversation_id = ?',
      [message, timestamp, now, conversationId],
    );
  }

  Future<void> updateUnreadCount(String conversationId, int unreadCount) async {
    await rawUpdate(
      'UPDATE ${(await getInstance()).getTableName()} SET unread_count = ? WHERE conversation_id = ?',
      [unreadCount, conversationId],
    );
  }

  Future<Conversation?> getConversation(String conversationId) async {
    final List<Conversation> conversations = await findWhere(
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      limit: 1,
    );
    return conversations.isEmpty ? null : conversations.first;
  }
}
