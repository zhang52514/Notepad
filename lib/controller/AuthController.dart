import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:notepad/common/domain/ChatUser.dart';
import 'package:notepad/common/module/AnoToast.dart';

import '../core/websocket_service.dart';

class AuthController extends ChangeNotifier {
  final String _url = 'ws://127.0.0.1:8081/chat';
  final WebSocketService _ws = WebSocketService();

  ChatUser? _currentUser;
  String? _token;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  ChatUser? get currentUser => _currentUser;

  String? get token => _token;

  /// 初始化方法，通过本地存储的用户信息自动进行身份验证
  Future<void> init() async {
    final Map<dynamic, dynamic>? userInfo = SpUtil.getObject("userinfo");
    final String? storedToken = SpUtil.getString("token");

    if (userInfo != null && storedToken != null && _currentUser == null) {
      _isLoading = true;
      try {
        _ws.auth(userInfo["username"], userInfo["password"]);
      } catch (e) {
        print("WebSocket auth init error: $e");
      }
    }
  }

  void connectWebsocket() {
    _ws.initialize(url: _url);
    _ws.addListener(_onMessageReceived);
  }

  /// 登录方法，通过传入的用户对象进行身份验证
  void login(String username, String password) {
    _isLoading = true;
    try {
      _ws.auth(username, password);
    } catch (e) {
      print("WebSocket auth login error: $e");
    }
    notifyListeners();
  }

  /// 通用的消息处理方法
  void _onMessageReceived(dynamic msg) {
    if (_currentUser != null) return;
    if (msg.code == "200" && msg.data != null) {
      if (msg.data["user"] != null && msg.data["key"] != null) {
        _currentUser = ChatUser.fromJson(msg.data["user"]);
        _token = msg.data["key"];

        // 更新本地存储
        SpUtil.putObject("userinfo", _currentUser!.toJson());
        SpUtil.putString("token", _token!);
      } else {
        AnoToast.showToast("用户信息不存在，请检查后再试！", type: ToastType.error);
      }
    } else {
      AnoToast.showToast(msg.message, type: ToastType.error);
    }
    _isLoading = false;
    // 通知监听者刷新 UI
    notifyListeners();
  }

  /// 退出登录，清除用户数据及本地存储缓存
  void logout() {
    _currentUser = null;
    _token = null;
    notifyListeners();
  }
}
