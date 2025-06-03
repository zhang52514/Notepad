import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:notepad/common/module/SingleCloseView.dart';
import 'package:notepad/controller/AuthController.dart';
import 'package:notepad/controller/MainController.dart';
import 'package:notepad/views/main/Sidebar.dart';
import 'package:notepad/views/main/titleBar.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

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
    with WindowListener {
  late StreamSubscription<List<ConnectivityResult>> subscription;
  ConnectivityResult networkResult = ConnectivityResult.none;
  String networkStatus = "网络检测中...";

  Future<void> _initAsync() async {
    await context.read<AuthController>().init();
  }

  @override
  void initState() {
    super.initState();
    //监听Window事件
    windowManager.addListener(this);
    //配置Window关闭按钮可拦截
    // windowManager.setPreventClose(true);

    _initAsync();
    subscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      setState(() {
        switch (result.first) {
          case ConnectivityResult.wifi:
            networkStatus = "Wi-Fi";
            networkResult = ConnectivityResult.wifi;
            break;
          case ConnectivityResult.mobile:
            networkStatus = "移动网络";
            networkResult = ConnectivityResult.mobile;
            break;
          case ConnectivityResult.ethernet:
            networkStatus = "有线网络";
            networkResult = ConnectivityResult.ethernet;
            break;
          case ConnectivityResult.vpn:
            networkStatus = "VPN";
            networkResult = ConnectivityResult.vpn;
            break;
          case ConnectivityResult.other:
            networkStatus = "其他网络";
            networkResult = ConnectivityResult.other;
            break;
          case ConnectivityResult.none:
            networkStatus = "无网络";
            networkResult = ConnectivityResult.none;
            break;
          case ConnectivityResult.bluetooth:
            networkStatus = "蓝牙";
            networkResult = ConnectivityResult.bluetooth;
            break;
        }
      });
    });
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
  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (networkResult == ConnectivityResult.none) {
      return SingleCloseView(child: Center(child: Text("网络异常，请检查网络连接！")));
    }

    var mainController = context.watch<MainController>();
    var authController = context.watch<AuthController>();

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
          child: TitleBar(title: networkStatus, mainCtl: mainController),
        ),
      ],
    );
  }
}
