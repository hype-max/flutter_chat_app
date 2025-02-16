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
      senderId: 0,
      contentType: 0,
      content: '',
      sendTime: 0,
      receiverId: 0,
    );
  }

  Future<List<Message>> getMessages(int? conversationId) async {
    return findWhere(
      where: 'senderId = ? or receiverId=?',
      whereArgs: [conversationId, conversationId],
      orderBy: 'sendTime DESC',
    );
  }

}
