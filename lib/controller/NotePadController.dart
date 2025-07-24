import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:notepad/common/domain/NoteTreeNode.dart';
import 'package:notepad/common/utils/dbHelperUtil.dart';
import 'package:sqlite3/sqlite3.dart';

class NotePadController extends ChangeNotifier {
  final QuillController controller = QuillController.basic();
  final DBHelperUtil dbController = DBHelperUtil();

  Future<List<NoteTreeNode>> fetchTreeNodes() async {
    final ResultSet result = await dbController.select(
      'SELECT * FROM nodes ORDER BY level ASC, sort ASC',
    );
    final List<Map<String, dynamic>> maps = [];

    for (final row in result) {
      maps.add({
        'id': row['id'],
        'name': row['name'],
        'type': row['type'],
        'parent_id': row['parent_id'],
        'content': row['content'],
        'created_at': row['created_at'],
        'updated_at': row['updated_at'],
        'level': row['level'],
        'sort': row['sort'],
      });
    }

    // 先将所有节点构建成 Map
    final Map<int, NoteTreeNode> nodeMap = {};

    for (final map in maps) {
      final node = NoteTreeNode(
        map['id'] as int,
        map['type'] as String,
        map['parent_id'] as int?,
        map['created_at'] as String,
        map['updated_at'] as String,
        map['level'] as int,
        map['sort'] as int? ?? 0,
        name: map['name'] as String,
        content: map['content'] ?? '',
      );
      nodeMap[node.id] = node;
    }

    // 建立树结构
    final List<NoteTreeNode> roots = [];
    for (final node in nodeMap.values) {
      if (node.parentId == null) {
        roots.add(node);
      } else {
        final parent = nodeMap[node.parentId]!;
        parent.children.add(node);
        node.parent = parent;
      }
    }
    notifyListeners();
    return roots;
  }
}
