import 'package:flutter/material.dart';
import 'package:notepad/common/utils/ThemeUtil.dart';
import 'package:notepad/controller/MainController.dart';

class Mainbody extends StatelessWidget {
  final MainController mainctl;
  const Mainbody({super.key, required this.mainctl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient:
            ThemeUtil.isDarkMode(context)
                ? null
                : LinearGradient(
                  begin: Alignment.topCenter, // 或者 Alignment.topLeft
                  end: Alignment.bottomCenter, // 或者 Alignment.bottomRight
                  colors: [
                    Color(0xFFE6E6E9), // 开始颜色
                    Color(0xFFEAE6DB), // 结束颜色
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
    );
  }
}
