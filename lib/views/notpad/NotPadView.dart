import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:notepad/controller/NotePadController.dart';
import 'package:notepad/views/notpad/LeftTreeView.dart';
import 'package:notepad/views/notpad/QuillToolbarWidget.dart';
import 'package:provider/provider.dart';
import 'package:split_view/split_view.dart';

class NotPadView extends StatefulWidget {
  const NotPadView({super.key});

  @override
  State<NotPadView> createState() => _NotPadViewState();
}

class _NotPadViewState extends State<NotPadView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<NotePadController>(
      builder: (context, NotePadController value, child) {
        return SplitView(
          viewMode: SplitViewMode.Horizontal,
          gripColor: Colors.grey,
          gripColorActive: Colors.blueGrey,
          gripSize: 1,
          controller: SplitViewController(
            weights: [0.2, 0.8],
            limits: [WeightLimit(min: 0.2), WeightLimit(min: 0.4)],
          ),
          children: [
            // 左侧面板：文件树
            LeftTreeView(),
            Column(
              children: [
                Row(
                  children: [
                    SizedBox(width: 4.w,),
                    Text(
                      "Title Notepad",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Divider(),
                MyQuillToolbar(controller: value.controller),
                Divider(),
                SizedBox(height: 10.h),
                Expanded(
                  child: FractionallySizedBox(
                    child: SizedBox(
                      height: double.infinity,
                      child: QuillEditor.basic(
                        controller: value.controller,
                        config: QuillEditorConfig(
                          textSelectionThemeData: TextSelectionThemeData(
                            cursorColor: Colors.indigo,
                            selectionColor: Colors.grey.withValues(alpha: 0.5),
                          ),
                          placeholder: "记录每一刻灵感",
                          autoFocus: true,
                          padding: const EdgeInsets.all(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
