import '../base/base_model.dart';

class FriendStatus {
  static const int PENDING = 0;
  static const int ACCEPTED = 1;
  static const int BLOCKED = 2;
}

class Friend implements BaseModel {
  int? id;
  String userId;
  String friendId;
  String? remark;
  int status;
  int? createdAt;
  int? updatedAt;

  Friend({
    this.id,
    required this.userId,
    required this.friendId,
    this.remark,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'friend_id': friendId,
      'remark': remark,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  dynamic getPrimaryKey() => id;

  @override
  String getTableName() => 'friends';

  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      id: map['id'],
      userId: map['user_id'],
      friendId: map['friend_id'],
      remark: map['remark'],
      status: map['status'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }
}
