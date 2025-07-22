import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:notepad/common/utils/ThemeUtil.dart';
import 'package:notepad/views/notpad/RightClickTreeMenu.dart';

class LeftTreeView extends StatefulWidget {
  const LeftTreeView({super.key});

  @override
  State<LeftTreeView> createState() => _LeftTreeViewState();
}

class _LeftTreeViewState extends State<LeftTreeView> {
  late final List<NoteTreeNode> roots;
  late final TreeController<NoteTreeNode> treeController;

  @override
  void initState() {
    super.initState();

    roots = [
      NoteTreeNode(
        title: 'Root 1',
        content: 'Content 1',
        children: [
          NoteTreeNode(title: 'Child 1-1', content: 'Content 1-1'),
          NoteTreeNode(title: 'Child 1-2', content: 'Content 1-2'),
        ],
      ),
      NoteTreeNode(
        title: 'Root 2',
        content: 'Content 2',
        children: [NoteTreeNode(title: 'Child 2-1', content: 'Content 2-1')],
      ),
    ];

    treeController = TreeController<NoteTreeNode>(
      roots: roots,
      childrenProvider: (node) => node.children,
      parentProvider: (node) => node.parent,
    );
  }

  bool _isDescendant(NoteTreeNode parent, NoteTreeNode potentialChild) {
    if (parent == potentialChild) return true;
    for (var child in parent.children) {
      if (_isDescendant(child, potentialChild)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color:
              ThemeUtil.isDarkMode(context)
                  ? Colors.black12
                  : Color(0xFFE6E6E9),
          height: 50.h,
          child: Row(
            children: [
              Expanded(child: Text("搜索框")),
              IconButton(icon: const Icon(Icons.add), onPressed: () {}),
            ],
          ),
        ),
        Expanded(
          child: AnimatedTreeView<NoteTreeNode>(
            treeController: treeController,
            nodeBuilder: (BuildContext context, TreeEntry<NoteTreeNode> entry) {
              return TreeDragTarget<NoteTreeNode>(
                node: entry.node,
                onNodeAccepted: (TreeDragAndDropDetails details) {
                  final draggedNode = details.draggedNode as NoteTreeNode;
                  final targetNode = details.targetNode as NoteTreeNode;

                  // 1. 拖到自己或子节点？禁止
                  if (_isDescendant(draggedNode, targetNode)) {
                    debugPrint("❌ 无法拖到自身或子节点下");
                    return;
                  }

                  // 2. 从原位置移除
                  if (draggedNode.parent != null) {
                    draggedNode.parent!.children.remove(draggedNode);
                  } else {
                    roots.remove(draggedNode); // ✅ 如果原来是根节点，要从 roots 移除
                  }

                  // 3. 设置新父节点
                  draggedNode.parent = targetNode;

                  // 4. 添加到新 children
                  targetNode.children.add(draggedNode);

                  // 5. rebuild 刷新 UI
                  treeController.rebuild();
                },
                builder: (
                  BuildContext context,
                  TreeDragAndDropDetails? details,
                ) {
                  Widget myTreeNodeTile = ListTile(
                    dense: true,
                    leading:
                        entry.node.children.isEmpty
                            ? HugeIcon(
                              icon: HugeIcons.strokeRoundedNote01,
                              color: Colors.indigo,
                            )
                            : Icon(Icons.folder, color: Colors.amber.shade700),
                    title: Text(entry.node.title),
                    trailing:
                        entry.node.children.isEmpty
                            ? null
                            : Icon(Icons.arrow_right),
                  );

                  // 如果 details 不为空，拖拽的节点会悬停在拖拽目标上。可添加一些反馈给用户。
                  if (details != null) {
                    myTreeNodeTile = ColoredBox(
                      color: Colors.indigo.withValues(alpha: 0.5),
                      child: myTreeNodeTile,
                    );
                  }

                  return TreeDraggable<NoteTreeNode>(
                    node: entry.node,

                    // 在拖拽的指针下面向用户表示一些反馈，这可以是任意组件。
                    feedback: IntrinsicWidth(
                      child: Material(elevation: 4, child: myTreeNodeTile),
                    ),

                    child: RightClickTreeMenu<NoteTreeNode>(
                      node: entry.node,
                      roots: roots,
                      controller: treeController,
                      getTitle: (node) => node.title,
                      createNode:
                          () => NoteTreeNode(title: '新节点', content: '新内容'),
                      addChild: (newNode, parent) {
                        newNode.parent = parent;
                        parent.children.add(newNode);
                      },
                      onDeleted: (node) {
                        debugPrint("已删除节点：${node.title}");
                      },
                      child: InkWell(
                        onTap: () => treeController.toggleExpansion(entry.node),
                        child: TreeIndentation(
                          entry: entry,
                          child: myTreeNodeTile,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class NoteTreeNode {
  final String title;
  final String content;
  final List<NoteTreeNode> children;
  NoteTreeNode? parent;

  NoteTreeNode({
    required this.title,
    required this.content,
    List<NoteTreeNode>? children,
  }) : children = children ?? [] {
    for (var child in this.children) {
      child.parent = this;
    }
  }
}
