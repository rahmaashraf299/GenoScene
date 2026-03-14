import 'dart:math';
import 'package:flutter/material.dart';

/// Animated DNA double-helix indicator.
///
/// Pure Flutter — uses [CustomPainter] + [AnimationController].
/// Works as a drop-in replacement for [CircularProgressIndicator].
///
/// ```dart
/// const DnaLoadingIndicator()            // default 60×120
/// const DnaLoadingIndicator(size: 40)    // mini for buttons
/// ```
class DnaLoadingIndicator extends StatefulWidget {
  /// Logical width of the helix. Height = size × 2.
  final double size;

  /// Strand colours (left / right).
  final Color color1;
  final Color color2;

  /// Colour of the horizontal rungs connecting the two strands.
  final Color rungColor;

  const DnaLoadingIndicator({
    super.key,
    this.size = 60,
    this.color1 = const Color(0xFF4DD0E1), // cyan
    this.color2 = const Color(0xFF535FF7), // indigo
    this.rungColor = const Color(0x55FFFFFF),
  });

  @override
  State<DnaLoadingIndicator> createState() => _DnaLoadingIndicatorState();
}

class _DnaLoadingIndicatorState extends State<DnaLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        size: Size(widget.size, widget.size * 2),
        painter: _DnaHelixPainter(
          progress: _ctrl.value,
          color1: widget.color1,
          color2: widget.color2,
          rungColor: widget.rungColor,
        ),
      ),
    );
  }
}

class _DnaHelixPainter extends CustomPainter {
  final double progress; // 0 → 1
  final Color color1;
  final Color color2;
  final Color rungColor;

  _DnaHelixPainter({
    required this.progress,
    required this.color1,
    required this.color2,
    required this.rungColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final amplitude = size.width * 0.38;
    final steps = 28; // smoothness
    final rungCount = 8;
    final phase = progress * 2 * pi;

    // Glow paint helper
    Paint glowPaint(Color c, double width) => Paint()
      ..color = c
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    Paint solidPaint(Color c, double width) => Paint()
      ..color = c
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Build strand paths
    final path1 = Path();
    final path2 = Path();
    final points1 = <Offset>[];
    final points2 = <Offset>[];

    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final y = t * size.height;
      final angle = t * 4 * pi + phase;
      final x1 = centerX + sin(angle) * amplitude;
      final x2 = centerX - sin(angle) * amplitude;

      points1.add(Offset(x1, y));
      points2.add(Offset(x2, y));

      if (i == 0) {
        path1.moveTo(x1, y);
        path2.moveTo(x2, y);
      } else {
        path1.lineTo(x1, y);
        path2.lineTo(x2, y);
      }
    }

    // Draw rungs (horizontal bars connecting the two strands)
    final rungPaint = Paint()
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    for (int r = 0; r < rungCount; r++) {
      final t = (r + 0.5) / rungCount;
      final idx = (t * steps).round().clamp(0, steps);
      final p1 = points1[idx];
      final p2 = points2[idx];

      // Depth: strand in front is brighter, strand behind is dimmer
      final angle = t * 4 * pi + phase;
      final depth = cos(angle); // -1 → 1

      // Rung colour fades based on whether it's "behind"
      final rungOpacity = (0.3 + 0.5 * depth.abs()).clamp(0.0, 1.0);
      rungPaint.color = rungColor.withValues(alpha: rungOpacity);
      canvas.drawLine(p1, p2, rungPaint);

      // Draw nucleotide dots at each end
      final dotR = 3.0;
      canvas.drawCircle(
        p1,
        dotR,
        Paint()..color = color1.withValues(alpha: (0.5 + 0.5 * depth).clamp(0.2, 1.0)),
      );
      canvas.drawCircle(
        p2,
        dotR,
        Paint()..color = color2.withValues(alpha: (0.5 - 0.5 * depth).clamp(0.2, 1.0)),
      );
    }

    // Draw strands with glow
    canvas.drawPath(path1, glowPaint(color1.withValues(alpha: 0.3), 4));
    canvas.drawPath(path1, solidPaint(color1, 2.5));

    canvas.drawPath(path2, glowPaint(color2.withValues(alpha: 0.3), 4));
    canvas.drawPath(path2, solidPaint(color2, 2.5));
  }

  @override
  bool shouldRepaint(_DnaHelixPainter old) => old.progress != progress;
}
