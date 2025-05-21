import 'package:flutter/material.dart';

class Chatdeatil extends StatefulWidget {
  const Chatdeatil({super.key});

  @override
  State<Chatdeatil> createState() => _ChatdeatilState();
}

class _ChatdeatilState extends State<Chatdeatil> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("我是标题"),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.add))],
      ),
      body: Center(child: Text("data")),
      bottomNavigationBar: Container(
        child: Text("bottom"),
        color: Colors.indigo,
      ),
    );
  }
}
