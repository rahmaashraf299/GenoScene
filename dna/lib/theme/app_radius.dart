import 'package:flutter/material.dart';

/// Border radius tokens.
abstract class AppRadius {
  // ── Raw values ──
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  // ── Pre-built BorderRadius ──
  static final BorderRadius chip = BorderRadius.circular(sm);
  static final BorderRadius button = BorderRadius.circular(md);
  static final BorderRadius card = BorderRadius.circular(xl);
  static final BorderRadius cardLg = BorderRadius.circular(xxl);
  static final BorderRadius banner = BorderRadius.circular(xxl);
  static final BorderRadius circle = BorderRadius.circular(100);
}
