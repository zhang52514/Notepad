// viewer_page.dart

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewer extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const ImageViewer({required this.imageUrl, required this.heroTag, super.key});

  @override
  Widget build(BuildContext context) {
    final bool isNetwork =
        imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
    final bool isWindowsFilePath = RegExp(r'^[a-zA-Z]:\\').hasMatch(imageUrl);
    final bool isUnixFilePath =
        imageUrl.startsWith('/') || imageUrl.startsWith('file://');
    final bool isFile = isWindowsFilePath || isUnixFilePath;

    ImageProvider provider;

    if (isNetwork) {
      provider = CachedNetworkImageProvider(imageUrl);
    } else if (isFile) {
      var filePath = imageUrl.replaceFirst('file://', '');
      provider = FileImage(File(filePath));
    } else {
      return Scaffold(body: Center(child: Text("不支持的图片类型")));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: Colors.white),
                ),
                Expanded(child: SizedBox.shrink()),
                Text("图片详情", style: TextStyle(color: Colors.white)),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Center(
                  child: Hero(
                    tag: heroTag,
                    child: PhotoView(
                      imageProvider: provider,
                      // backgroundDecoration: const BoxDecoration(color: Colors.black),
                      // minScale: PhotoViewComputedScale.contained * 1.0,
                      // maxScale: PhotoViewComputedScale.covered * 3.0,
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                "图像",
                style: TextStyle(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
