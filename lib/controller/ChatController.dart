import 'dart:async';

import 'package:flutter/cupertino.dart';

class ChatController extends ChangeNotifier {
  final ScrollController scrollController = ScrollController();
  bool _isScrolling = false;
  Timer? _scrollStopTimer;

  bool get isScrolling => _isScrolling;

  ChatController() {
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_isScrolling) {
      _isScrolling = true;
      notifyListeners();
    }

    _scrollStopTimer?.cancel();
    _scrollStopTimer = Timer(const Duration(milliseconds: 500), () {
      _isScrolling = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    _scrollStopTimer?.cancel();
    super.dispose();
  }
}