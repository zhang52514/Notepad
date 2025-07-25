import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart'; // 假设您已经引入了 hugeicons

/// 根据MIME类型提供相应图标的工具类。
/// 方便在UI中展示不同类型文件的视觉标识。
class MimeTypeIconProvider {
  /// 根据给定的MIME类型字符串返回一个对应的[Widget]图标。
  ///
  /// [mimeType] 文件的MIME类型字符串，例如 'image/png', 'application/pdf', 'audio/mpeg'。
  /// [size] 图标的尺寸，默认为24。
  /// [color] 图标的颜色，默认为null，将使用主题默认颜色。
  static Widget getIconForMimeType(
    String mimeType, {
    double size = 24.0,
    Color? color,
  }) {
    // 将mimeType转换为小写，方便匹配
    final String lowerCaseMimeType = mimeType.toLowerCase();

    // 图片类型
    if (lowerCaseMimeType.startsWith('image/')) {
      return HugeIcon(
        icon: HugeIcons.strokeRoundedImage01,
        size: size,
        color: color,
      );
    }
    // 视频类型
    else if (lowerCaseMimeType.startsWith('video/')) {
      return HugeIcon(
        icon: HugeIcons.strokeRoundedVideo01,
        size: size,
        color: color,
      );
    }
    // 音频类型
    else if (lowerCaseMimeType.startsWith('audio/')) {
      return HugeIcon(
        icon: HugeIcons.strokeRoundedMusicNote01,
        size: size,
        color: color,
      );
    }
    // 文档类型
    else if (lowerCaseMimeType == 'application/pdf') {
      return HugeIcon(
        icon: HugeIcons.strokeRoundedPdf01,
        size: size,
        color: color,
      );
    } else if (lowerCaseMimeType == 'application/msword' || // .doc
               lowerCaseMimeType == 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') { // .docx
      return HugeIcon(
        icon: HugeIcons.strokeRoundedDoc01,
        size: size,
        color: color,
      );
    } else if (lowerCaseMimeType == 'application/vnd.ms-excel' || // .xls
               lowerCaseMimeType == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') { // .xlsx
      return HugeIcon(
        icon: HugeIcons.strokeRoundedXls01,
        size: size,
        color: color,
      );
    } else if (lowerCaseMimeType == 'application/vnd.ms-powerpoint' || // .ppt
               lowerCaseMimeType == 'application/vnd.openxmlformats-officedocument.presentationml.presentation') { // .pptx
      return HugeIcon(
        icon: HugeIcons.strokeRoundedPpt01,
        size: size,
        color: color,
      );
    } else if (lowerCaseMimeType == 'text/plain') {
      return HugeIcon(
        icon: HugeIcons.strokeRoundedText,
        size: size,
        color: color,
      );
    }
    // 压缩文件
    else if (lowerCaseMimeType == 'application/zip' ||
             lowerCaseMimeType == 'application/x-rar-compressed' ||
             lowerCaseMimeType == 'application/x-7z-compressed') {
      return HugeIcon(
        icon: HugeIcons.strokeRoundedZip01,
        size: size,
        color: color,
      );
    }
    // 默认图标（未知或通用文件）
    else {
      return HugeIcon(
        icon: HugeIcons.strokeRoundedFile01, // 通用文件图标
        size: size,
        color: color,
      );
    }
  }
}