import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:notepad/core/ws_dispatcher.dart';

/// WebSocketProvider 用于管理 WebSocket 连接、自动重连和消息发送
class WebSocketProvider with ChangeNotifier {
  WebSocket? _socket; // 当前 WebSocket 连接
  String? _url; // 连接地址

  bool _isConnecting = false; // 防止重复连接
  Timer? _reconnectTimer; // 重连定时器
  final Duration reconnectInterval = const Duration(seconds: 5); // 重连间隔
  final int maxReconnectAttempts = 10; // 最大重连次数
  int _reconnectAttempts = 0; // 当前重连次数

  /// 建立 WebSocket 连接
  void connect(String url) {
    _url = url;
    _createConnection();
  }

  /// 创建 WebSocket 连接，自动处理异常和重连
  void _createConnection() async {
    if (_isConnecting) return;
    _isConnecting = true;

    // 连接前关闭旧连接，防止资源泄漏
    await _socket?.close();
    _socket = null;

    try {
      _socket = await WebSocket.connect(_url!);
      _reconnectAttempts = 0;
      print('[WebSocket] Connected');

      // 成功连接后取消重连定时器
      _reconnectTimer?.cancel();

      // 通知监听者（如 UI）连接已建立
      notifyListeners();

      _socket!.listen(
        (msg) {
          // 只处理字符串消息
          if (msg is String) {
            WsMessageDispatcher.dispatchRaw(msg);
          }
        },
        onError: (e) {
          print('[WebSocket Error] $e');
          _scheduleReconnect();
        },
        onDone: () {
          print('[WebSocket Closed]');
          _scheduleReconnect();
        },
        cancelOnError: true, // 异常时自动关闭
      );
    } catch (e) {
      print('[WebSocket Connect Failed] $e');
      _scheduleReconnect();
    } finally {
      _isConnecting = false;
    }
  }

  /// 安排重连逻辑
  void _scheduleReconnect() {
    if (_reconnectAttempts >= maxReconnectAttempts) {
      print('[WebSocket] Max reconnect attempts reached.');
      return;
    }

    // 已有定时器且未到期则不重复设置
    if (_reconnectTimer != null && _reconnectTimer!.isActive) return;

    _reconnectAttempts++;
    print('[WebSocket] Attempting reconnect #$_reconnectAttempts');

    _reconnectTimer = Timer(reconnectInterval, () {
      _createConnection();
    });

    // 通知监听者（如 UI）进入重连状态
    notifyListeners();
  }

  /// 发送消息
  void send(String msg) {
    if (_socket?.readyState == WebSocket.open) {
      _socket!.add(msg);
    } else {
      print('[WebSocket] Not connected, message dropped');
    }
  }

  /// 释放资源
  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _socket?.close();
    _socket = null;
    super.dispose();
  }
}
