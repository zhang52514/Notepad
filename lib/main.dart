import 'package:flutter/material.dart';
import 'package:notepad/core/ws_dispatcher.dart';
import 'package:notepad/models/ws_message.dart';
import 'package:notepad/provider/chat_provider.dart';
import 'package:notepad/provider/websocket_provider.dart';
import 'package:provider/provider.dart';

void main() {
  // 注册模型
  WsMessageDispatcher.register<ChatMessage>(
    type: 'chat',
    parser: (json) => ChatMessage.fromJson(json),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create:
              (_) => WebSocketProvider()..connect('ws://127.0.0.1:8081/chat'),
        ),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: Text('WebSocket 聊天')),
          body: MyHomePage(title: 'Flutter Demo Home Page'),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(),
    );
  }
}
