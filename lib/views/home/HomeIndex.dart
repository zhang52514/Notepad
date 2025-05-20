
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class HomeIndex extends StatefulWidget {
  const HomeIndex({super.key});

  @override
  State<HomeIndex> createState() => _HomeIndexState();
}

class _HomeIndexState extends State<HomeIndex> {
  final QuillController _controller = QuillController.basic();

  @override
  Widget build(BuildContext context) {
    IconButtonData iconData = IconButtonData(
      color: Theme.of(context).primaryColor,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
    return Column(
      children: [
        Wrap(
          children: [
            ///撤销
            QuillToolbarHistoryButton(
              isUndo: true,
              options: const QuillToolbarHistoryButtonOptions(
                iconSize: 12,
                tooltip: '撤销',
              ),
              controller: _controller,
            ),
            QuillToolbarHistoryButton(
              isUndo: false,
              options: const QuillToolbarHistoryButtonOptions(
                tooltip: '重做',
                iconSize: 12,
              ),
              controller: _controller,
            ),
            QuillToolbarToggleStyleButton(
              options: QuillToolbarToggleStyleButtonOptions(
                tooltip: '加粗',
                iconSize: 12,
                iconTheme: QuillIconTheme(iconButtonSelectedData: iconData),
              ),
              controller: _controller,
              attribute: Attribute.bold,
            ),
            QuillToolbarToggleStyleButton(
              options: QuillToolbarToggleStyleButtonOptions(
                tooltip: '斜体',
                iconSize: 12,
                iconTheme: QuillIconTheme(iconButtonSelectedData: iconData),
              ),
              controller: _controller,
              attribute: Attribute.italic,
            ),
            QuillToolbarToggleStyleButton(
              options: QuillToolbarToggleStyleButtonOptions(
                tooltip: '下划线',
                iconSize: 12,
                iconTheme: QuillIconTheme(iconButtonSelectedData: iconData),
              ),
              controller: _controller,
              attribute: Attribute.underline,
            ),

            ///删除线
            QuillToolbarToggleStyleButton(
              options: QuillToolbarToggleStyleButtonOptions(
                tooltip: '删除线',
                iconSize: 12,
                iconTheme: QuillIconTheme(iconButtonSelectedData: iconData),
              ),
              controller: _controller,
              attribute: Attribute.strikeThrough,
            ),
   
            ///下标
            QuillToolbarToggleStyleButton(
              options: QuillToolbarToggleStyleButtonOptions(
                tooltip: '下标',
                iconSize: 12,
                iconTheme: QuillIconTheme(iconButtonSelectedData: iconData),
              ),
              controller: _controller,
              attribute: Attribute.subscript,
            ),

            ///上标
            QuillToolbarToggleStyleButton(
              options: QuillToolbarToggleStyleButtonOptions(
                tooltip: '上标',
                iconSize: 12,
                iconTheme: QuillIconTheme(iconButtonSelectedData: iconData),
              ),
              controller: _controller,
              attribute: Attribute.superscript,
            ),

            ///内联代码
            QuillToolbarToggleStyleButton(
              options: QuillToolbarToggleStyleButtonOptions(
                tooltip: '内联代码',
                iconSize: 12,
                iconTheme: QuillIconTheme(iconButtonSelectedData: iconData),
              ),
              controller: _controller,
              attribute: Attribute.inlineCode,
            ),
            QuillToolbarClearFormatButton(
              options: QuillToolbarClearFormatButtonOptions(
                tooltip: '清除格式',
                iconSize: 12,
                iconTheme: QuillIconTheme(iconButtonSelectedData: iconData),
              ),
              controller: _controller,
            ),
            Builder(
              builder: (context) {
                return QuillToolbarColorButton(
                  options: QuillToolbarColorButtonOptions(
                    tooltip: '文字颜色',
                    iconSize: 12,
                    iconTheme: QuillIconTheme(iconButtonSelectedData: iconData),
                    customOnPressedCallback: (ctl, isBg) async {
                    
                    
                    },
                  ),
                  controller: _controller,
                  isBackground: false,
                );
              },
            ),
            Builder(
              builder: (context) {
                return QuillToolbarColorButton(
                  options: QuillToolbarColorButtonOptions(
                    tooltip: '背景颜色',
                    iconSize: 12,
                    iconTheme: QuillIconTheme(iconButtonSelectedData: iconData),
                    customOnPressedCallback: (ctl, isBg) async {
                    
                    
                    },
                  ),
                  controller: _controller,
                  isBackground: true,
                );
              },
            ),
          
            ///对齐文本
            QuillToolbarToggleStyleButton(
              options: QuillToolbarToggleStyleButtonOptions(
                tooltip: '左对齐',
                iconSize: 12,
                iconTheme: QuillIconTheme(iconButtonSelectedData: iconData),
              ),
              controller: _controller,
              attribute: Attribute.leftAlignment,
            ),
            QuillToolbarToggleStyleButton(
              options: QuillToolbarToggleStyleButtonOptions(
                tooltip: '居中对齐',
                iconSize: 12,
                iconTheme: QuillIconTheme(iconButtonSelectedData: iconData),
              ),
              controller: _controller,
              attribute: Attribute.centerAlignment,
            ),
            QuillToolbarToggleStyleButton(
              options: QuillToolbarToggleStyleButtonOptions(
                tooltip: '右对齐',
                iconSize: 12,
                iconTheme: QuillIconTheme(iconButtonSelectedData: iconData),
              ),
              controller: _controller,
              attribute: Attribute.rightAlignment,
            ),
      
            QuillToolbarSelectHeaderStyleDropdownButton(
              options: QuillToolbarSelectHeaderStyleDropdownButtonOptions(
                tooltip: '标题样式',
                iconSize: 14,
                iconTheme: QuillIconTheme(iconButtonSelectedData: iconData),
                defaultDisplayText: "正文内容",
                attributes: const [
                  Attribute.h1,
                  Attribute.h2,
                  Attribute.h3,
                  Attribute.h4,
                  Attribute.h5,
                  Attribute.h6,
                  Attribute.header,
                ],
              ),
              controller: _controller,
            ),
            QuillToolbarSelectLineHeightStyleDropdownButton(
              options: QuillToolbarSelectLineHeightStyleDropdownButtonOptions(
                tooltip: '行高',
                iconSize: 14,
                iconTheme: QuillIconTheme(iconButtonSelectedData: iconData),
              ),
              controller: _controller,
            ),
            QuillToolbarToggleCheckListButton(
              options: QuillToolbarToggleCheckListButtonOptions(
                tooltip: '任务列表',
                iconSize: 12,
                iconTheme: QuillIconTheme(iconButtonSelectedData: iconData),
              ),
              controller: _controller,
            ),
            QuillToolbarToggleStyleButton(
              options: QuillToolbarToggleStyleButtonOptions(
                tooltip: '有序列表',
                iconSize: 12,
                iconTheme: QuillIconTheme(iconButtonSelectedData: iconData),
              ),
              controller: _controller,
              attribute: Attribute.ol,
            ),
            QuillToolbarToggleStyleButton(
              options: QuillToolbarToggleStyleButtonOptions(
                tooltip: '无序列表',
                iconSize: 12,
                iconTheme: QuillIconTheme(iconButtonSelectedData: iconData),
              ),
              controller: _controller,
              attribute: Attribute.ul,
            ),
            QuillToolbarToggleStyleButton(
              options: QuillToolbarToggleStyleButtonOptions(
                tooltip: '代码块',
                iconSize: 12,
                iconTheme: QuillIconTheme(iconButtonSelectedData: iconData),
              ),
              controller: _controller,
              attribute: Attribute.codeBlock,
            ),
            QuillToolbarToggleStyleButton(
              options: QuillToolbarToggleStyleButtonOptions(
                tooltip: '引用',
                iconSize: 12,
                iconTheme: QuillIconTheme(iconButtonSelectedData: iconData),
              ),
              controller: _controller,
              attribute: Attribute.blockQuote,
            ),
            QuillToolbarIndentButton(
              options: QuillToolbarIndentButtonOptions(
                tooltip: '增加缩进',
                iconSize: 12,
                iconTheme: QuillIconTheme(iconButtonSelectedData: iconData),
              ),
              controller: _controller,
              isIncrease: true,
            ),
            QuillToolbarIndentButton(
              options: QuillToolbarIndentButtonOptions(
                tooltip: '减少缩进',
                iconSize: 12,
                iconTheme: QuillIconTheme(iconButtonSelectedData: iconData),
              ),
              controller: _controller,
              isIncrease: false,
            ),
            QuillToolbarLinkStyleButton(
              options: QuillToolbarLinkStyleButtonOptions(
                tooltip: '插入链接',
                iconSize: 12,
                iconTheme: QuillIconTheme(iconButtonSelectedData: iconData),
              ),

              controller: _controller,
            ),
            QuillToolbarSearchButton(
              options: QuillToolbarSearchButtonOptions(
                tooltip: '搜索',
                iconSize: 12,
                iconTheme: QuillIconTheme(iconButtonSelectedData: iconData),
              ),
              controller: _controller,
            ),
          ],
        ),
        Expanded(
          child: FractionallySizedBox(
            widthFactor: 0.8,
            child: SizedBox(
              height: double.infinity,
              child: QuillEditor.basic(
                controller: _controller,
                config: QuillEditorConfig(
                  textSelectionThemeData: TextSelectionThemeData(
                    cursorColor: Theme.of(context).primaryColor,
                    selectionColor: Colors.grey.withValues(alpha: 0.5),
                  ),
                  placeholder: "Do you want to write something",
                  autoFocus: true,
                  padding: const EdgeInsets.all(10),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildColorsWidget(
    QuillController controller,
    Function? onCancel,
    bool isBackground,
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

    return Container(
      padding: const EdgeInsets.all(8),
      width: 246,
      height: 300,
      child: Column(
        children: [
          Material(
            child: ListTile(
              leading: const Icon(Icons.format_color_reset),
              title: const Text("重置"),
              onTap: () {
                _controller.formatSelection(
                  isBackground
                      ? const BackgroundAttribute(null)
                      : const ColorAttribute(null),
                );
                if (onCancel != null) {
                  onCancel();
                }
              },
              dense: true,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Wrap(
              spacing: 2, // 控制颜色块之间的水平间距
              runSpacing: 5, // 控制颜色块之间的垂直间距
              children:
                  colors.map((color) {
                    return MouseRegion(
                      cursor: SystemMouseCursors.click, // 鼠标悬浮变成小手
                      child: GestureDetector(
                        onTap: () {
                          if (isBackground) {}

                          var hex = colorToHex(color);
                          hex = '#$hex';
                          _controller.formatSelection(
                            isBackground
                                ? BackgroundAttribute(hex)
                                : ColorAttribute(hex),
                          );
                          if (onCancel != null) {
                            onCancel();
                          }
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Without the hash sign (`#`).
  String colorToHex(Color color) {
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

  @override
  void dispose() {
    super.dispose();
  }
}
