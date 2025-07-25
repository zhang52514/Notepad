import 'package:flutter/material.dart';
import 'package:notepad/main.dart';

class DialogUtil {
  static void showGlobalDialog(Widget child) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(context: context, builder: (_) => child);
      });
    } else {
      debugPrint("⚠️ DialogUtil.showGlobalDialog: context 不可用");
    }
  }
}
