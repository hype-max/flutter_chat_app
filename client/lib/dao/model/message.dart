import '../base/base_model.dart';

class MessageContentType {
  static const int TEXT = 1;
  static const int IMAGE = 2;
  static const int FILE = 3;
  static const int AUDIO = 4;
  static const int VIDEO = 5;
  static const int FRIEND_REQUEST = 11;
  static const int FRIEND_RESPONSE = 12;
}

class Message extends BaseModel {
  int? id;
  int? userId;
  int senderId;
  int? receiverId;
  String content;
  int contentType;
  int? groupId;
  int? sendTime;
  int? createTime;

  Message({
    this.id,
    this.userId,
    required this.senderId,
    this.receiverId,
    required this.content,
    required this.contentType,
    this.groupId,
    this.sendTime,
    this.createTime,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'contentType': contentType,
      'groupId': groupId,
      'sendTime': sendTime,
      'createTime': createTime,
    };
  }

  static Message fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      userId: map['userId'],
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      content: map['content'],
      contentType: map['contentType'] ?? MessageContentType.TEXT,
      groupId: map['groupId'],
      sendTime: map['sendTime'],
      createTime: map['createTime'],
    );
  }

  Message fromJson(Map<String, dynamic> json) {
    return Message.fromMap(json);
  }

  @override
  getPrimaryKey() {
    return "id";
  }

  @override
  String getTableName() {
    return "messages";
  }
}
