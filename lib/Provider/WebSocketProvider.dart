import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

enum WebSocketStatus {
  connecting,
  connected,
  disconnected,
  error,
}

class WebSocketProvider extends ChangeNotifier {
  final String url;
  final Duration reconnectDelay;

  WebSocket? _socket;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;

  WebSocketStatus _status = WebSocketStatus.disconnected;
  WebSocketStatus get status => _status;

  final List<void Function(String message)> _listeners = [];

  WebSocketProvider({
    required this.url,
    this.reconnectDelay = const Duration(seconds: 5),
  });

  void connect() async {
    _setStatus(WebSocketStatus.connecting);
    try {
      _socket = await WebSocket.connect(url);
      _subscription = _socket!.listen(
        _onMessage,
        onDone: _onDisconnected,
        onError: _onError,
        cancelOnError: true,
      );
      _setStatus(WebSocketStatus.connected);
    } catch (e) {
      _onError(e);
    }
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _socket?.close();
    _socket = null;
    _setStatus(WebSocketStatus.disconnected);
  }

  void send(String message) {
    if (_socket != null && _status == WebSocketStatus.connected) {
      _socket!.add(message);
    }
  }

  void _onMessage(dynamic message) {
    if (message is String) {
      for (var listener in _listeners) {
        listener(message);
      }
    }
  }

  void _onDisconnected() {
    _setStatus(WebSocketStatus.disconnected);
    _scheduleReconnect();
  }

  void _onError(dynamic error) {
    _setStatus(WebSocketStatus.error);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(reconnectDelay, connect);
  }

  void _setStatus(WebSocketStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }

  void addMessageListener(void Function(String) listener) {
    _listeners.add(listener);
  }

  void removeMessageListener(void Function(String) listener) {
    _listeners.remove(listener);
  }

  @override
  void dispose() {
    disconnect();
    _listeners.clear();
    super.dispose();
  }
}
