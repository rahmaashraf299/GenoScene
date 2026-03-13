import 'package:flutter/material.dart';

/// Spacing scale based on 4dp increments.
/// Usage: `SizedBox(height: AppSpacing.md)` or `padding: AppSpacing.screenH`
abstract class AppSpacing {
  // ── Scale ──
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // ── Reusable EdgeInsets ──
  static const EdgeInsets screenH =
      EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets screenAll =
      EdgeInsets.all(xl);
  static const EdgeInsets cardAll =
      EdgeInsets.all(base);
  static const EdgeInsets cardLarge =
      EdgeInsets.all(lg);
  static const EdgeInsets cardInner =
      EdgeInsets.all(18);

  // ── SizedBox shortcuts (use as const children) ──
  static const SizedBox vXs = SizedBox(height: xs);
  static const SizedBox vSm = SizedBox(height: sm);
  static const SizedBox vMd = SizedBox(height: md);
  static const SizedBox vBase = SizedBox(height: base);
  static const SizedBox vLg = SizedBox(height: lg);
  static const SizedBox vXl = SizedBox(height: xl);
  static const SizedBox vXxl = SizedBox(height: xxl);
  static const SizedBox vSection = SizedBox(height: 28);

  static const SizedBox hXs = SizedBox(width: xs);
  static const SizedBox hSm = SizedBox(width: sm);
  static const SizedBox hMd = SizedBox(width: md);
  static const SizedBox hBase = SizedBox(width: base);
  static const SizedBox hLg = SizedBox(width: lg);
}
