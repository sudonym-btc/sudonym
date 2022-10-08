import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sudonym/presentation/index.dart';

import 'measurable.dart';

class ScreenSlideable extends StatefulWidget {
  final Widget top;
  final Widget bottom;
  const ScreenSlideable({required this.top, required this.bottom, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ScreenSlideableState();
}

class _ScreenSlideableState extends State<ScreenSlideable> {
  Size topSize = Size.zero;

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Positioned.fill(
          child: Column(
        children: [
          MeasureSize(
              onChange: (Size s) {
                setState(() {
                  topSize = s;
                });
              },
              child: widget.top),
        ],
      )),
      BottomSlideable(
          minHeight: MediaQuery.of(context).size.height -
              topSize.height -
              (Scaffold.of(context).appBarMaxHeight ?? 0) -
              MediaQuery.of(context).padding.top -
              50,
          child: widget.bottom),
    ]);
  }
}

class BottomSlideable extends StatefulWidget {
  final double minHeight;
  final Widget child;

  const BottomSlideable(
      {Key? key, required this.minHeight, required this.child})
      : super(key: key);

  @override
  _BottomSlideableState createState() => _BottomSlideableState();
}

class _BottomSlideableState extends State<BottomSlideable>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  double minHeightGetter() => widget.minHeight;

  double get maxHeight =>
      MediaQuery.of(context).size.height -
      (Scaffold.of(context).appBarMaxHeight ?? 0) -
      MediaQuery.of(context).padding.top -
      20;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: animationDuration,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double lerp(double min, double max) =>
      lerpDouble(min, max, _controller.value)!;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          height: lerp(minHeightGetter(), maxHeight),
          left: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: _toggle,
            onVerticalDragUpdate: _handleDragUpdate,
            onVerticalDragEnd: _handleDragEnd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }

  void _toggle() {
    final bool isOpen = _controller.status == AnimationStatus.completed;
    _controller.fling(
        velocity: isOpen ? -2 : 2); //<-- ...snap the sheet in proper direction
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _controller.value -= details.primaryDelta! / maxHeight;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_controller.isAnimating ||
        _controller.status == AnimationStatus.completed) return;

    final double flingVelocity =
        details.velocity.pixelsPerSecond.dy / maxHeight;
    if (flingVelocity < 0.0) {
      _controller.fling(velocity: math.max(2.0, -flingVelocity));
    } else if (flingVelocity > 0.0) {
      _controller.fling(velocity: math.min(-2.0, -flingVelocity));
    } else {
      _controller.fling(velocity: _controller.value < 0.5 ? -2.0 : 2.0);
    }
  }
}
