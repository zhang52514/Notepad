import 'package:flutter/material.dart';

class ThemeUtil {
  /// 获取当前是否为深色模式
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// 获取当前主题亮度（Brightness.light / dark）
  static Brightness getTheme(BuildContext context) {
    return Theme.of(context).brightness;
  }

  /// 获取主题主色
  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  /// 获取背景颜色（一般用于 Scaffold）
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.background;
  }

  /// 获取卡片颜色
  static Color getCardColor(BuildContext context) {
    return Theme.of(context).cardColor;
  }

  /// 获取文本颜色（通常为默认正文）
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
  }

  /// 判断是否使用 AMOLED 黑（纯黑主题）
  static bool isPureBlackDarkTheme(BuildContext context) {
    final background = getBackgroundColor(context);
    return isDarkMode(context) && background == Colors.black;
  }

  /// 判断是否启用高对比度模式（无障碍场景）
  static bool isHighContrast(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  /// 获取当前文字缩放倍数
  static double getTextScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor;
  }

  /// 获取当前 Material 设计版本（Material3？）
  static bool isMaterial3(BuildContext context) {
    return Theme.of(context).useMaterial3;
  }

  /// 获取 AppBar 的背景色（根据当前主题）
  static Color getAppBarColor(BuildContext context) {
    return Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;
  }
}
