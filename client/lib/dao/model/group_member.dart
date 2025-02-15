import '../base/base_model.dart';

class GroupMemberRole {
  static const int MEMBER = 0;
  static const int ADMIN = 1;
  static const int OWNER = 2;
}

class GroupMember implements BaseModel {
  final int? id;
  final String groupId;
  final String userId;
  final String? nickname;
  final int role;
  final int joinTime;
  final int createdAt;
  final int updatedAt;

  GroupMember({
    this.id,
    required this.groupId,
    required this.userId,
    this.nickname,
    required this.role,
    required this.joinTime,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_id': groupId,
      'user_id': userId,
      'nickname': nickname,
      'role': role,
      'join_time': joinTime,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  dynamic getPrimaryKey() => id;

  @override
  String getTableName() => 'group_members';

  factory GroupMember.fromMap(Map<String, dynamic> map) {
    return GroupMember(
      id: map['id'],
      groupId: map['group_id'],
      userId: map['user_id'],
      nickname: map['nickname'],
      role: map['role'],
      joinTime: map['join_time'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }
}
