import 'dart:async';
import 'dart:convert';

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
  final int _maxRetries = 10;
  final Duration _reconnectDelay = const Duration(seconds: 5);

  void initialize({required String url}) {
    _url = url;
    connect();
  }

  void connect() {
    if (_status == WebSocketConnectionStatus.connecting ||
        _status == WebSocketConnectionStatus.connected)
      return;

    _setStatus(WebSocketConnectionStatus.connecting);

    try {
      _channel = WebSocketChannel.connect(Uri.parse(_url));
      _channel!.stream.listen(
        _onData,
        onDone: _onDisconnected,
        onError: _onError,
        cancelOnError: true,
      );
      _retryCount = 0;
      _setStatus(WebSocketConnectionStatus.connected);
      _flushPendingMessages();
      _log("WebSocket connected.");
    } catch (e) {
      _onError(e);
    }
  }

  void send(Map<String, dynamic> message) {
    if (_status == WebSocketConnectionStatus.connected) {
      _channel?.sink.add(json.encode(message));
      print("send:${json.encode(message)}");
    } else {
      _pendingMessages.add(message);
      _log(
        "Send failed: WebSocket not connected. Message queued: ${json.encode(message)}",
      );
    }
  }

  void _flushPendingMessages() {
    for (var msg in _pendingMessages) {
      _channel?.sink.add(json.encode(msg));
    }
    _pendingMessages.clear();
  }

  void _onData(dynamic data) {
    print("新消息：$data");
    try {
      final decoded = json.decode(data);
      final message = WebSocketMessage.fromJson(decoded);
      _notifyListeners(message);
    } catch (e) {
      _log("Data parse error: $e");
    }
  }

  void _onDisconnected() {
    _setStatus(WebSocketConnectionStatus.disconnected);
    _log("WebSocket disconnected.");
    _scheduleReconnect();
  }

  void _onError(dynamic error) {
    _setStatus(WebSocketConnectionStatus.error);
    _log("WebSocket error: $error");
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_retryCount >= _maxRetries) {
      _log("Max retries reached. Giving up reconnecting.");
      return;
    }
    _retryCount++;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, connect);
    _log("Scheduled reconnect (#$_retryCount) in $_reconnectDelay.");
  }

  void _notifyListeners(WebSocketMessage message) {
    for (var listener in _listeners) {
      try {
        listener(message);
      } catch (e) {
        _log("Listener error: $e");
      }
    }
  }

  void addListener(WebSocketListener listener) {
    _listeners.add(listener);
  }

  void addStatusListener(void Function(WebSocketConnectionStatus) listener) {
    _statusListeners.add(listener);
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
    _log("WebSocketService disposed.");
  }

  void _setStatus(WebSocketConnectionStatus newStatus) {
    _status = newStatus;
    for (var listener in _statusListeners) {
      try {
        listener(newStatus);
      } catch (e) {
        _log("StatusListener error: $e");
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
