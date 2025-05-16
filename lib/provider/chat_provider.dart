import 'package:flutter/material.dart';
import '../core/ws_dispatcher.dart';
import '../models/ws_message.dart';

class ChatProvider with ChangeNotifier {
  final List<ChatMessage> messages = [];

  ChatProvider() {
    WsMessageDispatcher.listen<ChatMessage>('chat', _onMessage);
  }

  void _onMessage(ChatMessage msg) {
    messages.add(msg);
    notifyListeners();
  }

  @override
  void dispose() {
    WsMessageDispatcher.unlisten<ChatMessage>('chat', _onMessage);
    super.dispose();
  }
}
