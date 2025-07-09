import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';

class FileBuilder implements EmbedBuilder {
  final QuillController? controller;

  FileBuilder({this.controller});

  @override
  String get key => 'file';

  @override
  bool get expanded => false;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    
    final Map<String, dynamic> data = jsonDecode(embedContext.node.value.data);
    final String fileUrl = data['url'] ?? '';
    if (fileUrl.isEmpty) {
      return SizedBox.shrink();
    }
    final String fileName = fileUrl.split(RegExp(r'[\\/]+')).last;
    final color= controller==null?Colors.white:Colors.grey;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 60),
      child: Container(
        width: 80.w,
        height: 50.h,
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: color),
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        child: ListTile(

          dense: true,
          leading: HugeIcon(icon: HugeIcons.strokeRoundedFile01,size: 16,color:color,),
          title: Text(
            fileName,
            style: TextStyle(fontSize: 13,color: color),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          trailing:
              controller == null
                  ? IconButton(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    splashRadius: 20,
                    tooltip: "下载",
                    onPressed:
                        () => {
                          controller!.replaceText(
                            embedContext.node.offset,
                            1,
                            '',
                            null,
                          ),
                        },
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedBookDownload,
                      size: 16,
                      color: color,
                    ),
                  )
                  : IconButton(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    splashRadius: 20,
                    tooltip: "删除",
                    onPressed:
                        () => {
                          controller!.replaceText(
                            embedContext.node.offset,
                            1,
                            '',
                            null,
                          ),
                        },
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedDelete01,
                      size: 12,
                    ),
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
    final Map<String, dynamic> data = jsonDecode(node.value.data);
    return '[file:${data['url']??''}]';
  }
}
