import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:notepad/common/domain/ChatUser.dart';
import 'package:notepad/controller/AuthController.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class AuthLogin extends StatefulWidget {
  const AuthLogin({super.key});

  @override
  State<AuthLogin> createState() => _AuthLoginState();
}

class _AuthLoginState extends State<AuthLogin> {
  @override
  Widget build(BuildContext context) {
   AuthController authLogin = context.watch<AuthController>();
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DragToMoveArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: "关闭",
                  padding: EdgeInsets.zero,
                  hoverColor: Colors.red,
                  onPressed: () {
                    windowManager.close();
                  },
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    foregroundColor: WidgetStateProperty.resolveWith((
                        states,
                        ) {
                      if (states.contains(WidgetState.hovered)) {
                        return Colors.white;
                      }
                      return null;
                    }),
                  ),
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedCancel01,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: Center(child: TextButton(onPressed: (){
            authLogin.login(ChatUser(uid: 'test-001', nickname: 'Milan', avatarUrl: 'https://c-ssl.duitang.com/uploads/blog/202107/17/20210717100716_31038.jpg'));
          }, child: Text("一键登录")))),
        ],
      ),
    );
  }
}
