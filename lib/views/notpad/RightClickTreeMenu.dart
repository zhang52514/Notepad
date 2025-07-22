import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:notepad/common/utils/ThemeUtil.dart';

class RightClickTreeMenu<T extends Object> extends StatelessWidget {
  final T node;
  final List<T> roots;
  final TreeController<T> controller;
  final Widget child;

  final String Function(T node)? getTitle;
  final T Function()? createNode;
  final void Function(T newNode, T parent)? addChild;
  final void Function(T node)? onDeleted;

  const RightClickTreeMenu({
    super.key,
    required this.node,
    required this.roots,
    required this.controller,
    required this.child,
    this.getTitle,
    this.createNode,
    this.addChild,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: (details) async {
        final position = details.globalPosition;

        final result = await showMenu<String>(
          menuPadding: EdgeInsets.zero,
          elevation: 8,
          color:
              ThemeUtil.isDarkMode(context)
                  ? Colors.transparent
                  : Color(0xFFE6E6E9),
          context: context,
          position: RelativeRect.fromLTRB(
            position.dx,
            position.dy,
            position.dx,
            position.dy,
          ),
          items: const [
            PopupMenuItem(
              value: 'addfolder',
              child: ListTile(
                dense: true,
                leading: HugeIcon(icon: HugeIcons.strokeRoundedFolderAdd,size: 18,),
                title: Text('添加文件夹',style: TextStyle(fontSize: 12,fontWeight: FontWeight.w700),),
              ),
            ),
            PopupMenuItem(
              value: 'add',
              child: ListTile(
                dense: true,
                leading: HugeIcon(icon: HugeIcons.strokeRoundedNoteAdd,size: 18,),
                title: Text('添加笔记',style: TextStyle(fontSize: 12,fontWeight: FontWeight.w700),),
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                dense: true,
                leading: HugeIcon(icon: HugeIcons.strokeRoundedDelete01,size: 18,),
                title: Text('删除',style: TextStyle(fontSize: 12,fontWeight: FontWeight.w700),),
              ),
            ),
          ],
        );

        if (result == 'add') {
          final newNode = createNode?.call();
          if (newNode != null) {
            addChild?.call(newNode, node);
            controller.rebuild();
          }
        } else if (result == 'delete') {
          // 从 roots 或 parent.children 中移除
          if ((node as dynamic).parent != null) {
            (node as dynamic).parent.children.remove(node);
          } else {
            roots.remove(node);
          }
          onDeleted?.call(node);
          controller.rebuild();
        } else if (result == 'addfolder') {
          final newNode = createNode?.call();
          if (newNode != null) {
            addChild?.call(newNode, node);
            controller.rebuild();
          }
        }
      },
      child: child,
    );
  }
}
