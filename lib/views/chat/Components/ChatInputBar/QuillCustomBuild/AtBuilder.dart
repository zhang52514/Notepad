import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class AtBuilder implements EmbedBuilder {

  @override
  String get key => 'at';

  @override
  bool get expanded => false;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final Map<String, dynamic> data = jsonDecode(embedContext.node.value.data);
    final String id = data['id'] ?? '';
    if (id.isEmpty) {
      return SizedBox.shrink();
    }

    final String name = data['name'] ?? '';
    return Text(
      "@$name",
      style: TextStyle(
        fontSize: 14,
        color: Colors.redAccent.shade700,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  WidgetSpan buildWidgetSpan(Widget widget) {
    return WidgetSpan(child: widget, alignment: PlaceholderAlignment.middle);
  }

  @override
  String toPlainText(Embed node) {
        final Map<String, dynamic> data = jsonDecode(node.value.data);
    final String id = data['id'] ?? '';
    return '[at:$id]';
  }
}
