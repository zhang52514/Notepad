import 'package:flutter/material.dart';
import 'package:notepad/Provider/WebSocketProvider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create:
          (_) => WebSocketProvider(url: 'ws://127.0.0.1:8081/chat')..connect(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  void initState() {
    super.initState();
    final ws = Provider.of<WebSocketProvider>(context, listen: false);
    ws.addMessageListener(_onWsMessage);
  }

  void _onWsMessage(String message) {
    print("收到：$message");
  }

  @override
  void dispose() {
    Provider.of<WebSocketProvider>(
      context,
      listen: false,
    ).removeMessageListener(_onWsMessage);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Consumer<WebSocketProvider>(
              builder: (context, wsProvider, _) {
                final status = wsProvider.status;
                return Column(
                  children: [
                    Text('当前状态: $status'),
                    ElevatedButton(
                      onPressed:
                          () => wsProvider.send(
                            '{"senderId":"flutter", "room":{"roomType":0}}',
                          ),
                      child: Text('发送消息'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
