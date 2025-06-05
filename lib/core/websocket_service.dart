import 'dart:async';
import 'dart:convert';

import 'package:notepad/common/module/AnoToast.dart';
import 'package:web_socket_channel/status.dart' as status_;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'WebSocketMessage.dart';

typedef WebSocketListener = void Function(WebSocketMessage message);

enum WebSocketConnectionStatus { disconnected, connecting, connected, error }

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();

  factory WebSocketService() => _instance;

  WebSocketService._internal();

  late String _url;
  WebSocketChannel? _channel;
  WebSocketConnectionStatus _status = WebSocketConnectionStatus.disconnected;

  WebSocketConnectionStatus get status => _status;

  final Set<WebSocketListener> _listeners = {};
  final List<Map<String, dynamic>> _pendingMessages = [];
  final List<void Function(WebSocketConnectionStatus)> _statusListeners = [];

  Timer? _reconnectTimer;
  int _retryCount = 0;
  final int _maxRetries = 5;
  final Duration _reconnectDelay = const Duration(seconds: 5);

  void initialize({required String url}) {
    _url = url;
    connect();
  }

  ///链接
  void connect() {
    if (_status == WebSocketConnectionStatus.connecting ||
        _status == WebSocketConnectionStatus.connected) {
      return;
    }

    _setStatus(WebSocketConnectionStatus.connecting);

    try {
      _channel = WebSocketChannel.connect(Uri.parse(_url));
      bool hasConnected = false;

      _channel!.stream.listen(
        (data) {
          if (!hasConnected) {
            hasConnected = true;
            _setStatus(WebSocketConnectionStatus.connected);
            _log("WebSocket 已连接.$_status");
            _flushPendingMessages();
          }
          _onData(data);
        },
        onDone: _onDisconnected,
        onError: _onError,
        cancelOnError: true,
      );
      _setStatus(WebSocketConnectionStatus.connected);
      _log("WebSocket 已连接.$_status");
      _flushPendingMessages();
    } catch (e) {
      _onError(e);
    }
  }

  ///登录
  void auth(String name, String pwd) {
    send({"cmd": "auth", "userName": name, "userPwd": pwd});
  }
  ///Http
  void http(String path, String token, Map<String, dynamic> param) {
    send({"cmd": "http", "path": path, "token": token, "param": param});
  }

  ///发送消息
  void send(Map<String, dynamic> message) {
    if (_status == WebSocketConnectionStatus.connected) {
      _channel?.sink.add(json.encode(message));
      print("向服务器发送消息:${json.encode(message)}");
    } else {
      _pendingMessages.add(message);
      _log("向服务器发送消息失败了: ${json.encode(message)}");
    }
  }

  ///消息队列
  void _flushPendingMessages() {
    for (var msg in _pendingMessages) {
      _channel?.sink.add(json.encode(msg));
    }
    _pendingMessages.clear();
  }

  void _onData(dynamic data) {
    _log("客户端收到新消息：$data");
    try {
      final decoded = json.decode(data);
      final message = WebSocketMessage.fromJson(decoded);
      _notifyListeners(message);
    } catch (e) {
      _log("数据解析错误: $e-->$data");
    }
  }

  void _onDisconnected() {
    if (_status != WebSocketConnectionStatus.disconnected) {
      _setStatus(WebSocketConnectionStatus.disconnected);
      _log("WebSocket 已断开连接.");
      _scheduleReconnect();
    }
  }

  void _onError(dynamic error) {
    _setStatus(WebSocketConnectionStatus.error);
    _log("链接出现异常: $error");
    _scheduleReconnect();
  }

  ///链接重试
  void _scheduleReconnect() {
    String msg = "";
    if (_retryCount >= _maxRetries) {
      msg = "已达到最大重试次数。放弃连接。";
      AnoToast.showToast(msg, type: ToastType.error);
      _log(msg);
      return;
    }
    _retryCount++;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, connect);
    msg = "尝试第( $_retryCount )次重新连接 $_reconnectDelay.";
    _log(msg);
    AnoToast.showToast(msg, type: ToastType.error);
  }

  void _notifyListeners(WebSocketMessage message) {
    final listenersCopy = [..._listeners];
    for (var listener in listenersCopy) {
      try {
        listener(message);
      } catch (e) {
        _log("订阅异常: $e");
      }
    }
  }

  void addListener(WebSocketListener listener) {
    _listeners.add(listener);
  }

  void addStatusListener(void Function(WebSocketConnectionStatus) listener) {
    _statusListeners.add(listener);
    listener(status);
  }

  void removeListener(WebSocketListener listener) {
    _listeners.remove(listener);
  }

  void dispose() {
    if (_status == WebSocketConnectionStatus.connected) {
      _channel?.sink.close(status_.goingAway);
    }
    _reconnectTimer?.cancel();
    _listeners.clear();

    _setStatus(WebSocketConnectionStatus.disconnected);
    _log("服务器主动断开链接.");
  }

  void _setStatus(WebSocketConnectionStatus newStatus) {
    if (_status == newStatus) return;
    _status = newStatus;
    for (var listener in _statusListeners) {
      try {
        listener(newStatus);
      } catch (e) {
        _log("状态订阅异常: $e");
      }
    }
  }

  void _log(String message) {
    if (true) {
      // 可切换为 debug 模式
      print("[WebSocketService] $message");
    }
  }
}
