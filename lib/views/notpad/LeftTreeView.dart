import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:notepad/common/utils/ThemeUtil.dart';

class LeftTreeView extends StatefulWidget {
  const LeftTreeView({super.key});

  @override
  State<LeftTreeView> createState() => _LeftTreeViewState();
}

class _LeftTreeViewState extends State<LeftTreeView> {
  TreeViewController<NoteTreeNode, TreeNode<NoteTreeNode>>? _controller;

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
          child: TreeView.simpleTyped<NoteTreeNode, TreeNode<NoteTreeNode>>(
            // 2. 拿到Controller
            onTreeReady: (controller) {
              _controller = controller;
            },
            indentation: Indentation(
              width: 24,
              style: IndentStyle.squareJoint,
              thickness: 0.5,
            ),
            showRootNode: true,
            builder: (context, node) {
              return ListTile(
                dense: true,
                tileColor: Colors.amber,
                leading: Icon(Icons.folder),
                title: Text("Item ${node.data?.title}"),
                onTap: () {
                  if (node.isExpanded) {
                    _controller?.collapseNode(node);
                  } else {
                    _controller?.expandNode(node);
                  }
                },
              );
            },
            tree: root,
          ),
        ),
      ],
    );
  }

  final root =
      TreeNode<NoteTreeNode>.root()..addAll([
        TreeNode<NoteTreeNode>(
          key: "0",
          data: NoteTreeNode(title: "文件夹1", content: "dir"),
        )..add(
          TreeNode<NoteTreeNode>(
            key: "0A1A",
            data: NoteTreeNode(title: "title2", content: ""),
          ),
        ),
      ]);
}

class NoteTreeNode {
  final String title;
  final String content;

  NoteTreeNode({required this.title, required this.content});
}
