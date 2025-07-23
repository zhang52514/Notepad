import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:notepad/common/utils/dbHelperUtil.dart';
import 'package:sqlite3/sqlite3.dart';

class NotePadController extends ChangeNotifier {
  final QuillController controller = QuillController.basic();
  final DBHelperUtil dbController = DBHelperUtil();

  void loadRootNodes() {
    final ResultSet result = dbController.select(
      'SELECT * FROM nodes WHERE parent_id IS NULL;',
    );

    for (final row in result) {
      print('ID: ${row['id']}, Name: ${row['name']}, Type: ${row['type']}');
    }
  }
}
