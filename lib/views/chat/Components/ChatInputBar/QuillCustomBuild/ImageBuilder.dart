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
    // --- 1. 数据解析健壮性增强 ---
    final dynamic rawData = embedContext.node.value.data;
    Map<String, dynamic> data;
    if (rawData is String) {
      try {
        data = jsonDecode(rawData) as Map<String, dynamic>;
      } catch (e) {
        // 如果jsonDecode失败，但原始数据是字符串，尝试将其作为url
        data = {'url': rawData};
      }
    } else if (rawData is Map) {
      data = rawData.cast<String, dynamic>(); // 确保类型为 Map<String, dynamic>
    } else {
      return const SizedBox.shrink(); // 数据格式不正确，不显示
    }

    final String imageUrl = data['url'] ?? '';
    if (imageUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    final String heroTag = '${imageUrl}_${embedContext.node.hashCode}';

    final bool isNetwork = imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
    final bool isWindowsFilePath = RegExp(r'^[a-zA-Z]:\\').hasMatch(imageUrl);
    final bool isUnixFilePath = imageUrl.startsWith('/') || imageUrl.startsWith('file://');
    final bool isFile = isWindowsFilePath || isUnixFilePath;

    Widget imageWidget;

    // 获取主题文本颜色，用于加载/错误占位符
    final Color defaultTextColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;

    // --- 2. 优化加载中和错误占位符 ---
    if (isNetwork) {
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover, // 使用 cover 填充容器
        // width: 50.w, // 移除固定宽度，让 ConstrainedBox 控制
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: defaultTextColor.withValues(alpha:0.6)), // 更小的加载指示器
        ),
        errorWidget: (_, __, ___) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min, // 确保Column占据最小空间
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedImageNotFound01,
                size: 20.sp, // 调整图标大小
                color: defaultTextColor.withValues(alpha: 0.6),
              ),
              SizedBox(height: 4.h), // 间距
              Text(
                "加载失败", // 更简洁的提示
                style: TextStyle(fontSize: 10.sp, color: defaultTextColor.withValues(alpha: 0.6)),
              ),
            ],
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
        fit: BoxFit.cover, // 使用 cover 填充容器
        // width: 50.w, // 移除固定宽度，让 ConstrainedBox 控制
        errorBuilder: (_, __, ___) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedImageNotFound01,
                size: 20.sp,
                color: defaultTextColor.withValues(alpha: 0.6),
              ),
              SizedBox(height: 4.h),
              Text(
                "文件损坏", // 更简洁的提示
                style: TextStyle(fontSize: 10.sp, color: defaultTextColor.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),
      );
    } else {
      // 无法识别的图片类型
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedImageNotFound01,
              size: 20.sp,
              color: defaultTextColor.withValues(alpha: 0.6),
            ),
            SizedBox(height: 4.h),
            Text(
              "格式错误", // 更简洁的提示
              style: TextStyle(fontSize: 10.sp, color: defaultTextColor.withValues(alpha: 0.6)),
            ),
          ],
        ),
      );
    }

    // --- 3. 外观美化：圆角、边框、阴影 ---
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h), // 调整外边距
      constraints: BoxConstraints(maxHeight: 100.h, maxWidth: 100.w), // 限制图片最大尺寸，但取消最小高度限制
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r), // 统一圆角
        border: Border.all(
          color: defaultTextColor.withValues(alpha: 0.2), // 柔和的边框
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: defaultTextColor.withValues(alpha: 0.05), // 轻微阴影
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect( // 裁剪为圆角
        borderRadius: BorderRadius.circular(8.r),
        child: GestureDetector(
          onTap: () {
            // 确保只有当图片加载成功时才进行预览
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
    // --- 4. toPlainText数据解析健壮性 ---
    final dynamic rawData = node.value.data;
    Map<String, dynamic> data;
    if (rawData is String) {
      try {
        data = jsonDecode(rawData) as Map<String, dynamic>;
      } catch (e) {
        data = {'url': rawData};
      }
    } else if (rawData is Map) {
      data = rawData.cast<String, dynamic>();
    } else {
      return '[图片]'; // 无法解析，返回通用文本
    }
    return '[图片:${data['url'] ?? ''}]';
  }
}