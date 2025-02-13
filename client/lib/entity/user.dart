class User {
  final int? id;
  final String username;
  String? nickname;
  String? signature;
  String? address;
  String? email;
  String? phone;
  final int? status;
  final DateTime? lastLoginTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String? get avatarUrl => "http://localhost:8080/api/user/avatar/$id";

  User({
    this.id,
    required this.username,
    this.nickname,
    this.signature,
    this.address,
    this.email,
    this.phone,
    this.status,
    this.lastLoginTime,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      username: json['username'] as String? ?? '',
      nickname: json['nickname'] as String?,
      signature: json['signature'] as String?,
      address: json['address'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      status: json['status'] as int?,
      lastLoginTime: json['lastLoginTime'] != null
          ? DateTime.parse(json['lastLoginTime'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nickname': nickname,
      'signature': signature,
      'avatarUrl': avatarUrl,
      'address': address,
      'email': email,
      'phone': phone,
      'status': status,
      'lastLoginTime': lastLoginTime?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? nickname,
    String? signature,
    String? avatarUrl,
    String? address,
    String? email,
    String? phone,
  }) {
    return User(
      id: id,
      username: username,
      nickname: nickname ?? this.nickname,
      signature: signature ?? this.signature,
      address: address ?? this.address,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      status: status,
      lastLoginTime: lastLoginTime,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
