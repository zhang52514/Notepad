import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:notepad/common/domain/ChatUser.dart';

import '../core/websocket_service.dart';

class AuthController extends ChangeNotifier {
  final String _url = 'ws://127.0.0.1:8081/chat';
  ChatUser? _currentUser;
  String? token;

  ChatUser? get currentUser => _currentUser;

  AuthController() {}

  Future<void> init() async {
    await SpUtil.getInstance(); // 确保 SharedPreferences 已初始化

    Map<dynamic, dynamic>? userinfo = SpUtil.getObject("userinfo");
    token = SpUtil.getString("token");

    if (userinfo != null && token != null) {
      var ws = WebSocketService();
      ws.initialize(url: _url);

      // 等待 WebSocket 连接成功（你可能需要加个监听或等待机制）
      ws.addListener((msg) {
        if (msg.code == "200" && msg.data != null) {
          _currentUser = ChatUser.fromJson(msg.data);
          token = msg.data["key"];
          notifyListeners(); // 数据加载后再刷新 UI
        }
      });

      // 你也可以把发送 auth 的逻辑封装到 WebSocketService 中更优雅
      ws.send({"cmd": "auth", "userName": "admin", "userPwd": "123133131"});
    }
  }

  void login(ChatUser user) {
    _currentUser = user;
    WebSocketService().initialize(url: _url);
    SpUtil.putObject("userinfo", user.toJson());
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
