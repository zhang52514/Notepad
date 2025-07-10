import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
// 移除 flutter_screenutil 库的引入

class AtBuilder implements EmbedBuilder {
  @override
  String get key => 'at';

  @override
  bool get expanded => false;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    // 解析嵌入数据
    final Map<String, dynamic> data;
    try {
      data = jsonDecode(embedContext.node.value.data);
    } catch (e) {
      // JSON 解析失败，返回一个提示错误的占位符
      return Text(
        '[无效@提及]',
        style: TextStyle(fontSize: 14.0, color: Colors.grey),
      );
    }

    final String id = data['id'] ?? '';
    final String name = data['name'] ?? '未知用户'; // 如果 name 为空，显示“未知用户”

    // 如果 id 或 name 缺失，返回一个更友好的占位符
    if (id.isEmpty) {
      return Text(
        '[无效@提及]',
        style: TextStyle(fontSize: 14.0, color: Colors.grey),
      );
    }
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          _showAtDetailsDialog(context, id, name);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
          margin: const EdgeInsets.symmetric(horizontal: 1.0),
          child: Text(
            "@$name",
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.red,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  // 新增的私有方法：显示 @ 提及详情对话框
  void _showAtDetailsDialog(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // 对话框圆角
          ),
          title: Text(
            '@$name',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min, // 内容高度自适应
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('用户ID: $id'),
              SizedBox(height: 10.0),
              // 您可以在这里添加更多用户详情，例如：
              // Text('角色: 管理员'),
              // Text('邮箱: example@example.com'),
              // 添加一个按钮，例如跳转到用户个人主页
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop(); // 关闭对话框
                  // TODO: 这里可以添加跳转到用户个人主页的逻辑
                  // Navigator.push(context, MaterialPageRoute(builder: (ctx) => UserProfilePage(userId: id)));
                  print('跳转到用户 $name (ID: $id) 的个人主页'); // 调试输出
                },
                icon: Icon(Icons.person),
                label: Text('查看个人主页'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
              },
              child: Text('关闭', style: TextStyle(color: Colors.grey[700])),
            ),
          ],
        );
      },
    );
  }

  @override
  WidgetSpan buildWidgetSpan(Widget widget) {
    return WidgetSpan(child: widget, alignment: PlaceholderAlignment.middle);
  }

  @override
  String toPlainText(Embed node) {
    final Map<String, dynamic> data;
    try {
      data = jsonDecode(node.value.data);
    } catch (e) {
      return '[无效@提及]';
    }
    final String id = data['id'] ?? '';
    final String name = data['name'] ?? '';
    return '@$name[at_id:$id]';
  }
}
