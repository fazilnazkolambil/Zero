import 'dart:async';

import 'package:flutter/material.dart';

class AutoPageView extends StatefulWidget {
  const AutoPageView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.interval = const Duration(seconds: 3),
    this.transitionDuration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOut,
    this.controller,
    this.onPageChanged,
    this.loop = true,
    this.physics,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Duration interval;
  final Duration transitionDuration;
  final Curve curve;
  final PageController? controller;
  final ValueChanged<int>? onPageChanged;
  final bool loop;
  final ScrollPhysics? physics;

  @override
  State<AutoPageView> createState() => _AutoPageViewState();
}

class _AutoPageViewState extends State<AutoPageView> {
  late final PageController _controller = widget.controller ?? PageController();

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(widget.interval, (_) {
      if (!_controller.hasClients || widget.itemCount == 0) return;

      final int current = _controller.page?.round() ?? _controller.initialPage;
      int next = current + 1;

      if (next >= widget.itemCount) {
        if (!widget.loop) return;
        next = 0; // wrap
      }

      _controller.animateToPage(
        next,
        duration: widget.transitionDuration,
        curve: widget.curve,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      itemCount: widget.itemCount,
      physics: widget.physics,
      onPageChanged: widget.onPageChanged,
      itemBuilder: widget.itemBuilder,
    );
  }
}
