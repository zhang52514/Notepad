import 'package:notepad/common/domain/ChatEnumAll.dart';

/// 表示聊天系统中的一个用户。
///
/// 该类封装了用户的基本信息，包括唯一标识、登录名、昵称、头像、联系方式等。
/// 同时也包含用户的当前状态和角色（如成员、管理员等）。
class ChatUser {
  /// 用户的唯一标识符，必填项。
  String id;

  /// 用户登录系统的用户名，默认为空字符串。
  String username;

  /// 用户的昵称，用于在聊天中展示，必填项。
  String nickname;

  /// 用户的登录密码，默认为空字符串。
  String password;

  /// 用户头像的URL地址，必填项。
  String avatarUrl;

  /// 用户绑定的邮箱地址，默认为空字符串。
  String email;

  /// 用户绑定的手机号码，默认为空字符串。
  String phone;

  /// 用户当前的状态描述，例如“在线”、“离线”等，默认为空字符串。
  String status;

  /// 用户在聊天系统中的角色，默认为普通成员 [ChatUserRole.member]。
  ChatUserRole role;

  /// 构造函数，创建一个 [ChatUser] 实例。
  ///
  /// 参数说明：
  /// - [id]: 用户的唯一标识，必填。
  /// - [username]: 用户名，可选，默认为空字符串。
  /// - [nickname]: 用户昵称，必填。
  /// - [password]: 用户密码，可选，默认为空字符串。
  /// - [avatarUrl]: 头像URL，必填。
  /// - [email]: 邮箱地址，可选，默认为空字符串。
  /// - [phone]: 手机号码，可选，默认为空字符串。
  /// - [status]: 当前状态，可选，默认为空字符串。
  /// - [role]: 用户角色，可选，默认为 [ChatUserRole.member]。
  ChatUser({
    required this.id,
    this.username = '',
    required this.nickname,
    this.password = '',
    required this.avatarUrl,
    this.email = '',
    this.phone = '',
    this.status = '',
    this.role = ChatUserRole.member,
  });


  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'nickname': nickname,
    'password': password,
    'avatarUrl': avatarUrl,
    'email': email,
    'phone': phone,
    'status': status,
    'role': role.name,
  };

  static ChatUser fromJson(Map<String, dynamic> json) => ChatUser(
    id: json['id'],
    username: json['username'] ?? '',
    nickname: json['nickname'],
    password: json['password'] ?? '',
    avatarUrl: json['avatarUrl'],
    email: json['email'] ?? '',
    phone: json['phone'] ?? '',
    status: json['status'] ?? '',
    role: ChatUserRole.values.byName(json['role'] ?? 'member'),
  );

  @override
  String toString() {
    return 'ChatUser{id: $id, username: $username, nickname: $nickname, password: $password, avatarUrl: $avatarUrl, email: $email, phone: $phone, status: $status, role: $role}';
  }
}

