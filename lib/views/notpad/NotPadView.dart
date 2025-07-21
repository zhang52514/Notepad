
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:notepad/controller/NotePadController.dart';
import 'package:notepad/views/notpad/LeftTreeView.dart';
import 'package:provider/provider.dart';

class NotPadView extends StatefulWidget {
  const NotPadView({super.key});

  @override
  State<NotPadView> createState() => _NotPadViewState();
}

class _NotPadViewState extends State<NotPadView> {
  @override
  Widget build(BuildContext context) {
    IconButtonData iconData = IconButtonData(
      color: Theme.of(context).primaryColor,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
    return Consumer<NotePadController>(
      builder: (context, NotePadController value, child) {
        return Row(
          children: [
            Container(width: 80.w, child: LeftTreeView()),
            Expanded(
              child: Column(
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
                        controller: value.controller,
                      ),
                      QuillToolbarHistoryButton(
                        isUndo: false,
                        options: const QuillToolbarHistoryButtonOptions(
                          tooltip: '重做',
                          iconSize: 12,
                        ),
                        controller: value.controller,
                      ),
                      QuillToolbarToggleStyleButton(
                        options: QuillToolbarToggleStyleButtonOptions(
                          tooltip: '加粗',
                          iconSize: 12,
                          iconTheme: QuillIconTheme(
                            iconButtonSelectedData: iconData,
                          ),
                        ),
                        controller: value.controller,
                        attribute: Attribute.bold,
                      ),
                      QuillToolbarToggleStyleButton(
                        options: QuillToolbarToggleStyleButtonOptions(
                          tooltip: '斜体',
                          iconSize: 12,
                          iconTheme: QuillIconTheme(
                            iconButtonSelectedData: iconData,
                          ),
                        ),
                        controller: value.controller,
                        attribute: Attribute.italic,
                      ),
                      QuillToolbarToggleStyleButton(
                        options: QuillToolbarToggleStyleButtonOptions(
                          tooltip: '下划线',
                          iconSize: 12,
                          iconTheme: QuillIconTheme(
                            iconButtonSelectedData: iconData,
                          ),
                        ),
                        controller: value.controller,
                        attribute: Attribute.underline,
                      ),

                      ///删除线
                      QuillToolbarToggleStyleButton(
                        options: QuillToolbarToggleStyleButtonOptions(
                          tooltip: '删除线',
                          iconSize: 12,
                          iconTheme: QuillIconTheme(
                            iconButtonSelectedData: iconData,
                          ),
                        ),
                        controller: value.controller,
                        attribute: Attribute.strikeThrough,
                      ),

                      ///下标
                      QuillToolbarToggleStyleButton(
                        options: QuillToolbarToggleStyleButtonOptions(
                          tooltip: '下标',
                          iconSize: 12,
                          iconTheme: QuillIconTheme(
                            iconButtonSelectedData: iconData,
                          ),
                        ),
                        controller: value.controller,
                        attribute: Attribute.subscript,
                      ),

                      ///上标
                      QuillToolbarToggleStyleButton(
                        options: QuillToolbarToggleStyleButtonOptions(
                          tooltip: '上标',
                          iconSize: 12,
                          iconTheme: QuillIconTheme(
                            iconButtonSelectedData: iconData,
                          ),
                        ),
                        controller: value.controller,
                        attribute: Attribute.superscript,
                      ),

                      ///内联代码
                      QuillToolbarToggleStyleButton(
                        options: QuillToolbarToggleStyleButtonOptions(
                          tooltip: '内联代码',
                          iconSize: 12,
                          iconTheme: QuillIconTheme(
                            iconButtonSelectedData: iconData,
                          ),
                        ),
                        controller: value.controller,
                        attribute: Attribute.inlineCode,
                      ),
                      QuillToolbarClearFormatButton(
                        options: QuillToolbarClearFormatButtonOptions(
                          tooltip: '清除格式',
                          iconSize: 12,
                          iconTheme: QuillIconTheme(
                            iconButtonSelectedData: iconData,
                          ),
                        ),
                        controller: value.controller,
                      ),
                      Builder(
                        builder: (context) {
                          return QuillToolbarColorButton(
                            options: QuillToolbarColorButtonOptions(
                              tooltip: '文字颜色',
                              iconSize: 12,
                              iconTheme: QuillIconTheme(
                                iconButtonSelectedData: iconData,
                              ),
                              customOnPressedCallback: (ctl, isBg) async {},
                            ),
                            controller: value.controller,
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
                              iconTheme: QuillIconTheme(
                                iconButtonSelectedData: iconData,
                              ),
                              customOnPressedCallback: (ctl, isBg) async {},
                            ),
                            controller: value.controller,
                            isBackground: true,
                          );
                        },
                      ),

                      ///对齐文本
                      QuillToolbarToggleStyleButton(
                        options: QuillToolbarToggleStyleButtonOptions(
                          tooltip: '左对齐',
                          iconSize: 12,
                          iconTheme: QuillIconTheme(
                            iconButtonSelectedData: iconData,
                          ),
                        ),
                        controller: value.controller,
                        attribute: Attribute.leftAlignment,
                      ),
                      QuillToolbarToggleStyleButton(
                        options: QuillToolbarToggleStyleButtonOptions(
                          tooltip: '居中对齐',
                          iconSize: 12,
                          iconTheme: QuillIconTheme(
                            iconButtonSelectedData: iconData,
                          ),
                        ),
                        controller: value.controller,
                        attribute: Attribute.centerAlignment,
                      ),
                      QuillToolbarToggleStyleButton(
                        options: QuillToolbarToggleStyleButtonOptions(
                          tooltip: '右对齐',
                          iconSize: 12,
                          iconTheme: QuillIconTheme(
                            iconButtonSelectedData: iconData,
                          ),
                        ),
                        controller: value.controller,
                        attribute: Attribute.rightAlignment,
                      ),

                      QuillToolbarSelectHeaderStyleDropdownButton(
                        options:
                            QuillToolbarSelectHeaderStyleDropdownButtonOptions(
                              tooltip: '标题样式',
                              iconSize: 14,
                              iconTheme: QuillIconTheme(
                                iconButtonSelectedData: iconData,
                              ),
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
                        controller: value.controller,
                      ),
                      QuillToolbarSelectLineHeightStyleDropdownButton(
                        options:
                            QuillToolbarSelectLineHeightStyleDropdownButtonOptions(
                              tooltip: '行高',
                              iconSize: 14,
                              iconTheme: QuillIconTheme(
                                iconButtonSelectedData: iconData,
                              ),
                            ),
                        controller: value.controller,
                      ),
                      QuillToolbarToggleCheckListButton(
                        options: QuillToolbarToggleCheckListButtonOptions(
                          tooltip: '任务列表',
                          iconSize: 12,
                          iconTheme: QuillIconTheme(
                            iconButtonSelectedData: iconData,
                          ),
                        ),
                        controller: value.controller,
                      ),
                      QuillToolbarToggleStyleButton(
                        options: QuillToolbarToggleStyleButtonOptions(
                          tooltip: '有序列表',
                          iconSize: 12,
                          iconTheme: QuillIconTheme(
                            iconButtonSelectedData: iconData,
                          ),
                        ),
                        controller: value.controller,
                        attribute: Attribute.ol,
                      ),
                      QuillToolbarToggleStyleButton(
                        options: QuillToolbarToggleStyleButtonOptions(
                          tooltip: '无序列表',
                          iconSize: 12,
                          iconTheme: QuillIconTheme(
                            iconButtonSelectedData: iconData,
                          ),
                        ),
                        controller: value.controller,
                        attribute: Attribute.ul,
                      ),
                      QuillToolbarToggleStyleButton(
                        options: QuillToolbarToggleStyleButtonOptions(
                          tooltip: '代码块',
                          iconSize: 12,
                          iconTheme: QuillIconTheme(
                            iconButtonSelectedData: iconData,
                          ),
                        ),
                        controller: value.controller,
                        attribute: Attribute.codeBlock,
                      ),
                      QuillToolbarToggleStyleButton(
                        options: QuillToolbarToggleStyleButtonOptions(
                          tooltip: '引用',
                          iconSize: 12,
                          iconTheme: QuillIconTheme(
                            iconButtonSelectedData: iconData,
                          ),
                        ),
                        controller: value.controller,
                        attribute: Attribute.blockQuote,
                      ),
                      QuillToolbarIndentButton(
                        options: QuillToolbarIndentButtonOptions(
                          tooltip: '增加缩进',
                          iconSize: 12,
                          iconTheme: QuillIconTheme(
                            iconButtonSelectedData: iconData,
                          ),
                        ),
                        controller: value.controller,
                        isIncrease: true,
                      ),
                      QuillToolbarIndentButton(
                        options: QuillToolbarIndentButtonOptions(
                          tooltip: '减少缩进',
                          iconSize: 12,
                          iconTheme: QuillIconTheme(
                            iconButtonSelectedData: iconData,
                          ),
                        ),
                        controller: value.controller,
                        isIncrease: false,
                      ),
                      QuillToolbarLinkStyleButton(
                        options: QuillToolbarLinkStyleButtonOptions(
                          tooltip: '插入链接',
                          iconSize: 12,
                          iconTheme: QuillIconTheme(
                            iconButtonSelectedData: iconData,
                          ),
                        ),

                        controller: value.controller,
                      ),
                      QuillToolbarSearchButton(
                        options: QuillToolbarSearchButtonOptions(
                          tooltip: '搜索',
                          iconSize: 12,
                          iconTheme: QuillIconTheme(
                            iconButtonSelectedData: iconData,
                          ),
                        ),
                        controller: value.controller,
                      ),
                    ],
                  ),
                  Expanded(
                    child: FractionallySizedBox(
                      widthFactor: 0.8,
                      child: SizedBox(
                        height: double.infinity,
                        child: QuillEditor.basic(
                          controller: value.controller,
                          config: QuillEditorConfig(
                            textSelectionThemeData: TextSelectionThemeData(
                              cursorColor: Theme.of(context).primaryColor,
                              selectionColor: Colors.grey.withValues(
                                alpha: 0.5,
                              ),
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
              ),
            ),
          ],
        );
      },
    );
  }
}
