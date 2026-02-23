import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class FadeInOnScroll extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const FadeInOnScroll(
      {super.key, required this.child, this.delay = Duration.zero});

  @override
  State<StatefulWidget> createState() => _FadeInOnScrollState();
}

class _FadeInOnScrollState extends State<FadeInOnScroll>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _opacity = Tween<double>(begin: 0, end: 1).animate(curved);
    _offset = Tween<Offset>(begin: const Offset(0, 30), end: Offset.zero)
        .animate(curved);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    ;
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (_hasAnimated) return;
    if (info.visibleFraction >= 0.1) {
      _hasAnimated = true;
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('fade_${widget.key ?? identityHashCode(this)}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacity.value,
            child: Transform.translate(
              offset: _offset.value,
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
