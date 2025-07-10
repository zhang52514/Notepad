import 'dart:math';

import 'package:intl/intl.dart';

class FormatUtil {
  static String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];

    final i = (bytes > 0 ? (log(bytes) / log(1024)).floor() : 0);
    final effectiveIndex = i.clamp(0, suffixes.length - 1);
    final double value = bytes / pow(1024, effectiveIndex);

    return '${value.toStringAsFixed(decimals)} ${suffixes[effectiveIndex]}';
  }

  static String formatChatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    String timeStr = DateFormat('HH:mm').format(timestamp); // 使用 intl 包来格式化时间

    if (messageDate == today) {
      return '今天 $timeStr';
    } else if (messageDate == yesterday) {
      return '昨天 $timeStr';
    } else if (now.difference(timestamp).inDays < 7) {
      // 一周以内，显示星期几
      return '${DateFormat('EEEE', 'zh_CN').format(timestamp)} $timeStr'; // EEEE 代表星期全称
    } else {
      // 更早，显示完整日期
      return '${DateFormat('yyyy年MM月dd日', 'zh_CN').format(timestamp)} $timeStr';
    }
  }
}
