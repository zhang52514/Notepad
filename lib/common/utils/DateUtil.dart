import 'package:intl/intl.dart';

class DateUtil {
  /// 格式化为 yyyy-MM-dd
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// 格式化为 yyyy-MM-dd HH:mm:ss
  static String formatFull(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }

  /// 自定义格式化，例如 format: "MM/dd/yyyy HH:mm"
  static String formatCustom(DateTime date, String pattern) {
    return DateFormat(pattern).format(date);
  }

  /// 格式化为中文时间：2025年05月20日
  static String formatChineseDate(DateTime date) {
    return DateFormat('yyyy年MM月dd日', 'zh_CN').format(date);
  }

  /// 只返回时间：HH:mm
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// 相对时间（刚刚 / xx分钟前 / 昨天）
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) {
      return '刚刚';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}小时前';
    } else if (diff.inDays == 1) {
      return '昨天';
    } else if (diff.inDays < 30) {
      return '${diff.inDays}天前';
    } else {
      return formatDate(date);
    }
  }

  /// 将时间字符串（"2025-05-20 14:00:00"）转为 DateTime
  static DateTime parseDate(String dateStr, {String pattern = 'yyyy-MM-dd HH:mm:ss'}) {
    return DateFormat(pattern).parse(dateStr);
  }

  /// 获取当前时间戳（秒）
  static int timestampSeconds() => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  /// 获取当前时间戳（毫秒）
  static int timestampMillis() => DateTime.now().millisecondsSinceEpoch;
}
