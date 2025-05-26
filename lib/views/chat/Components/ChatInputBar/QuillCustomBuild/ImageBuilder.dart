import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ImageBuilder implements EmbedBuilder {
  @override
  String get key => BlockEmbed.imageType;

  @override
  bool get expanded => false;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final String imageUrl = embedContext.node.value.data;

    final bool isNetwork =
        imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
    final bool isWindowsFilePath = RegExp(
      r'^[a-zA-Z]:\\',
    ).hasMatch(imageUrl); // 例如 C:\xxx
    final bool isUnixFilePath =
        imageUrl.startsWith('/') || imageUrl.startsWith('file://');
    final bool isFile = isWindowsFilePath || isUnixFilePath;

    Image imageWidget;

    if (isNetwork) {
      imageWidget = Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (ctx, child, progress) {
          if (progress == null) return child;
          return Center(child: CircularProgressIndicator());
        },
        errorBuilder:
            (_, __, ___) =>
                const Center(child: Icon(Icons.broken_image, size: 48)),
      );
    } else if (isFile) {
      String filePath = imageUrl;
      if (filePath.startsWith('file://')) {
        filePath = filePath.replaceFirst('file://', '');
      }

      imageWidget = Image.file(
        File(filePath),
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) =>
                const Center(child: Icon(Icons.broken_image, size: 48)),
      );
    } else {
      return const Center(child: Icon(Icons.image_not_supported, size: 48));
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 60.h, // 高度最多50
      ),
      child: Padding(padding: EdgeInsets.all(4), child: imageWidget),
    );
  }

  @override
  WidgetSpan buildWidgetSpan(Widget widget) {
    return WidgetSpan(child: widget, alignment: PlaceholderAlignment.middle);
  }

  @override
  String toPlainText(Embed node) {
    final String url = node.value.data;
    return '[Image:$url]';
  }
}
