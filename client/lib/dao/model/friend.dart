import '../base/base_model.dart';

class FriendStatus {
  static const int PENDING = 0;
  static const int ACCEPTED = 1;
  static const int REJECTED = 2;
  static const int BLOCKED = 3;
}

class Friend extends BaseModel {
  int? id;
  int? userId;
  int? friendId;
  int status;
  int? createTime;
  int? updateTime;

  Friend({
    this.id,
    this.userId,
    this.friendId,
    this.status = FriendStatus.PENDING,
    this.createTime,
    this.updateTime,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'friendId': friendId,
      'status': status,
      'createTime': createTime,
      'updateTime': updateTime,
    };
  }

  static Friend fromMap(Map<String, dynamic> map) {
    return Friend(
      id: map['id'],
      userId: map['userId'],
      friendId: map['friendId'],
      status: map['status'] ?? FriendStatus.PENDING,
      createTime: map['createTime'] != null 
          ? DateTime.parse(map['createTime']).millisecondsSinceEpoch 
          : null,
      updateTime: map['updateTime'] != null 
          ? DateTime.parse(map['updateTime']).millisecondsSinceEpoch 
          : null,
    );
  }

  @override
  String getTableName() {
    return "friends";
  }

  @override
  getPrimaryKey() {
    return "id";
  }

  @override
  Friend fromJson(Map<String, dynamic> json) {
    return Friend.fromMap(json);
  }
}
