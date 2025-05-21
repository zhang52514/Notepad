import 'package:flutter/material.dart';
import 'package:notepad/common/utils/ThemeUtil.dart';
import 'package:notepad/controller/MainController.dart';

class Mainbody extends StatelessWidget {
  final MainController mainctl;
  const Mainbody({super.key, required this.mainctl});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: BoxDecoration(
          gradient:
              ThemeUtil.isDarkMode(context)
                  ? null
                  : LinearGradient(
                    begin: Alignment.topCenter, // 或者 Alignment.topLeft
                    end: Alignment.bottomCenter, // 或者 Alignment.bottomRight
                    colors: [
                      // Color(0xFFDEE4EA), // 浅蓝灰
                      // Color(0xFFC3CBD6), // 深一点的蓝灰
                      Color(0xFFE6E6E9), // 开始颜色 灰色
                      Color(0xFFEAE6DB), // 结束颜色 米色
                      // Color(0xFFFFF6E5), // 米白
                      // Color(0xFFE8C8A0), // 浅茶色
                      // Color(0xFFEDEDED), // 银白
                      // Color(0xFFD0CCDF), // 浅紫灰
                    ],
                  ),
        ),
        child: PageView(
          scrollDirection: Axis.vertical,
          // 禁止滑动
          controller: mainctl.pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: mainctl.views,
        ),
      ),
    );
  }
}
