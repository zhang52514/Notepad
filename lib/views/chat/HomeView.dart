import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:notepad/common/utils/themeUtil.dart';
import 'package:notepad/controller/ChatController.dart';
import 'package:notepad/views/chat/ChatDetail.dart';
import 'package:notepad/views/chat/ChatList.dart';
import 'package:provider/provider.dart';

class Homeview extends StatefulWidget {
  const Homeview({super.key});

  @override
  State<Homeview> createState() => _HomeviewState();
}

class _HomeviewState extends State<Homeview> {
  @override
  Widget build(BuildContext context) {
    Color? color =
        ThemeUtil.isDarkMode(context) ? Color(0xFF292929) : Colors.white;
    return Consumer<ChatController>(
      builder:
          (context, ChatController value, child) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 95.w,
                height: double.infinity,
                child: Chatlist(value: value),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(2),
                  child: Card(
                    color: color,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: ChatDetail(),
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
