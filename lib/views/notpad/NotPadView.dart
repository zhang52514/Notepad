import 'package:flutter/material.dart';

class NotPadView extends StatefulWidget {
  const NotPadView({super.key});

  @override
  State<NotPadView> createState() => _NotPadViewState();
}

class _NotPadViewState extends State<NotPadView> {
  @override
  Widget build(BuildContext context) {
    return  const Center(
      child: Text("NotPadView"),
    );
  }
}