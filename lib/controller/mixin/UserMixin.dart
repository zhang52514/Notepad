import 'package:flutter/material.dart';

import '../../common/domain/ChatUser.dart';
import '../../core/websocket_service.dart';

mixin UserMixin on ChangeNotifier {
  ///
  ///所有用户
  final Map<String, ChatUser> _users = {};

  Map<String, ChatUser> get users => _users;

  initUser(WebSocketService ws, String token, String id) {
    ws.http("/getUsers", token, {"id": id});
  }

  void setUsers(List<dynamic> data, String uid) {
    // 1. 清空旧列表
    _users.clear();
    // 2. 遍历 JSON 列表，转换并填充 Map
    for (final item in data) {
      final json = item as Map<String, dynamic>;
      final user = ChatUser.fromJson(json);

      _users[user.id] = user;
    }
  }

  ChatUser getUser(String id) {
    return _users[id] ?? ChatUser(id: id, nickname: "未知用户", avatarUrl: '');
  }
}
