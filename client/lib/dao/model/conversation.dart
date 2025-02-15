import '../base/base_model.dart';

class ConversationType {
  static const int PRIVATE = 0;
  static const int GROUP = 1;
}

class Conversation implements BaseModel {
  int? id;
  String conversationId;
  int conversationType;
  String? lastMessage;
  int? lastMessageTime;
  int unreadCount;
  String targetId;
  String? conversationName;
  String? conversationAvatar;
  int? pinTime;
  int? createdAt;
  int? updatedAt;

  Conversation({
    this.id,
    required this.conversationId,
    required this.conversationType,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    required this.targetId,
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
      'conversation_id': conversationId,
      'conversation_type': conversationType,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime,
      'unread_count': unreadCount,
      'target_id': targetId,
      'conversation_name': conversationName,
      'conversation_avatar': conversationAvatar,
      'pin_time': pinTime,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  dynamic getPrimaryKey() => id;

  @override
  String getTableName() => 'conversations';

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'],
      conversationId: map['conversation_id'],
      conversationType: map['conversation_type'],
      lastMessage: map['last_message'],
      lastMessageTime: map['last_message_time'],
      unreadCount: map['unread_count'] ?? 0,
      targetId: map['target_id'],
      conversationName: map['conversation_name'],
      conversationAvatar: map['conversation_avatar'],
      pinTime: map['pin_time'] ?? 0,
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }
}
