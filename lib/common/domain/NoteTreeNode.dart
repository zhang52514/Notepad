class NoteTreeNode {
  final int id;
  final String name;
  final String type; // 'folder' 或 'note'
  final int? parentId;
  final String content;
  final String createdAt;
  final String updatedAt;
  final int level;
  final int? sort;
  final List<NoteTreeNode> children;
  NoteTreeNode? parent;

  NoteTreeNode(
    this.id,
    this.type,
    this.parentId,
    this.createdAt,
    this.updatedAt,
    this.level,
    this.sort, {
    required this.name,
    required this.content,
    List<NoteTreeNode>? children,
  }) : children = children ?? [];

  factory NoteTreeNode.fromMap(Map<String, dynamic> map) {
    return NoteTreeNode(
      map['id'] as int,
      map['type'] as String,
      map['parent_id'] as int?, // 这里保留可空类型
      map['created_at'] as String,
      map['updated_at'] as String,
      map['level'] as int,
      map['sort'] as int?,
      name: map['name'] as String,
      content: map['content'] ?? '',
    );
  }
}
