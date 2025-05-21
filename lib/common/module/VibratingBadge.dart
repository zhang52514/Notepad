import 'package:flutter/material.dart';

class VibratingBadge extends StatefulWidget {
  final int messageCount;
  final double width;
  final double height;

  const VibratingBadge({
    super.key,
    required this.messageCount,
    this.width = 20,
    this.height = 20,
  });

  @override
  State<VibratingBadge> createState() => _VibratingBadgeState();
}

class _VibratingBadgeState extends State<VibratingBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;
  int _oldCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -4), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -4, end: 4), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4, end: -4), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4, end: 0), weight: 1),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant VibratingBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messageCount != _oldCount && widget.messageCount > 0) {
      _controller.forward(from: 0);
    }
    _oldCount = widget.messageCount;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.messageCount == 0) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.indigo.shade600,
          borderRadius: BorderRadius.circular(widget.height / 2),
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            widget.messageCount > 99 ? '99+' : widget.messageCount.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }
}
