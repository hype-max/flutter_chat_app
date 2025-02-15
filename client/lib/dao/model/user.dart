import '../base/base_model.dart';

class UserStatus {
  static const int OFFLINE = 0;
  static const int ONLINE = 1;
  static const int AWAY = 2;
}

class Gender {
  static const int UNKNOWN = 0;
  static const int MALE = 1;
  static const int FEMALE = 2;
}

class User implements BaseModel {
  int? id;
  String userId;
  String nickname;
  String? avatar;
  int? status;
  String? signature;
  int? gender;
  String? phone;
  String? email;
  int? lastOnlineTime;
  int? createdAt;
  int? updatedAt;

  User({
    this.id,
    required this.userId,
    required this.nickname,
    this.avatar,
    this.status,
    this.signature,
    this.gender,
    this.phone,
    this.email,
    this.lastOnlineTime,
    this.createdAt,
    this.updatedAt,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'nickname': nickname,
      'avatar': avatar,
      'status': status,
      'signature': signature,
      'gender': gender,
      'phone': phone,
      'email': email,
      'last_online_time': lastOnlineTime,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  dynamic getPrimaryKey() => id;

  @override
  String getTableName() => 'users';

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      userId: map['user_id'],
      nickname: map['nickname'],
      avatar: map['avatar'],
      status: map['status'],
      signature: map['signature'],
      gender: map['gender'],
      phone: map['phone'],
      email: map['email'],
      lastOnlineTime: map['last_online_time'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }
}
