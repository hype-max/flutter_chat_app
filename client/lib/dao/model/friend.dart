import '../base/base_model.dart';

class FriendStatus {
  static const int PENDING = 0;
  static const int ACCEPTED = 1;
  static const int BLOCKED = 2;
}
class Friend extends BaseModel {
  int? id;
  int? userId;
  int? friendId;
  String? remark;
  int status;
  int? createTime;
  int? updateTime;

  Friend({
    this.id,
    this.userId,
    this.friendId,
    this.remark,
    this.status = 0,
    this.createTime,
    this.updateTime,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'friendId': friendId,
      'remark': remark,
      'status': status,
      'createdTime': createTime,
      'updatedTime': updateTime,
    };
  }

  static Friend fromMap(Map<String, dynamic> map) {
    return Friend(
      id: map['id'],
      userId: map['userId'],
      friendId: map['friendId'],
      remark: map['remark'],
      status: map['status'] ?? 0,
      createTime: map['createTime'],
      updateTime: map['updateTime'],
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
