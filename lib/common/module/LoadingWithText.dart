import 'package:flutter/material.dart';

class LoadingWithText extends StatelessWidget {
  final String text;
  final double size;
  final Color color;

  const LoadingWithText({
    super.key,
    this.text="正在加载中...",
    this.size = 25.0,
    this.color = Colors.indigo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // 让 Column 尽量紧凑
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(color: color),
        ),
        SizedBox(height: 8.0), // 添加一些垂直间距
        Text(text,style: TextStyle(fontSize: 12)),
      ],
    );
  }
}