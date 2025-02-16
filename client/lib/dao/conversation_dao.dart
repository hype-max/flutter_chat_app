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
      conversationType: 0,
      conversationName: '',
      createdAt: 0,
      updatedAt: 0,
      targetId: 1,
    );
  }

  Future<List<Conversation>> getConversations() async {
    return findWhere(
      orderBy: 'lastMessageTime DESC',
    );
  }

  Future<void> updateLastMessage(
      String conversationId, String message, int timestamp) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await rawUpdate(
      'UPDATE ${(await getInstance()).getTableName()} SET lastMessage = ?, lastMessageTime = ?, updated_at = ? WHERE conversationId = ?',
      [message, timestamp, now, conversationId],
    );
  }

  Future<void> updateUnreadCount(String conversationId, int unreadCount) async {
    await rawUpdate(
      'UPDATE ${(await getInstance()).getTableName()} SET unreadCount = ? WHERE conversationId = ?',
      [unreadCount, conversationId],
    );
  }

  Future<Conversation?> getConversation(String conversationId) async {
    final List<Conversation> conversations = await findWhere(
      where: 'conversationId = ?',
      whereArgs: [conversationId],
      limit: 1,
    );
    return conversations.isEmpty ? null : conversations.first;
  }

  Future<Conversation?> upsertConversation(Conversation conversation) async {
    var old = await findWhere(
        where: "targetId = ? and conversationType=?",
        whereArgs: [
          conversation.targetId,
          conversation.conversationType,
        ]);
    if (old.isNotEmpty) {
      var first = old.first;
      await update(conversation..id = first.id);
    }else {
      conversation.id = await insert(conversation);
    }
    return conversation;
  }
}
