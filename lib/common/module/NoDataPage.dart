import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:notepad/common/utils/themeUtil.dart';

class NoDataPage extends StatelessWidget {
  final String? title;
  final String? subTitle;
  final String? buttonText;
  final IconData? iconData;
  final VoidCallback? onPressed;

  const NoDataPage({
    super.key,
    this.onPressed,
    this.title,
    this.subTitle,
    this.buttonText,
    this.iconData,
  }) : assert(
         !(onPressed != null && (buttonText == null || buttonText == "")),
         '当 onCreateNewChat 不为 null 时，buttonText 不能为空',
       );

  @override
  Widget build(BuildContext context) {
    // 根据当前主题模式调整背景色和文字颜色
    final bool isDarkMode = ThemeUtil.isDarkMode(context);
    final Color textColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 垂直居中
          crossAxisAlignment: CrossAxisAlignment.center, // 水平居中
          children: [
            // 顶部图标或插画
            HugeIcon(
              icon: iconData ?? HugeIcons.strokeRoundedMailOpen01,
              size: 60,
              color: Colors.indigo.withValues(alpha: 0.8),
            ),
            SizedBox(height: 25.h), // 间距
            // 提示标题
            Text(
              title ?? '暂无数据哦',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: 15.h), // 间距
            // 引导文本
            Text(
              subTitle ?? '请稍后再试！',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: textColor.withValues(alpha: 0.7),
                height: 1.4, // 行高
              ),
            ),
            SizedBox(height: 40.h), // 间距
            // 如果有创建新聊天的功能，可以添加一个按钮
            if (onPressed != null)
              FilledButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo, // 按钮背景色
                  padding: EdgeInsets.symmetric(
                    horizontal: 30.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.r), // 圆角按钮
                  ),
                  elevation: 3, // 增加一点阴影
                ),
                child: Text(
                  buttonText ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
