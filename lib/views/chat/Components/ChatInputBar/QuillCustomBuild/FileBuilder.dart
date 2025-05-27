import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';

class FileBuilder implements EmbedBuilder {
  final QuillController controller;

  FileBuilder(this.controller);

  @override
  String get key => 'file';

  @override
  bool get expanded => false;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final String fileUrl = embedContext.node.value.data;
    final String fileName = fileUrl.split(RegExp(r'[\\/]+')).last;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 60),
      child: Container(
        width: 150.w,
        height: 50.h,
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.indigo),
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        child: ListTile(
          dense: true,
          leading: HugeIcon(icon: HugeIcons.strokeRoundedFile01),
          title: Text(
            fileName,
            style: TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          trailing: IconButton(
            tooltip: "删除",
            onPressed:
                () => {
                  controller.replaceText(embedContext.node.offset, 1, '', null),
                },
            icon: HugeIcon(icon: HugeIcons.strokeRoundedDelete01, size: 12),
          ),
        ),
      ),
    );
  }

  @override
  WidgetSpan buildWidgetSpan(Widget widget) {
    return WidgetSpan(child: widget, alignment: PlaceholderAlignment.middle);
  }

  @override
  String toPlainText(Embed node) {
    final String url = node.value.data;
    return '[file:$url]';
  }
}
