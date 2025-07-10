import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
// 假设你有一些主题相关的工具，比如 ThemeUtil
import 'package:notepad/common/utils/themeUtil.dart'; // 保持你现有的导入

// 可以在一个单独的文件中创建这个 WelcomePage，例如 views/common/welcome_page.dart
// 然后在 ChatDetail 中导入并使用它。

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 根据当前主题模式调整背景色和文字颜色
    final bool isDarkMode = ThemeUtil.isDarkMode(context);
    final Color textColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w), // 左右留白
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // 垂直居中
            crossAxisAlignment: CrossAxisAlignment.center, // 水平居中
            children: [
              // 顶部图标或插画
              HugeIcon(
                icon: HugeIcons.strokeRoundedChatting01,
                size: 60,
                color: Colors.indigo.withValues(alpha: 0.8),
              ),
              SizedBox(height: 30.h), // 间距
              // 欢迎标题
              Text(
                "欢迎来到你的专属聊天空间",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: 15.h), // 间距
              // 欢迎副标题/提示语
              Text(
                "与朋友们畅聊，分享生活中的精彩瞬间！\n选择一个聊天室,开始你的对话吧。",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: textColor.withValues(alpha: 0.7), // 副标题颜色稍微浅一些
                  height: 1.5, // 行高
                ),
              ),
            ],
          ),
        ),
      );
  }
}
