import 'package:flutter/material.dart';
import 'package:notepad/common/utils/ThemeUtil.dart';

class ColorsBox {
  static Widget buildColorsWidget(Function? onTap, BuildContext context) {
    final List<Color> colors = [
      // 第一行
      Colors.black,
      Colors.grey[900]!,
      Colors.grey[800]!,
      Colors.grey[700]!,
      Colors.grey[600]!,
      Colors.grey[400]!,
      Colors.grey[300]!,
      Colors.grey[200]!,
      Colors.grey[100]!,
      Colors.white,

      // 第二行
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.cyan,
      Colors.lightBlue,
      Colors.blue,
      Colors.purple,
      Colors.purpleAccent,
      Colors.blueGrey,

      // 第三行
      Colors.red[100]!,
      Colors.orange[100]!,
      Colors.yellow[100]!,
      Colors.green[100]!,
      Colors.cyan[100]!,
      Colors.lightBlue[100]!,
      Colors.blue[100]!,
      Colors.purple[100]!,
      Colors.purpleAccent[100]!,
      Colors.blueGrey[100]!,

      // 第四行
      Colors.red[300]!,
      Colors.orange[300]!,
      Colors.yellow[300]!,
      Colors.green[300]!,
      Colors.cyan[300]!,
      Colors.lightBlue[300]!,
      Colors.blue[300]!,
      Colors.purple[300]!,
      Colors.purpleAccent[200]!,
      Colors.blueGrey[300]!,

      // 第五行
      Colors.red[500]!,
      Colors.orange[500]!,
      Colors.yellow[500]!,
      Colors.green[500]!,
      Colors.cyan[500]!,
      Colors.lightBlue[500]!,
      Colors.blue[500]!,
      Colors.purple[500]!,
      Colors.purpleAccent[400]!,
      Colors.blueGrey[500]!,

      // 第六行
      Colors.red[700]!,
      Colors.orange[700]!,
      Colors.yellow[700]!,
      Colors.green[700]!,
      Colors.cyan[700]!,
      Colors.lightBlue[700]!,
      Colors.blue[700]!,
      Colors.purple[700]!,
      Colors.purpleAccent[700]!,
      Colors.blueGrey[700]!,

      // 第七行
      Colors.red[900]!,
      Colors.orange[900]!,
      Colors.yellow[900]!,
      Colors.green[900]!,
      Colors.cyan[900]!,
      Colors.lightBlue[900]!,
      Colors.blue[900]!,
      Colors.purple[900]!,
      Colors.purpleAccent[700]!,
      Colors.blueGrey[800]!,
    ];
    return Material(
      type: MaterialType.card,
      borderRadius: BorderRadius.circular(12),
      elevation: 6,
      color:
          ThemeUtil.isDarkMode(context) ? Colors.grey.shade800 : Colors.white,
      child: SizedBox(
        width: 280,
        height: 250,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // 重置颜色按钮
              GestureDetector(
                onTap: () {
                  if (onTap != null) {
                    onTap(null);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '重置',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 10, // 每行10个颜色，与你的原始数据一致
                    crossAxisSpacing: 8, // 水平间距
                    mainAxisSpacing: 8, // 垂直间距
                  ),
                  itemCount: colors.length,
                  itemBuilder: (BuildContext context, int index) {
                    return MouseRegion(
                      cursor: SystemMouseCursors.click, // 鼠标悬浮变成小手
                      child: GestureDetector(
                        onTap: () {
                          var hex = colorToHex(colors[index]);
                          hex = '#$hex';
                          if (onTap != null) {
                            onTap(hex);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: colors[index],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  ThemeUtil.isDarkMode(context)
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Without the hash sign (`#`).
  static String colorToHex(Color color) {
    int floatToInt8(double x) => (x * 255.0).round() & 0xff;

    final alpha = floatToInt8(color.a);
    final red = floatToInt8(color.r);
    final green = floatToInt8(color.g);
    final blue = floatToInt8(color.b);

    return '${alpha.toRadixString(16).padLeft(2, '0')}'
            '${red.toRadixString(16).padLeft(2, '0')}'
            '${green.toRadixString(16).padLeft(2, '0')}'
            '${blue.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }
}
