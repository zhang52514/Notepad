import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:notepad/common/module/ImageViewer.dart';
import 'package:notepad/views/chat/ChatMessage/AbstractMessageRenderer.dart';

class ImageMessageRenderer extends AbstractMessageRenderer {
  ImageMessageRenderer(super.payload);

  @override
  Widget render(BuildContext context) {
    if (payload.attachments.isEmpty) {
      return const Text("图像过期");
    }

    // 使用 Column 或 Wrap 来容纳多张图片
    return Column(
      // 或者 Wrap，根据需要决定布局
      crossAxisAlignment: CrossAxisAlignment.start, // 保证图片从左侧开始排列
      children:
          payload.attachments.map((image) {
            final String imageUrl = image.url;
            if (imageUrl.isEmpty) {
              return const SizedBox.shrink();
            }

            final String heroTag =
                '${imageUrl}_${context.hashCode}_${image.hashCode}'; // 增加唯一性

            final bool isNetwork =
                imageUrl.startsWith('http://') ||
                imageUrl.startsWith('https://');
            final bool isWindowsFilePath = RegExp(
              r'^[a-zA-Z]:\\',
            ).hasMatch(imageUrl);
            final bool isUnixFilePath =
                imageUrl.startsWith('/') || imageUrl.startsWith('file://');
            final bool isFile = isWindowsFilePath || isUnixFilePath;

            Widget imageWidget;

            if (isNetwork) {
              imageWidget = CachedNetworkImage(
                imageUrl: imageUrl,
                width: 50.w,
                height: 50.w, // 为本地图片也设定高度，保持一致性
                fit: BoxFit.cover, // 通常图片列表用 cover 保持裁剪一致性
                placeholder: (context, url) => Center(child: Text("加载中...")),
                errorWidget:
                    (_, __, ___) => Center(
                      child: TextButton.icon(
                        onPressed: null,
                        label: const Text("图片加载失败"),
                        icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedImageNotFound01,
                        ),
                      ),
                    ),
              );
            } else if (isFile) {
              String filePath = imageUrl;
              if (filePath.startsWith('file://')) {
                filePath = filePath.replaceFirst('file://', '');
              }
              imageWidget = Image.file(
                File(filePath),
                width: 50.w,
                height: 50.w, // 为本地图片也设定高度，保持一致性
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Center(
                      child: TextButton.icon(
                        onPressed: null,
                        label: const Text("图片破损"),
                        icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedImageNotFound01,
                        ),
                      ),
                    ),
              );
            } else {
              return TextButton.icon(
                onPressed: null,
                label: const Text("图片破损"),
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedImageNotFound01,
                ),
              );
            }

            return ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 80.h, maxWidth: 100.w),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ImageViewer(
                              imageUrl: imageUrl,
                              heroTag: heroTag,
                            ),
                          );
                        },
                      ),
                    );
                  },
                  child: Hero(tag: heroTag, child: imageWidget),
                ),
              ),
            );
          }).toList(), // 将 Iterable 转换为 List
    );
  }

  static void register() {
    MessageRendererRegistry.register(
      'image',
      (payload) => ImageMessageRenderer(payload),
    );
  }
}
