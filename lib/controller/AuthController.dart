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

    if (userInfo != null && storedToken != null) {
      _isLoading = true;
      // 初始化 WebSocket
      _ws.initialize(url: _url);

      // 监听服务端消息
      _ws.addListener(_onMessageReceived);

      try {
        // 使用存储的用户名和密码进行身份验证
        _ws.auth(userInfo["username"], userInfo["password"]);
      } catch (e) {
        // 此处可引入日志系统记录错误
        print("WebSocket auth init error: $e");
      }
    }
  }

  /// 登录方法，通过传入的用户对象进行身份验证
  void login(String username, String password) {
    _ws.initialize(url: _url);
    _isLoading = true;
    _ws.addListener(_onMessageReceived);

    try {
      _ws.auth(username, password);
    } catch (e) {
      print("WebSocket auth login error: $e");
    }
  }

  /// 通用的消息处理方法
  void _onMessageReceived(dynamic msg) {
    print("服务器AUTH${msg.data}");
    if (msg.code == "200" && msg.data != null) {
      _currentUser = ChatUser.fromJson(msg.data["user"]);
      print("转换的JSON：${_currentUser}");
      _token = msg.data["key"];

      // 更新本地存储
      SpUtil.putObject("userinfo", _currentUser!.toJson());
      SpUtil.putString("token", _token!);

      // 登录成功后移除监听器，避免重复回调
      _ws.removeListener(_onMessageReceived);
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

    // 清除本地缓存数据
    SpUtil.remove("userinfo");
    SpUtil.remove("token");

    notifyListeners();
  }
}
