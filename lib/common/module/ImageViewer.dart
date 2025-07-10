// viewer_page.dart

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewer extends StatefulWidget {
  final String imageUrl;
  final String heroTag;
  final String? initialTitle;

  const ImageViewer({
    required this.imageUrl,
    required this.heroTag,
    this.initialTitle,
    super.key,
  });

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  late final PhotoViewController _controller;
  late final PhotoViewScaleStateController _scaleStateCtrl;
  ImageProvider? _provider;
  bool _loadFailed = false;

  // 缩放因子控制
  static const double _step = 0.2;
  static const double _minScaleFactor = 0.5;
  static const double _maxScaleFactor = 4.0;

  String get _fileName {
    if (widget.initialTitle != null && widget.initialTitle!.isNotEmpty) {
      return widget.initialTitle!;
    }
    try {
      final uri = Uri.parse(widget.imageUrl);
      final name =
          uri.pathSegments.isNotEmpty ? uri.pathSegments.last : widget.heroTag;
      return name.split('?').first;
    } catch (e) {
      return widget.heroTag;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = PhotoViewController();
    _scaleStateCtrl = PhotoViewScaleStateController();
    _resolveImage();
  }

  void _resolveImage() {
    final u = widget.imageUrl;
    if (u.startsWith(RegExp(r'https?://'))) {
      _provider = CachedNetworkImageProvider(u);
    } else {
      final f = File(u.replaceFirst('file://', ''));
      if (f.existsSync()) {
        _provider = FileImage(f);
      } else {
        _loadFailed = true;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scaleStateCtrl.dispose();
    super.dispose();
  }

  void _onPointerSignal(PointerSignalEvent evt) {
    if (evt is PointerScrollEvent && _provider != null) {
      final double oldScale = _controller.scale ?? 1.0;
      final double delta = evt.scrollDelta.dy < 0 ? (1 + _step) : (1 - _step);
      final double target = (oldScale * delta).clamp(
        _minScaleFactor,
        _maxScaleFactor,
      );
      _controller.scale = target;
    }
  }

  void _zoomIn() {
    final double oldScale = _controller.scale ?? 1.0;
    final double target = (oldScale * (1 + _step)).clamp(
      _minScaleFactor,
      _maxScaleFactor,
    );
    _controller.scale = target;
  }

  void _zoomOut() {
    final double oldScale = _controller.scale ?? 1.0;
    final double target = (oldScale * (1 - _step)).clamp(
      _minScaleFactor,
      _maxScaleFactor,
    );
    _controller.scale = target;
  }

  void _downloadImage() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('开始下载…')));
  }

  @override
  Widget build(BuildContext context) {
    // 失败或无图
    if (_loadFailed || _provider == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.white70, size: 48.sp),
              SizedBox(height: 16.h),
              Text(
                '无法加载图片',
                style: TextStyle(color: Colors.white70, fontSize: 16.sp),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('返回'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      // 保证状态栏白色图标
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          children: [
            // 中心图片区域
            Center(
              child: Listener(
                onPointerSignal: _onPointerSignal,
                child: PhotoView(
                  controller: _controller,
                  scaleStateController: _scaleStateCtrl,
                  imageProvider: _provider!,
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  minScale: PhotoViewComputedScale.contained * _minScaleFactor,
                  maxScale: PhotoViewComputedScale.contained * _maxScaleFactor,
                  enableRotation: false,
                  initialScale: 0.52,
                  basePosition: Alignment.center,
                  heroAttributes: PhotoViewHeroAttributes(tag: widget.heroTag),
                ),
              ),
            ),

            // 顶部导航栏
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Container(
                  color: Colors.black54,
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  height: 48.h,
                  child: Row(
                    children: [
                      IconButton(
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowLeft01,
                          color: Colors.white,
                          size: 16,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),

                      IconButton(
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedZoomInArea,
                          color: Colors.white,
                          size: 16,
                        ),
                        onPressed: _zoomIn,
                      ),
                      IconButton(
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedZoomOutArea,
                          color: Colors.white,
                          size: 16,
                        ),
                        onPressed: _zoomOut,
                      ),
                      IconButton(
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedRefresh,
                          color: Colors.white,
                          size: 16,
                        ),
                        tooltip: '重置缩放',
                        onPressed: () {
                          _controller.scale = 1.0;
                          _scaleStateCtrl.scaleState =
                              PhotoViewScaleState.initial;
                        },
                      ),
                      IconButton(
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedDownload01,
                          color: Colors.white,
                          size: 16,
                        ),
                        onPressed: _downloadImage,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 底部文件名
            Positioned(
              bottom: 16.h,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      _fileName,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
