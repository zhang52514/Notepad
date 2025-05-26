import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FileBuilder implements EmbedBuilder {
  @override
  String get key => 'file';

  @override
  bool get expanded => false;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final String fileUrl = embedContext.node.value.data;
    final String fileName = fileUrl.split(RegExp(r'[\\/]+')).last;
    return ConstrainedBox(
      constraints:  BoxConstraints(
        maxHeight: 60,
      ),
      child: Row(children: [
        Icon(Icons.attach_file),
        Text(fileName),
      ],),
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
