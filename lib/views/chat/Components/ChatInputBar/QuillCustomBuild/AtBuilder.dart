import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class AtBuilder implements EmbedBuilder {

  @override
  String get key => 'at';

  @override
  bool get expanded => false;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final String name = embedContext.node.value.data;
    return Text(
      "@$name",
      style: TextStyle(
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
    final String name = node.value.data;
    return '[at:$name]';
  }
}
