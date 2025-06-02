class ChatUser {
  // CREATE TABLE `user` (
  // `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  // `username` varchar(50) NOT NULL COMMENT '用户名/账号（唯一）',
  // `nickname` varchar(50) DEFAULT NULL COMMENT '用户昵称',
  // `password` varchar(255) NOT NULL COMMENT '密码（加密存储）',
  // `avatar_url` varchar(255) DEFAULT NULL COMMENT '头像地址',
  // `email` varchar(100) DEFAULT NULL COMMENT '邮箱',
  // `phone` varchar(20) DEFAULT NULL COMMENT '手机号',
  // `status` tinyint DEFAULT '1' COMMENT '状态（1正常，0禁用）',
  // `role` varchar(20) DEFAULT 'USER' COMMENT '角色（USER、ADMIN等）',
  // `last_login_ip` varchar(45) DEFAULT NULL COMMENT '上次登录 IP',
  // `last_login_time` datetime DEFAULT NULL COMMENT '上次登录时间',
  // `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  // `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  // PRIMARY KEY (`id`),
  // UNIQUE KEY `username` (`username`)
  // ) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='IM 用户表';
  String uid;
  String username;
  String nickname;
  String password;
  String avatarUrl;
  String email;
  String phone;
  String status;
  String role;

  ChatUser({
    required this.uid,
    this.username = '',
    required this.nickname,
    this.password = '',
    required this.avatarUrl,
    this.email = '',
    this.phone = '',
    this.status = '',
    this.role = 'user',
  });

  factory ChatUser.fromJson(Map<dynamic, dynamic> json) {
    return ChatUser(
      uid: json['id'] ?? '',
      username: json['username'] ?? '',
      nickname: json['nickname'] ?? '',
      password: json['password'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      status: json['status']?.toString() ?? '',
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': uid,
      'username': username,
      'nickname': nickname,
      'password': password,
      'avatar_url': avatarUrl,
      'email': email,
      'phone': phone,
      'status': status,
      'role': role,
    };
  }

  @override
  String toString() {
    return 'ChatUser{uid: $uid, username: $username, nickname: $nickname, password: $password, avatarUrl: $avatarUrl, email: $email, phone: $phone, status: $status, role: $role}';
  }
}
