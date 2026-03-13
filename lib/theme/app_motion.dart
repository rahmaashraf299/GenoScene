import 'package:flutter/material.dart';

/// Animation duration and curve tokens.
abstract class AppMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 220);
  static const Duration emphasis = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 500);
  static const Curve curve = Curves.easeOutCubic;
  static const Curve curveIn = Curves.easeInCubic;
  static const Curve spring = Curves.elasticOut;
}

/// Reusable fade+slide entrance animation for sections/cards.
///
/// ```dart
/// AnimatedEntrance(
///   delay: Duration(milliseconds: 100),
///   child: MyCard(),
/// )
/// ```
class AnimatedEntrance extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset slideOffset;

  const AnimatedEntrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppMotion.standard,
    this.slideOffset = const Offset(0, 0.04),
  });

  @override
  State<AnimatedEntrance> createState() => _AnimatedEntranceState();
}

class _AnimatedEntranceState extends State<AnimatedEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(parent: _controller, curve: AppMotion.curve);
    _slide = Tween<Offset>(begin: widget.slideOffset, end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: AppMotion.curve));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}

/// Scale + fade entrance — for cards/buttons that pop in.
class ScaleEntrance extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const ScaleEntrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppMotion.standard,
  });

  @override
  State<ScaleEntrance> createState() => _ScaleEntranceState();
}

class _ScaleEntranceState extends State<ScaleEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scale = Tween<double>(begin: 0.88, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: AppMotion.curve));
    _opacity = CurvedAnimation(parent: _controller, curve: AppMotion.curve);

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
