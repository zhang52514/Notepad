import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

class DBHelperUtil {
  // 静态实例，实现单例模式
  static final DBHelperUtil _instance = DBHelperUtil._internal();
  factory DBHelperUtil() => _instance;

  // 私有构造函数
  DBHelperUtil._internal();

  // 数据库连接实例
  late Database _db;

  // 数据库路径和名称
  final String _dbName = 'notepad.db';

  /// 初始化并打开数据库
  Future<void> initDatabase() async {
    // 获取应用的数据目录，Windows 上一般在 `C:\Users\用户名\AppData\Local\你的应用名`
    // 如果没有，可以自己指定一个目录，例如在当前工作目录
    final String dbPath = p.join(
      Directory.current.path,
      'db', // 在当前目录下创建一个 db 文件夹
      _dbName,
    );
    
    // 确保数据库目录存在
    final Directory dbDir = Directory(p.dirname(dbPath));
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }

    // 打开数据库
    _db = sqlite3.open(dbPath);

    // 检查并创建表，如果表不存在的话
    _createTables();
    print('数据库已成功打开，路径: $dbPath');
  }

  /// 创建数据表
  void _createTables() {
    // 这里放你的建表语句
    _db.execute('''
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
  }
  
  /// 获取数据库连接实例
  Database get database => _db;

  /// 执行 SQL 查询
  ResultSet select(String sql, [List<Object?> parameters = const []]) {
    return _db.select(sql, parameters);
  }

  /// 执行 SQL 语句 (插入, 更新, 删除, 事务等)
  void execute(String sql, [List<Object?> parameters = const []]) {
    _db.execute(sql, parameters);
  }

  /// 关闭数据库连接
  void close() {
    _db.dispose();
  }
}