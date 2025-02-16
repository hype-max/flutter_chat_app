import '../base/base_model.dart';

class GroupMemberRole {
  static const int MEMBER = 0;
  static const int ADMIN = 1;
  static const int OWNER = 2;
}

class GroupMember extends BaseModel {
  int? id;
  String groupId;
  String userId;
  String? nickname;
  int role;
  int? createdAt;
  int? updatedAt;

  GroupMember({
    this.id,
    required this.groupId,
    required this.userId,
    this.nickname,
    required this.role,
    this.createdAt,
    this.updatedAt,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'userId': userId,
      'nickname': nickname,
      'role': role,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static GroupMember fromMap(Map<String, dynamic> map) {
    return GroupMember(
      id: map['id'],
      groupId: map['groupId'],
      userId: map['userId'],
      nickname: map['nickname'],
      role: map['role'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  @override
  String getTableName() {
    return "groupMembers";
  }

  @override
  getPrimaryKey() {
    return "id";
  }

  @override
  GroupMember fromJson(Map<String, dynamic> json) {
    return GroupMember.fromMap(json);
  }
}
