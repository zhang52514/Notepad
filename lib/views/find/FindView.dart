import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:notepad/views/chat/Components/VideoCall/VideoCallPage.dart';

class FindView extends StatefulWidget {
  const FindView({super.key});

  @override
  State<FindView> createState() => _FindViewState();
}

class _FindViewState extends State<FindView> {


  @override
  Widget build(BuildContext context) {
    return VideoCallPage(isCaller: true, callTargetId: 'target_user_id');
  }
}
