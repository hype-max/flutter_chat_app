import '../base/base_model.dart';

class ConversationType {
  static const int PRIVATE = 0;
  static const int GROUP = 1;
  static const int AI = 2;
}

class Conversation extends BaseModel {
  int? id;
  int? userId;
  int conversationType;
  String? lastMessage;
  int? lastMessageTime;
  int unreadCount;
  int? targetId;
  String? conversationName;
  String? conversationAvatar;
  int pinTime;
  int? createdAt;
  int? updatedAt;

  Conversation({
    this.id,
    this.userId,
    required this.conversationType,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.targetId,
    this.conversationName,
    this.conversationAvatar,
    this.pinTime = 0,
    this.createdAt,
    this.updatedAt,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'conversationType': conversationType,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'unreadCount': unreadCount,
      'targetId': targetId,
      'conversationName': conversationName,
      'conversationAvatar': conversationAvatar,
      'pinTime': pinTime,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static Conversation fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'],
      userId: map['userId'],
      conversationType: map['conversationType'],
      lastMessage: map['lastMessage'],
      lastMessageTime: map['lastMessageTime'],
      unreadCount: map['unreadCount'] ?? 0,
      targetId: map['targetId'],
      conversationName: map['conversationName'],
      conversationAvatar: map['conversationAvatar'],
      pinTime: map['pinTime'] ?? 0,
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  @override
  String getTableName() {
    return "conversations";
  }

  @override
  dynamic getPrimaryKey() => id;

  Conversation fromJson(Map<String, dynamic> json) {
    return Conversation.fromMap(json);
  }
}
