import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
// 假设你有一些主题相关的工具，比如 ThemeUtil
import 'package:notepad/common/utils/themeUtil.dart'; // 保持你现有的导入

// 可以在一个单独的文件中创建这个 NoDataPage，例如 views/common/no_data_page.dart
// 然后在 ChatDetail 中导入并使用它。

class NoDataPage extends StatelessWidget {
  // 如果需要，可以传递一个回调函数，让页面可以触发某个动作
  final VoidCallback? onCreateNewChat;

  const NoDataPage({super.key, this.onCreateNewChat});

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
              icon: HugeIcons.strokeRoundedMailOpen01,
              size: 60,
              color: Colors.indigo.withValues(alpha: 0.8),
            ),
            SizedBox(height: 25.h), // 间距
            // 提示标题
            Text(
              "这里还没有消息哦",
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
              "快来发送第一条消息，开启新的对话吧！",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: textColor.withValues(alpha: 0.7),
                height: 1.4, // 行高
              ),
            ),
            SizedBox(height: 40.h), // 间距
            // 如果有创建新聊天的功能，可以添加一个按钮
            if (onCreateNewChat != null)
              ElevatedButton(
                onPressed: onCreateNewChat,
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
                  "发送第一条消息",
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

// 如何在你的 ChatDetail 中使用它：
// 在 ChatDetail 类的 build 方法中：
/*
@override
Widget build(BuildContext context) {
  // ... 其他代码 ...

  return () {
    // ... 获取 chatMessages 列表 ...
    List<ChatMessage> chatMessages = value.getMessagesForRoom();

    // 在构建 itemsWithSeparators 之前，判断原始消息列表是否为空
    if (chatMessages.isEmpty) {
      return const NoDataPage(); // 直接返回我们美观的暂无数据页
      // 如果你希望在“暂无数据”页面有一个点击事件，比如回到主页或者触发创建新聊天的逻辑
      // 可以这样传递回调：
      // return NoDataPage(
      //   onCreateNewChat: () {
      //     // 例如：Navigator.pop(context); // 返回上一页
      //     // 或者：value.createNewChat(); // 调用 ChatController 中的方法
      //     print("创建新聊天或发送消息被点击！");
      //   },
      // );
    }

    // --- 后续构建 itemsWithSeparators 的逻辑，只在 chatMessages 不为空时执行 ---
    List<dynamic> itemsWithSeparators = [];
    // ... 你的列表构建逻辑 ...

    return Scaffold(
      // ... 你的 Scaffold 内容 ...
      body: () {
        // 这里可以直接返回 ScrollablePositionedList.builder
        // 因为在上面已经对 chatMessages.isEmpty 做了判断并返回了 NoDataPage
        // 所以当代码执行到这里时，itemsWithSeparators 肯定不为空了。
        return ScrollablePositionedList.builder(
          // ... List 的属性 ...
        );
      }(),
      // ... 其他部分 ...
    );
  }();
}
*/
