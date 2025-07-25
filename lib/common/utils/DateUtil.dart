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

  static bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  static String formatMessageTimestamp(DateTime timestamp) {
    final now = DateTime.now(); // 获取当前时间
    final today = DateTime(now.year, now.month, now.day); // 获取今天的日期（不含时间部分）
    final yesterday = DateTime(now.year, now.month, now.day - 1); // 获取昨天的日期

    if (isSameDay(timestamp, today)) {
      // 如果是今天，显示“今天 HH:mm”
      return '今天 ${formatTime(timestamp)}';
    } else if (isSameDay(timestamp, yesterday)) {
      // 如果是昨天，显示“昨天 HH:mm”
      return '昨天 ${formatTime(timestamp)}';
    } else if (timestamp.year == now.year) {
      // 如果是本年内的消息（但不是今天也不是昨天），显示“MM月dd日 HH:mm”
      return DateFormat('MM月dd日 HH:mm').format(timestamp);
    } else {
      // 如果是跨年消息，显示“yyyy年MM月dd日 HH:mm”
      return DateFormat('yyyy年MM月dd日 HH:mm').format(timestamp);
    }
  }

  /// 将时间字符串（"2025-05-20 14:00:00"）转为 DateTime
  static DateTime parseDate(
    String dateStr, {
    String pattern = 'yyyy-MM-dd HH:mm:ss',
  }) {
    return DateFormat(pattern).parse(dateStr);
  }

  /// 获取当前时间戳（秒）
  static int timestampSeconds() =>
      DateTime.now().millisecondsSinceEpoch ~/ 1000;

  /// 获取当前时间戳（毫秒）
  static int timestampMillis() => DateTime.now().millisecondsSinceEpoch;
}
