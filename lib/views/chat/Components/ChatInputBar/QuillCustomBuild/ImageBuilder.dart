import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:notepad/common/module/ImageViewer.dart';

class ImageBuilder implements EmbedBuilder {
  @override
  String get key => BlockEmbed.imageType;

  @override
  bool get expanded => false;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
  
     final Map<String, dynamic> data = jsonDecode(embedContext.node.value.data);
    final String imageUrl = data['url'] ?? '';
    if (imageUrl.isEmpty) {
      return SizedBox.shrink();
    }
    final String heroTag = '${imageUrl}_${embedContext.node.hashCode}';

    final bool isNetwork =
        imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
    final bool isWindowsFilePath = RegExp(
      r'^[a-zA-Z]:\\',
    ).hasMatch(imageUrl); // 例如 C:\xxx
    final bool isUnixFilePath =
        imageUrl.startsWith('/') || imageUrl.startsWith('file://');
    final bool isFile = isWindowsFilePath || isUnixFilePath;

    Widget imageWidget;

    if (isNetwork) {
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl,
        width: 50.w,
        fit: BoxFit.contain,
        placeholder: (context, url) => Center(child: Text("加载中...")),
        errorWidget:
            (_, __, ___) => Center(
              child: TextButton.icon(
                onPressed: null,
                label: Text("图片加载失败"),
                icon: HugeIcon(icon: HugeIcons.strokeRoundedImageNotFound01),
              ),
            ),
      );
    } else if (isFile) {
      String filePath = imageUrl;
      if (filePath.startsWith('file://')) {
        filePath = filePath.replaceFirst('file://', '');
      }
      imageWidget = Image.file(
        width: 50.w,
        File(filePath),
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) => Center(
              child: TextButton.icon(
                onPressed: null,
                label: Text("图片破损"),
                icon: HugeIcon(icon: HugeIcons.strokeRoundedImageNotFound01),
              ),
            ),
      );
    } else {
      return TextButton.icon(
        onPressed: null,
        label: Text("图片破损"),
        icon: HugeIcon(icon: HugeIcons.strokeRoundedImageNotFound01),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 80.h, maxWidth: 100.w),
      child: Padding(
        padding: EdgeInsets.all(4),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ImageViewer(imageUrl: imageUrl, heroTag: heroTag),
                  );
                },
              ),
            );
          },
          child: Hero(tag: heroTag, child: imageWidget),
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
    return '[Image:${data['url']??''}]';
  }
}
