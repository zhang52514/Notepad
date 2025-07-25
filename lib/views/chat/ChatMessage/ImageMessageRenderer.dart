import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:notepad/common/module/ImageViewer.dart'; // 您的图片查看器
import 'package:notepad/views/chat/ChatMessage/AbstractMessageRenderer.dart';

class ImageMessageRenderer extends AbstractMessageRenderer {
  ImageMessageRenderer(super.payload);

  @override
  Widget render(BuildContext context) {
    if (payload.attachments.isEmpty) {
      // 图像附件为空时，显示更友好的提示
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Text(
          "图片已失效或加载失败",
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(
              alpha: 0.6,
            ), // 使用 withOpacity
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    // 获取主题颜色，用于加载/错误占位符
    final Color defaultTextColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;

    // 定义图片宽高，保持您原有的 50.w
    final double imageSize = 50.w;

    // 假设头像宽度是 40.w，气泡和头像间距是 4.w
    // 这个数值与 ChatMessageBubble 中的对齐有关，用于计算左侧偏移量
    // 如果您希望图片列表整体靠左，不需要这个偏移，可以将其设置为 0.0
    final double leftOffsetForOtherUser = 40.w + 4.w; // 头像宽度 + 气泡-头像间距

    // 判断消息是否由当前用户发送
    final bool isCurrentUser = !payload.reverse;

    // 构建所有图片项的列表，包括潜在的偏移 SizedBox
    List<Widget> imageWidgets = [];

    // 根据是对方消息还是我方消息，调整整体的水平对齐
    // 对于对方消息，整个图片区域应该向右偏移，以便和气泡内容对齐
    // 对于我方消息，图片区域保持靠右
    if (!isCurrentUser) {
      // 如果是对方消息，在图片列表最前面添加一个占位符来模拟缩进
      imageWidgets.add(SizedBox(width: leftOffsetForOtherUser));
    }

    for (int i = 0; i < payload.attachments.length; i++) {
      final image = payload.attachments[i];
      final String imageUrl = image.url;
      if (imageUrl.isEmpty) {
        imageWidgets.add(const SizedBox.shrink());
        continue;
      }

      // HeroTag 增加 payload.id 确保在多条消息中唯一
      // 保持您原有的 HeroTag 逻辑
      final String heroTag = '${imageUrl}_${image.hashCode}';

      final bool isNetwork =
          imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
      // 检查文件是否存在
      final bool isFile =
          imageUrl.startsWith('file://') ||
          (Platform.isWindows &&
              imageUrl.contains(r'\') &&
              File(imageUrl).existsSync());

      Widget currentImageWidget;

      if (isNetwork) {
        currentImageWidget = CachedNetworkImage(
          imageUrl: imageUrl,
          width: imageSize,
          height: imageSize,
          fit: BoxFit.cover,
          placeholder:
              (context, url) => Container(
                width: imageSize,
                height: imageSize,
                color: defaultTextColor.withValues(
                  alpha: 0.08,
                ), // 使用 withOpacity
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: defaultTextColor.withValues(
                      alpha: 0.6,
                    ), // 使用 withOpacity
                  ),
                ),
              ),
          errorWidget:
              (_, __, ___) =>
                  _buildErrorPlaceholder(defaultTextColor, imageSize),
        );
      } else if (isFile) {
        final path =
            imageUrl.startsWith('file://')
                ? imageUrl.replaceFirst('file://', '')
                : imageUrl;
        currentImageWidget = Image.file(
          File(path),
          width: imageSize,
          height: imageSize,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) => _buildErrorPlaceholder(
                defaultTextColor,
                imageSize,
                message: "文件损坏",
              ),
        );
      } else {
        // 无法识别或无效的图片路径
        currentImageWidget = _buildErrorPlaceholder(
          defaultTextColor,
          imageSize,
          message: "无效图片",
        );
      }

      // 包裹图片，添加圆角、边框、阴影和点击事件
      Widget finalImageContainer = GestureDetector(
        onTap: () {
          // 只有当图片有效时才导航到 ImageViewer
          if (imageUrl.isNotEmpty && (isNetwork || isFile)) {
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
          }
        },
        child: Container(
          width: imageSize,
          height: imageSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r), // 圆角
            border: Border.all(
              color: defaultTextColor.withValues(alpha: 0.1), // 使用 withOpacity
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: defaultTextColor.withValues(
                  alpha: 0.03,
                ), // 使用 withOpacity
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            // 确保图片内容也被裁剪为圆角
            borderRadius: BorderRadius.circular(8.r),
            child: Hero(tag: heroTag, child: currentImageWidget),
          ),
        ),
      );

      imageWidgets.add(finalImageContainer);
    }

    // Wrap 容器
    return Wrap(
      alignment:
          isCurrentUser
              ? WrapAlignment.end
              : WrapAlignment.start, // 根据发送方调整整体对齐
      spacing: 6.w, // 图片之间的水平间距
      runSpacing: 6.h, // 图片之间的垂直间距
      children: imageWidgets,
    );
  }

  // 统一的错误占位符构建方法
  Widget _buildErrorPlaceholder(
    Color textColor,
    double size, {
    String message = "加载失败",
  }) {
    return Container(
      width: size,
      height: size,
      color: textColor.withValues(alpha: 0.08), // 使用 withOpacity
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedImageNotFound01,
              size: 24, // 错误图标尺寸
              color: textColor.withValues(alpha: 0.5), // 使用 withOpacity
            ),
            SizedBox(height: 4.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 10,
                color: textColor.withValues(alpha: 0.5), // 使用 withOpacity
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  static void register() {
    MessageRendererRegistry.register(
      'image',
      (payload) => ImageMessageRenderer(payload),
    );
  }
}
