import 'package:sqflite/sqflite.dart';
import 'base/base_dao.dart';
import 'model/message.dart';

class MessageDao extends BaseDao<Message> {
  @override
  Message createModel(Map<String, dynamic> map) {
    return Message.fromMap(map);
  }

  @override
  Future<Message> getInstance() async {
    return Message(
      messageId: '',
      conversationId: '',
      senderId: '',
      contentType: 0,
      content: '',
      status: 0,
      sendTime: 0,
      createdAt: 0,
    );
  }

  Future<List<Message>> getMessages(String conversationId, {int? beforeTime, int limit = 20}) async {
    return findWhere(
      where: beforeTime != null 
          ? 'conversation_id = ? AND send_time < ?' 
          : 'conversation_id = ?',
      whereArgs: beforeTime != null 
          ? [conversationId, beforeTime]
          : [conversationId],
      orderBy: 'send_time DESC',
      limit: limit,
    );
  }

  Future<void> updateMessageStatus(String messageId, int status) async {
    await rawUpdate(
      'UPDATE ${(await getInstance()).getTableName()} SET status = ? WHERE message_id = ?',
      [status, messageId],
    );
  }

  Future<void> markAsRead(String conversationId, int readTime) async {
    await rawUpdate(
      'UPDATE ${(await getInstance()).getTableName()} SET read_time = ? WHERE conversation_id = ? AND read_time IS NULL',
      [readTime, conversationId],
    );
  }

  Future<int> getUnreadCount(String conversationId) async {
    return count(
      where: 'conversation_id = ? AND read_time IS NULL',
      whereArgs: [conversationId],
    );
  }
}
