import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:notepad/common/domain/ChatEnumAll.dart';
import 'package:notepad/common/module/bubbleDialog.dart';
import 'package:notepad/common/utils/themeUtil.dart';
import 'package:notepad/views/chat/ChatMessage/AbstractMessageRenderer.dart';
import 'package:notepad/views/chat/ChatMessage/ChatMessageWidget/MessagePayload.dart';

import '../../../../common/module/AvatarWidget.dart';

/// 消息气泡框
/// [ChatMessageBubble] 消息气泡框
/// [MessagePayload] 消息数据
class ChatMessageBubble extends StatelessWidget {
  final MessagePayload payload;

  const ChatMessageBubble({super.key, required this.payload});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: payload.reverse ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        child: Column(
          crossAxisAlignment:
              payload.reverse
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            ///  消息时间 + 名称
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (payload.reverse) ...[SizedBox(width: 45)],
                Text.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                    children: [
                      TextSpan(
                        text: !payload.reverse ? payload.status.label : '',
                      ),
                      TextSpan(text: "  "),
                      TextSpan(
                        text: payload.reverse ? payload.name : payload.time,
                      ),
                      TextSpan(text: "  "),
                      TextSpan(
                        text: payload.reverse ? payload.time : '',
                      ),
                    ],
                  ),
                ),
                if (!payload.reverse) ...[SizedBox(width: 45)],
              ],
            ),

            ///消息气泡框
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (payload.reverse) ...[
                  _buildAvatar(payload.avatar),
                  SizedBox(width: 4),
                ],
                Flexible(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.5,
                    ),
                    child: IntrinsicWidth(
                      child: () {
                        if (payload.type == 'quill' || payload.type == 'text') {
                          return BubbleWidget(
                            arrowDirection:
                                payload.reverse
                                    ? AxisDirection.left
                                    : AxisDirection.right,
                            arrowOffset: 22,
                            arrowLength: 8,
                            arrowRadius: 4,
                            arrowWidth: 14,
                            padding: const EdgeInsets.all(8),
                            borderRadius: BorderRadius.circular(4),
                            backgroundColor:
                                !payload.reverse
                                    ? Colors.indigo
                                    : ThemeUtil.isDarkMode(context)
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade300,
                            contentBuilder:
                                (context) =>
                                    buildMessageWidget(payload, context),
                          );
                        }
                        return buildMessageWidget(payload, context);
                      }(),
                    ),
                  ),
                ),
                if (!payload.reverse) ...[
                  SizedBox(width: 4),
                  _buildAvatar(payload.avatar),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String url) {
    // return ClipOval(
    //   child: CachedNetworkImage(
    //     filterQuality: FilterQuality.high,
    //     imageUrl: url,
    //     width: 40,
    //     fit: BoxFit.cover,
    //     placeholder:
    //         (context, url) => HugeIcon(icon: HugeIcons.strokeRoundedLoading03),
    //     errorWidget:
    //         (_, __, ___) => Center(
    //           child: HugeIcon(icon: HugeIcons.strokeRoundedImageNotFound01),
    //         ),
    //   ),
    // );
    return AvatarWidget(url: url);
  }

  /// 根据消息类型构建消息组件
  /// [payload] 消息数据
  /// [context] 上下文
  /// [return] 消息组件
  Widget buildMessageWidget(MessagePayload payload, BuildContext context) {
    final renderer = MessageRendererRegistry.fromType(payload);
    return renderer.render(context);
  }
}
