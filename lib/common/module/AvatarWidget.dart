import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class AvatarWidget extends StatelessWidget {
  final String? url;
  final double size;

  const AvatarWidget({super.key, required this.url, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.network(
        url ?? '',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Center(
            child: HugeIcon(icon: HugeIcons.strokeRoundedImageNotFound01),
          );
        },
      ),
    );
  }
}
