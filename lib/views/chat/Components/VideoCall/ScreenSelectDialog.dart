import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:notepad/common/utils/themeUtil.dart';

/// 全局缓存，用于存储首次枚举的缩略图，避免重复调用枚举接口
final Map<String, Uint8List?> _thumbnailCache = {};

/// 打开屏幕/窗口选择对话框的便捷方法
Future<DesktopCapturerSource?> showScreenSelectDialog(
  BuildContext context,
) async {
  // 使用 DesktopCapturer 的静态方法枚举源列表
  final sources = await desktopCapturer.getSources(
    types: [SourceType.Screen, SourceType.Window],
    thumbnailSize: ThumbnailSize(320, 240), // 可选：设置缩略图尺寸
  );
  // 缓存缩略图
  for (var src in sources) {
    _thumbnailCache[src.id] = src.thumbnail;
  }
  // 弹出对话框并返回选择结果
  return showDialog<DesktopCapturerSource>(
    context: context,
    builder: (_) => ScreenSelectDialog(sources),
  );
}

/// 一个用于显示可选屏幕/窗口源的对话框，UI 经过精致化优化
class ScreenSelectDialog extends StatefulWidget {
  final List<DesktopCapturerSource> sources;

  const ScreenSelectDialog(this.sources, {super.key});

  @override
  State<ScreenSelectDialog> createState() => _ScreenSelectDialogState();
}

class _ScreenSelectDialogState extends State<ScreenSelectDialog> {
  DesktopCapturerSource? _selected;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ThemeUtil.isDarkMode(context) ? null : Color(0xFFE6E6E9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        '选择屏幕共享内容',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      content: Container(
        decoration: BoxDecoration(
          gradient:
              ThemeUtil.isDarkMode(context)
                  ? null
                  : LinearGradient(
                    begin: Alignment.topCenter, // 或者 Alignment.topLeft
                    end: Alignment.bottomCenter, // 或者 Alignment.bottomRight
                    colors: [
                      // Color(0xFFDEE4EA), // 浅蓝灰
                      // Color(0xFFC3CBD6), // 深一点的蓝灰
                      Color(0xFFE6E6E9), // 开始颜色 灰色
                      Color(0xFFEAE6DB), // 结束颜色 米色
                      // Color(0xFFFFF6E5), // 米白
                      // Color(0xFFE8C8A0), // 浅茶色
                      // Color(0xFFEDEDED), // 银白
                      // Color(0xFFD0CCDF), // 浅紫灰
                    ],
                  ),
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.7,
          child:
              widget.sources.isEmpty
                  ? const Center(
                    child: Text('没有可用的屏幕或窗口源。', style: TextStyle(fontSize: 16)),
                  )
                  : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.3,
                        ),
                    itemCount: widget.sources.length,
                    itemBuilder: (context, i) {
                      final src = widget.sources[i];
                      final thumb = _thumbnailCache[src.id];
                      final isSelected = _selected == src;

                      return Card(
                        clipBehavior: Clip.antiAlias,
                        elevation: isSelected ? 8 : 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () => setState(() => _selected = src),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child:
                                    thumb != null
                                        ? AnimatedOpacity(
                                          opacity: 1,
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          child: Image.memory(
                                            thumb,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                        : Center(
                                          child: Icon(
                                            src.type == SourceType.Screen
                                                ? Icons.monitor
                                                : Icons.window,
                                            size: 48,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      src.name,
                                      style: TextStyle(
                                        color:
                                            isSelected
                                                ? Colors.indigo
                                                : Colors.grey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      src.type == SourceType.Screen
                                          ? '屏幕'
                                          : '窗口',
                                      style: TextStyle(
                                        color:
                                            isSelected
                                                ? Colors.indigo
                                                : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed:
              _selected == null
                  ? null
                  : () => Navigator.of(context).pop(_selected),
          child: const Text('确认共享'),
        ),
      ],
    );
  }
}
