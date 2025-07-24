import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

class DBHelperUtil {
  static final DBHelperUtil _instance = DBHelperUtil._internal();
  factory DBHelperUtil() => _instance;

  DBHelperUtil._internal();

  // 使用一个私有的 Future 来管理数据库的初始化状态
  Future<Database>? _dbFuture;

  final String _dbName = 'notepad.db';

  // 优化过的数据库 getter
  // 它会确保 _dbFuture 已经完成，返回一个可用的数据库实例
  Future<Database> get _database async {
    // 如果 _dbFuture 为空，说明还没开始初始化，则进行初始化
    _dbFuture ??= _initDatabase();
    return _dbFuture!;
  }

  // 封装初始化逻辑，返回一个 Future<Database>
  Future<Database> _initDatabase() async {
    final String dbPath = p.join(Directory.current.path, 'db', _dbName);

    final Directory dbDir = Directory(p.dirname(dbPath));
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }

    final Database db = sqlite3.open(dbPath);
    _createTables(db);
    print('数据库已成功打开，路径: $dbPath');
    return db;
  }

  Future<void> _createTables(Database db) async {
    db.execute('''
      CREATE TABLE IF NOT EXISTS nodes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL, -- 'folder' or 'note'
        parent_id INTEGER,
        content TEXT, -- only used for 'note' type
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        level integer NOT NULL,
        sort integer,
        FOREIGN KEY (parent_id) REFERENCES nodes (id) ON DELETE CASCADE
      );
    ''');

    // 检查根节点是否存在
    final ResultSet result = db.select(
      'SELECT COUNT(*) AS count FROM nodes WHERE parent_id IS NULL AND type = ?',
      ['folder'],
    );
    final int count = result.first['count'] as int;

    if (count == 0) {
      // 如果不存在，则插入默认根节点
      final now = DateTime.now().toIso8601String();
      db.execute(
        '''
        INSERT INTO nodes (name, type, parent_id, content, created_at, updated_at, level, sort)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ''',
        [
          '我的笔记', // 根节点名称
          'folder', // 类型为文件夹
          null, // 根节点没有父ID
          null, // 文件夹没有内容
          now,
          now,
          0, // 根节点层级为0
          0, // 排序
        ],
      );
      print('已插入默认根节点。');
    }
  }

  /// 执行 SQL 查询
  Future<ResultSet> select(
    String sql, [
    List<Object?> parameters = const [],
  ]) async {
    final db = await _database;
    return db.select(sql, parameters);
  }

  /// 执行 SQL 语句 (插入, 更新, 删除, 事务等)
  Future<void> execute(
    String sql, [
    List<Object?> parameters = const [],
  ]) async {
    final db = await _database;
    db.execute(sql, parameters);
  }

  /// 关闭数据库连接
  Future<void> close() async {
    final db = await _database;
    db.dispose();
    _dbFuture = null; // 重置 Future，以便下次可以重新初始化
  }
}
