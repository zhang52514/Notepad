import 'package:flutter/material.dart';

class MineView extends StatefulWidget {
  const MineView({super.key});

  @override
  State<MineView> createState() => _MineViewState();
}

class _MineViewState extends State<MineView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Center(
      child: Text("MineView"),
    ),
    color: Colors.white,
    );  
    
  }
}