import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:notepad/common/domain/ChatUser.dart';
import 'package:notepad/common/module/AnoToast.dart';

import '../core/websocket_service.dart';
import 'mixin/MessageMixin.dart';
import 'mixin/RoomMixin.dart';
import 'mixin/UserMixin.dart';

class AuthController extends ChangeNotifier
    with UserMixin, RoomMixin, MessageMixin {
  final String _url = 'ws://127.0.0.1:8081/chat';
  final WebSocketService _ws = WebSocketService();
  String webSocketStatus = "初始化中";
  WebSocketConnectionStatus webSocketResult =
      WebSocketConnectionStatus.disconnected;
  late StreamSubscription<List<ConnectivityResult>> subscription;
  ConnectivityResult networkResult = ConnectivityResult.none;
  String networkStatus = "未知";

  AuthController() {
    _ws.addStatusListener((status) {
      switch (status) {
        case WebSocketConnectionStatus.connecting:
          webSocketStatus = "服务器连接中";
          break;
        case WebSocketConnectionStatus.disconnected:
          webSocketStatus = "服务器断开连接";
          logout(not: false);
          break;
        case WebSocketConnectionStatus.connected:
          webSocketStatus = "服务器已连接";
          if (currentUser == null) {
            init();
          }
          break;
        case WebSocketConnectionStatus.error:
          webSocketStatus = "服务器异常";
          logout(not: false);
          break;
      }
      webSocketResult = status;
      notifyListeners();
    });
    subscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      switch (result.first) {
        case ConnectivityResult.wifi:
          networkStatus = "Wi-Fi";
          break;
        case ConnectivityResult.mobile:
          networkStatus = "移动网络";
          break;
        case ConnectivityResult.ethernet:
          networkStatus = "有线网络";
          break;
        case ConnectivityResult.vpn:
          networkStatus = "VPN";
          break;
        case ConnectivityResult.other:
          networkStatus = "其他网络";
          break;
        case ConnectivityResult.none:
          networkStatus = "无网络";
          break;
        case ConnectivityResult.bluetooth:
          networkStatus = "蓝牙";
          break;
      }
      networkResult = result.first;

      if (networkResult != ConnectivityResult.none &&
          webSocketResult != WebSocketConnectionStatus.connected &&
          webSocketResult != WebSocketConnectionStatus.connecting) {
        connectWebsocket();
      }
      notifyListeners();
    });
  }

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
        _initData();
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
  /// {not} 是否通知监听者刷新 UI
  void logout({bool not = true}) {
    _currentUser = null;
    _token = null;
    if (not) {
      notifyListeners();
    }
  }

  _initData() {
    String token = _token!;
    initUser(_ws, token, _currentUser!.id);
    initRoom(_ws, token, _currentUser!.id);
    initMessage(_ws, token, _currentUser!.id, 20);
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }
}
