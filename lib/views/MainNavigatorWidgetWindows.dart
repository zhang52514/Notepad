import 'package:flutter/cupertino.dart';
import 'package:notepad/controller/MainController.dart';
import 'package:flutter/material.dart';
import 'package:notepad/views/main/Sidebar.dart';
import 'package:notepad/views/main/titleBar.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

/// 主窗口
/// 主要用于显示侧边栏和顶部菜单
class MainNavigatorWidgetWindows extends StatefulWidget {
  const MainNavigatorWidgetWindows({super.key});

  @override
  State<MainNavigatorWidgetWindows> createState() =>
      _MainNavigatorWidgetWindowsState();
}

class _MainNavigatorWidgetWindowsState extends State<MainNavigatorWidgetWindows>
    with WindowListener {
  @override
  void initState() {
    super.initState();
    //监听Window事件
    windowManager.addListener(this);
    //配置Window关闭按钮可拦截
    // windowManager.setPreventClose(true);
  }

  @override
  void onWindowMaximize() {
    super.onWindowMaximize();
    Provider.of<MainController>(context, listen: false).extendedValue = true;
  }

  @override
  void onWindowUnmaximize() {
    super.onWindowUnmaximize();
    Provider.of<MainController>(context, listen: false).extendedValue = false;
  }

  @override
  Widget build(BuildContext context) {
    var mainController = context.watch<MainController>();
    return Row(
      children: [
        // 侧边栏
        Sidebar(mainctl: mainController),
        // 主内容区域
        Expanded(
          child: Titlebar(title: "anoxia.cn", mainctl: mainController),
        )
      ],
    );
  }
}
