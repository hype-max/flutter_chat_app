import '../base/base_model.dart';

class MessageContentType {
  static const int TEXT = 0;
  static const int IMAGE = 1;
  static const int VOICE = 2;
  static const int VIDEO = 3;
  static const int FILE = 4;
  static const int LOCATION = 5;
}

class MessageStatus {
  static const int SENDING = 0;
  static const int SENT = 1;
  static const int DELIVERED = 2;
  static const int READ = 3;
  static const int FAILED = 4;
}

class Message implements BaseModel {
   int? id;
   String messageId;
   String conversationId;
   String senderId;
   int contentType;
   String content;
   int status;
   int sendTime;
   int? receiveTime;
   int? readTime;
   String? extra;
   int createdAt;

  Message({
    this.id,
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.contentType,
    required this.content,
    required this.status,
    required this.sendTime,
    this.receiveTime,
    this.readTime,
    this.extra,
    required this.createdAt,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message_id': messageId,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'content_type': contentType,
      'content': content,
      'status': status,
      'send_time': sendTime,
      'receive_time': receiveTime,
      'read_time': readTime,
      'extra': extra,
      'created_at': createdAt,
    };
  }

  @override
  dynamic getPrimaryKey() => id;

  @override
  String getTableName() => 'messages';

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      messageId: map['message_id'],
      conversationId: map['conversation_id'],
      senderId: map['sender_id'],
      contentType: map['content_type'],
      content: map['content'],
      status: map['status'],
      sendTime: map['send_time'],
      receiveTime: map['receive_time'],
      readTime: map['read_time'],
      extra: map['extra'],
      createdAt: map['created_at'],
    );
  }
}
