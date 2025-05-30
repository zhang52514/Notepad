import 'package:flutter/material.dart';

class ColorsBox {
  static Widget buildColorsWidget(
    Function? onTap,
    Color? color,
  ) {
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
      elevation: 4,
      color: color,
      child: SizedBox(
        width: 240,
        height: 200,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Wrap(
            spacing: 2, // 控制颜色块之间的水平间距
            runSpacing: 5, // 控制颜色块之间的垂直间距
            children:
                colors.map((color) {
                  return MouseRegion(
                    cursor: SystemMouseCursors.click, // 鼠标悬浮变成小手
                    child: GestureDetector(
                      onTap: () {
                        var hex = colorToHex(color);
                        hex = '#$hex';
                        if (onTap != null) {
                          onTap(hex);
                        }
                      },
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  );
                }).toList(),
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
