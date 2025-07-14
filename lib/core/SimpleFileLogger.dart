import 'dart:io';
import 'package:path_provider/path_provider.dart'; // 需要在 pubspec.yaml 中添加 path_provider 依赖

class SimpleFileLogger {
  static File? _logFile;
  static bool _isInitialized = false; // 标记是否已初始化

  /// 初始化日志记录器。建议在应用启动时调用一次。
  /// [fileName] 日志文件的名称，默认为 'app_logs.txt'。
  static Future<void> initialize({String fileName = 'app_logs.txt'}) async {
    if (_isInitialized) {
      print('日志记录器已初始化过，跳过重复初始化。');
      return;
    }
    try {
      // 获取应用文档目录
      final directory = await getApplicationDocumentsDirectory();
      _logFile = File('${directory.path}/$fileName');

      // 如果文件不存在，则创建它
      if (!await _logFile!.exists()) {
        await _logFile!.create(recursive: true); // recursive: true 确保父目录也存在
      }
      _isInitialized = true;
      _writeToFileSync('--- 日志记录器初始化成功: ${DateTime.now()} ---');
      print('日志文件已准备好: ${_logFile!.path}');
    } catch (e) {
      print('初始化日志记录器失败: $e');
      _isInitialized = false; // 初始化失败则重置标记
    }
  }

  /// 写入日志到文件。
  /// [message] 要记录的日志消息。
  /// 可以选择性地添加 [tag] 来分类日志（如 'DEBUG', 'ERROR'）。
  static void log(String message, {String tag = 'INFO'}) {
    // 确保日志记录器已初始化
    if (!_isInitialized || _logFile == null) {
      print('日志记录器未初始化或初始化失败，日志无法写入文件: [$tag] $message');
      return;
    }
    final logEntry = '${DateTime.now()} [${tag.toUpperCase()}]: $message';
    print(logEntry); // 依然在控制台打印，方便实时调试
    _writeToFileSync(logEntry);
  }

  /// 内部方法：同步写入内容到文件。
  /// 为了保证日志的即时性，这里使用同步写入。
  static void _writeToFileSync(String content) {
    try {
      _logFile!.writeAsStringSync('$content\n', mode: FileMode.append);
    } catch (e) {
      print('写入日志文件失败: $e');
    }
  }

  /// 清空日志文件内容。
  static Future<void> clearLogs() async {
    if (_logFile != null && await _logFile!.exists()) {
      try {
        await _logFile!.writeAsString('', mode: FileMode.write);
        print('日志文件内容已清空。');
      } catch (e) {
        print('清空日志文件失败: $e');
      }
    } else {
      print('日志文件不存在，无需清空。');
    }
  }
}
