import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DeviceUtils {
  // 判断是否是 Web 平台
  static bool isWeb() => kIsWeb;

  // 判断是否是 Android 平台
  static bool isAndroid() => !kIsWeb && Platform.isAndroid;

  // 判断是否是 iOS 平台
  static bool isIOS() => !kIsWeb && Platform.isIOS;

  // 判断是否是 Windows 平台
  static bool isWindows() => !kIsWeb && Platform.isWindows;

  // 判断是否是 macOS 平台
  static bool isMacOS() => !kIsWeb && Platform.isMacOS;

  // 判断是否是 Linux 平台
  static bool isLinux() => !kIsWeb && Platform.isLinux;

  // 判断是否是移动端（iOS/Android）
  static bool isMobile() => isAndroid() || isIOS();

  // 判断是否是桌面端（Windows/macOS/Linux）
  static bool isDesktop() => isWindows() || isMacOS() || isLinux();

  // 判断是否为平板设备（基于屏幕宽度）
  static bool isTablet(BuildContext context) {
    final data = MediaQuery.of(context);
    return data.size.shortestSide >= 600;
  }

  // 判断是否为大屏幕（适用于 UI 适配）
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  // 判断是否为小屏幕（一般是手机）
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  // 判断是否为 Retina / 高像素密度屏幕
  static bool isHighResolution(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio > 2.0;
  }
}
