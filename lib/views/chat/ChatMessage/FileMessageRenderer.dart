import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:notepad/common/utils/FormatUtil.dart';
import 'package:notepad/common/utils/MimeTypeIconProvider.dart';
import 'package:notepad/common/utils/ThemeUtil.dart';
import 'package:notepad/views/chat/ChatMessage/AbstractMessageRenderer.dart';

class FileMessageRenderer extends AbstractMessageRenderer {
  FileMessageRenderer(super.payload);

  @override
  Widget render(BuildContext context) {
    if (payload.attachments.isEmpty) {
      return const Text("文件过期");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          payload.attachments.map((file) {
            final String fileUrl = file.url;
            if (fileUrl.isEmpty) {
              return const SizedBox.shrink();
            }
            final String fileName = fileUrl.split(RegExp(r'[\\/]+')).last;
            final bool isDarkMode = ThemeUtil.isDarkMode(context);

            final Color cardBackgroundColor =
                isDarkMode
                    ? const Color(0xFF2C2C2C)
                    : Colors.indigo.shade800; // 深色卡片背景更深一些
            final Color borderColor =
                isDarkMode
                    ? Colors.grey.shade700
                    : Colors.grey.shade300; // 边框颜色
            final Color shadowColor =
                isDarkMode
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.05); // 深色模式下阴影更明显但柔和

            return Container(
              margin: EdgeInsets.symmetric(vertical: 4.h),
              constraints: BoxConstraints(minHeight: 20.h, maxWidth: 120.w),
              decoration: BoxDecoration(
                color: cardBackgroundColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: borderColor, width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor, // 使用调整后的阴影颜色
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MimeTypeIconProvider.getIconForMimeType(
                      file.type,
                      size: 24,
                      color: messageColor(context), // 使用消息颜色
                    ),
                    SizedBox(width: 8.w), // 图标和文本之间的间距稍微缩小一点，更紧凑
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            fileName,
                            style: TextStyle(
                              fontSize: 13, // 字体大小也用 sp
                              fontWeight: FontWeight.w600,
                              color: messageColor(context), // 使用消息颜色
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            FormatUtil.formatBytes(file.size, 2),
                            style: TextStyle(
                              fontSize: 11,
                              color: messageColor(
                                context,
                              ).withValues(alpha: 0.6), // 文件大小颜色更淡一些
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),

                    IconButton(
                      padding: EdgeInsets.zero, // 移除内边距，方便控制点击区域
                      iconSize: 22,
                      tooltip: "下载文件", // 添加提示信息
                      onPressed: () {
                        print('下载文件: $fileUrl');
                      },
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedDownload01,
                        color: messageColor(context), // 使用消息颜色
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  static void register() {
    MessageRendererRegistry.register(
      'file',
      (payload) => FileMessageRenderer(payload),
    );
  }
}
