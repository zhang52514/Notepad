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
      title: const Text('选择屏幕共享内容'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8, // 对话框宽度占屏幕的80%
        height: MediaQuery.of(context).size.height * 0.6, // 对话框高度占屏幕的60%
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min, // 根据内容调整高度
            children: [
              if (widget.sources.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('没有可用的屏幕或窗口源。'),
                ),
              ...widget.sources.map((source) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: _selectedSource == source ? 8 : 2, // 选中时有更大阴影
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: _selectedSource == source
                        ? const BorderSide(color: Colors.blueAccent, width: 2.0) // 选中时有蓝色边框
                        : BorderSide.none,
                  ),
                  child: ListTile(
                    leading: source.thumbnail != null // 如果有缩略图就显示
                        ? Image.memory(
                            source.thumbnail!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.monitor), // 没有缩略图就显示通用图标
                    title: Text(source.name ?? '未知来源'), // 显示源名称
                    subtitle: Text(source.type == SourceType.Screen ? '屏幕' : '窗口'), // 显示类型
                    onTap: () {
                      setState(() {
                        _selectedSource = source; // 更新选中状态
                      });
                    },
                    selected: _selectedSource == source, // ListTile的选中状态
                    selectedTileColor: Colors.blue.withOpacity(0.1), // 选中时的背景色
                  ),
                );
              }).toList(),
            ],
          ),
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