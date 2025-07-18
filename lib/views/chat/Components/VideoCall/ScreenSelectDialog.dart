import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart'; // 导入 flutter_webrtc 以使用 DesktopCapturerSource

/// 一个用于显示可选屏幕/窗口源的对话框。
/// 用户可以从中选择一个源进行屏幕共享。
class ScreenSelectDialog extends StatefulWidget {
  final List<DesktopCapturerSource> sources;

  const ScreenSelectDialog(this.sources, {Key? key}) : super(key: key);

  @override
  State<ScreenSelectDialog> createState() => _ScreenSelectDialogState();
}

class _ScreenSelectDialogState extends State<ScreenSelectDialog> {
  // 当前选中的源
  DesktopCapturerSource? _selectedSource;

  @override
  Widget build(BuildContext context) {

    
    return AlertDialog(
      title: const Text('选择屏幕共享内容', style: TextStyle(fontWeight: FontWeight.bold)),
      contentPadding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 0.0), // 调整内容内边距
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85, // 宽度稍微增加，容纳更大截图
        height: MediaQuery.of(context).size.height * 0.7, // 高度增加，显示更多内容
        child: Column(
          children: [
            if (widget.sources.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('没有可用的屏幕或窗口源。', style: TextStyle(fontSize: 16)),
              ),
            Expanded( // 使用 Expanded 让列表占据剩余空间
              child: GridView.builder( // 使用 GridView 来并排显示截图
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 每行显示2个截图
                  crossAxisSpacing: 16.0, // 列间距
                  mainAxisSpacing: 16.0, // 行间距
                  childAspectRatio: 1.5, // 宽高比，可以根据截图实际比例调整
                ),
                itemCount: widget.sources.length,
                itemBuilder: (context, index) {
                  final source = widget.sources[index];
                  final isSelected = _selectedSource == source;
                  return GestureDetector( // 使用 GestureDetector 替代 ListTile 以便更自由布局
                    onTap: () {
                      setState(() {
                        _selectedSource = source;
                      });
                    },
                    child: AnimatedContainer( // 增加动画效果，选中时有过渡
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.withOpacity(0.15) : Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: isSelected ? Colors.blueAccent : Colors.grey.shade300,
                          width: isSelected ? 3.0 : 1.0,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch, // 让内容横向拉伸
                        children: [
                          Expanded( // 截图占据大部分空间
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect( // 圆角裁剪图片
                                borderRadius: BorderRadius.circular(8.0),
                                child: source.thumbnail != null // ✅ 再次确认 thumbnail 不为 null
                                    ? Image.memory(
                                        source.thumbnail!, // 如果确定非空才使用!
                                        fit: BoxFit.cover, // 覆盖整个可用空间
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey)),
                                      )
                                    : Center( // ✅ 当 thumbnail 为 null 时的替代方案
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              source.type == SourceType.Screen ? Icons.monitor : Icons.window,
                                              size: 60,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(height: 8),
                                            const Text(
                                              '无预览',
                                              style: TextStyle(color: Colors.grey, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  source.name ?? '未知来源',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isSelected ? Colors.blue : Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  source.type == SourceType.Screen ? '屏幕' : '窗口',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected ? Colors.blue.shade700 : Colors.grey.shade600,
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(null); // 用户点击取消，返回 null
          },
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _selectedSource == null // 只有选中了源才能点击确认
              ? null
              : () {
                  Navigator.of(context).pop(_selectedSource); // 返回选中的源
                },
          child: const Text('确认共享'),
        ),
      ],
    );
  }
}