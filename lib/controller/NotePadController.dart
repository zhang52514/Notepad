import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class NotePadController extends ChangeNotifier {
  final QuillController controller = QuillController.basic();
}
