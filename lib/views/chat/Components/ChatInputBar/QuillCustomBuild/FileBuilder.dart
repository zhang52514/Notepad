import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:notepad/common/utils/MimeTypeIconProvider.dart';
// 假设您有一个 ThemeUtil 类来判断深色模式，如果 Quill 自身有主题判断，也可以用它的
// import 'package:notepad/common/utils/ThemeUtil.dart';

class FileBuilder implements EmbedBuilder {
  final QuillController? controller;

  FileBuilder({this.controller});

  @override
  String get key => 'file';

  @override
  bool get expanded => false;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    // 确保数据解析的健壮性，兼容之前可能存在的双重编码问题
    final dynamic rawData = embedContext.node.value.data;
    Map<String, dynamic> data;
    if (rawData is String) {
      try {
        data = jsonDecode(rawData) as Map<String, dynamic>;
      } catch (e) {
        data = {'url': rawData}; // 如果解码失败，尝试将整个字符串作为url
      }
    } else if (rawData is Map) {
      data = rawData.cast<String, dynamic>(); // 确保类型为 Map<String, dynamic>
    } else {
      return const SizedBox.shrink(); // 数据格式不正确，不显示
    }

    final String fileUrl = data['url'] ?? '';
    final String fileName =
        data['name'] ?? fileUrl.split(RegExp(r'[\\/]+')).last; // 优先使用 name 字段
    final String fileType =
        data['type'] ?? 'application/octet-stream'; // 获取文件类型
    final int fileSize =
        int.tryParse(data['size']?.toString() ?? '') ?? 0; // 如果需要显示大小

    if (fileUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    // 根据 Quill 编辑器的主题色来选择文字和图标颜色
    // 默认使用主题文本颜色，在深色模式下自动适应
    final Color defaultColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    final Color accentColor = Theme.of(context).colorScheme.primary; // 使用主题强调色
    final Color deleteColor = Colors.red.shade700; // 删除按钮使用红色

    return Container(
      // 保持合理的最小高度和最大宽度，但更强调内容自适应
      constraints: BoxConstraints(
        minHeight: 36.h, // 稍微减少高度，使其更像文本流中的元素
        maxWidth: 180.w, // Quill 编辑器中通常不希望太宽
      ),
      margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h), // 调整间距
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: defaultColor.withOpacity(0.05), // 轻微的背景色，突出文件块
        borderRadius: BorderRadius.circular(8.r), // 更小的圆角，更贴近文本
        border: Border.all(
          color: defaultColor.withOpacity(0.2), // 边框颜色更柔和
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // 宽度自适应内容
        children: [
          MimeTypeIconProvider.getIconForMimeType(
            fileType,
            size: 16, // 图标大小与文本一致
            color: accentColor, // 使用强调色
          ),
          SizedBox(width: 6.w), // 图标和文本之间的间距

          Expanded(
            child: Text(
              fileName,
              style: TextStyle(
                fontSize: 13, // 字体大小
                color: defaultColor, // 使用默认文字颜色
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          SizedBox(width: 6.w), // 文本和按钮之间的间距
          // 根据是否有 controller 来决定显示下载按钮（预览）还是删除按钮（编辑）
          controller == null
              ? InkWell(
                // 下载按钮 (用于预览模式)
                onTap: () {
                  // TODO: 实现文件下载逻辑
                  print('下载文件: $fileUrl');
                },
                borderRadius: BorderRadius.circular(4.r),
                child: Padding(
                  padding: EdgeInsets.all(4.w), // 增加点击区域
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedDownload01,
                    size: 18,
                    color: accentColor, // 下载按钮用强调色
                  ),
                ),
              )
              : InkWell(
                // 删除按钮 (用于编辑模式)
                onTap: () {
                  // 安全检查：确保 controller 不为 null 且节点有效
                  if (controller != null && embedContext.node.offset != null) {
                    controller!.replaceText(
                      embedContext.node.offset,
                      1, // 替换当前嵌入节点 (通常长度为1)
                      '',
                      null,
                    );
                  }
                },
                borderRadius: BorderRadius.circular(4.r),
                child: Padding(
                  padding: EdgeInsets.all(4.w), // 增加点击区域
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedDelete01,
                    size: 16, // 删除图标可以小一点
                    color: deleteColor, // 删除图标用红色
                  ),
                ),
              ),
        ],
      ),
    );
  }

  @override
  WidgetSpan buildWidgetSpan(Widget widget) {
    return WidgetSpan(child: widget, alignment: PlaceholderAlignment.middle);
  }

  @override
  String toPlainText(Embed node) {
    // 确保数据解析的健壮性
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
      return '[文件]'; // 无法解析，返回通用文本
    }

    final String fileName =
        data['name'] ?? (data['url']?.split(RegExp(r'[\\/]+')).last ?? '');
    return '[文件:$fileName]';
  }
}
