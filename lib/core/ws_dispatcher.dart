import 'dart:convert';
import '../models/ws_message.dart';

typedef WsMessageCallback<T extends WsMessage> = void Function(T message);

class WsMessageDispatcher {
  static final Map<String, WsMessage Function(Map<String, dynamic>)> _parsers = {};
  static final Map<String, List<WsMessageCallback>> _listeners = {};

  static void register<T extends WsMessage>({
    required String type,
    required WsMessage Function(Map<String, dynamic>) parser,
  }) {
    _parsers[type] = parser;
    _listeners[type] = [];
  }

  static void listen<T extends WsMessage>(String type, WsMessageCallback<T> callback) {
    _listeners[type]?.add(callback as WsMessageCallback);
  }

  static void unlisten<T extends WsMessage>(String type, WsMessageCallback<T> callback) {
    _listeners[type]?.remove(callback);
  }

  static void dispatchRaw(String raw) {
    try {
      final Map<String, dynamic> json = jsonDecode(raw);
      final type = json['type'] as String?;

      if (type != null && _parsers.containsKey(type)) {
        final parser = _parsers[type]!;
        final message = parser(json);
        for (final callback in _listeners[type]!) {
          callback(message);
        }
      }
    } catch (e) {
      print('[Dispatcher] Invalid message: $e');
    }
  }
}
