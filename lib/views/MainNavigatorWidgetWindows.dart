import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:notepad/common/module/SingleCloseView.dart';
import 'package:notepad/controller/AuthController.dart';
import 'package:notepad/controller/MainController.dart';
import 'package:notepad/views/main/Sidebar.dart';
import 'package:notepad/views/main/titleBar.dart';
import 'package:provider/provider.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../core/websocket_service.dart';
import 'auth/AuthLogin.dart';

/// 主窗口
/// 主要用于显示侧边栏和顶部菜单
class MainNavigatorWidgetWindows extends StatefulWidget {
  const MainNavigatorWidgetWindows({super.key});

  @override
  State<MainNavigatorWidgetWindows> createState() =>
      _MainNavigatorWidgetWindowsState();
}

class _MainNavigatorWidgetWindowsState extends State<MainNavigatorWidgetWindows>
    with WindowListener, TrayListener {
  @override
  void initState() {
    super.initState();
    _initTray();
    trayManager.addListener(this);
    //监听Window事件
    windowManager.addListener(this);
    //配置Window关闭按钮可拦截
    // windowManager.setPreventClose(true);
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    super.dispose();
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
  void onTrayIconMouseDown() {
    // 当托盘图标被点击时，显示窗口
    windowManager.show();
    windowManager.focus();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
    // 当托盘图标右键被点击时，弹出菜单
  }

  @override
  void onTrayIconRightMouseUp() {
    // do something
    // 当托盘图标右键被释放时，可以执行其他操作
    print("当托盘图标右键被释放时，可以执行其他操作");
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    print('菜单项点击: ${menuItem.key}');
    if (menuItem.key == 'show_window') {
      windowManager.show();
      windowManager.focus();
    } else if (menuItem.key == 'hide_window') {
      windowManager.hide();
    } else if (menuItem.key == 'exit_app') {
      windowManager.close();
    }
  }

  Future<void> _initTray() async {
    await trayManager.setIcon('assets/favicon.ico');

    List<MenuItem> items = [
      MenuItem(key: 'show_window', label: '显示窗口'),
      MenuItem(key: 'hide_window', label: '隐藏窗口'),
      MenuItem.separator(),
      MenuItem(key: 'exit_app', label: '退出'),
    ];

    await trayManager.setContextMenu(Menu(items: items));
  }

  @override
  Widget build(BuildContext context) {
    var mainController = context.watch<MainController>();
    var authController = context.watch<AuthController>();
    if (authController.networkResult == ConnectivityResult.none) {
      return SingleCloseView(child: Center(child: Text("网络异常，请检查网络连接！")));
    }

    if (authController.webSocketResult != WebSocketConnectionStatus.connected) {
      return SingleCloseView(
        child: Center(child: Text(authController.webSocketStatus)),
      );
    }

    if (authController.isLoading) {
      return SingleCloseView(child: Center(child: Text("登录中...")));
    }

    if (authController.currentUser == null) {
      return const AuthLogin();
    }

    return Row(
      children: [
        // 侧边栏
        Sidebar(mainctl: mainController),
        // 主内容区域
        Expanded(
          child: TitleBar(
            title: authController.networkStatus,
            mainCtl: mainController,
          ),
        ),
      ],
    );
  }
}
