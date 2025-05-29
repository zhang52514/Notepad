import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../common/utils/ThemeUtil.dart';

class MineView extends StatefulWidget {
  const MineView({super.key});

  @override
  State<MineView> createState() => _MineViewState();
}

class _MineViewState extends State<MineView> {

  final QuillController _controller = QuillController.basic();

  @override
  void initState() {
    super.initState();
    _controller.document=Document.fromJson(jsonDecode('[{"insert":{"image":"C:\\\\Users\\\\Administrator\\\\Downloads\\\\壁纸1.png"}},{"insert":"\\n"},{"insert":{"image":"C:\\\\Users\\\\Administrator\\\\Downloads\\\\壁纸3_compressed.png"}},{"insert":"\\n"},{"insert":{"at":"data2"}},{"insert":" yes\\n"}]'));
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 400, // 控制最大宽度
            maxHeight: 300, // 控制最大高度
          ),
          child: Container(
            color: Colors.amber,
            child: QuillEditor.basic(
              controller: QuillController.basic(),
              config: QuillEditorConfig(
                scrollable: true,
                placeholder: "输入消息",
                autoFocus: true,
                scrollBottomInset: 10,
                padding: const EdgeInsets.all(4),
                textSelectionThemeData: TextSelectionThemeData(
                  cursorColor: ThemeUtil.isDarkMode(context)
                      ? Colors.white
                      : Colors.indigo,
                  selectionColor: Colors.blue.withOpacity(0.5),
                ),
                customStyles: DefaultStyles(
                  paragraph: DefaultTextBlockStyle(
                    TextStyle(
                      fontSize: 14,
                      color: ThemeUtil.isDarkMode(context)
                          ? Colors.white
                          : Colors.black,
                    ),
                    HorizontalSpacing(0, 0),
                    VerticalSpacing(6, 0),
                    VerticalSpacing(6, 0),
                    null,
                  ),
                  placeHolder: DefaultTextBlockStyle(
                    TextStyle(fontSize: 14, color: Colors.grey),
                    HorizontalSpacing(0, 0),
                    VerticalSpacing(6, 0),
                    VerticalSpacing(6, 0),
                    null,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
