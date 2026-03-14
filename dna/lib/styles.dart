import 'package:flutter/material.dart';

// Re-export new token system so existing `import '../styles.dart'` still works.
export 'theme/app_theme.dart';

/// Legacy style helpers — kept for backward compatibility.
/// New code should use AppColors, AppSpacing, AppRadius, AppTypography directly.
class AppStyle {
  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0A1628),
      Color(0xFF1C2E4A),
    ],
  );

  static BoxDecoration glassDecoration({
    double borderRadius = 20.0,
    double opacity = 0.06,
    Color borderColor = const Color(0x19FFFFFF),
  }) {
    return BoxDecoration(
      color: Color.fromRGBO(255, 255, 255, opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor),
    );
  }

  static Widget glassCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    double borderRadius = 20.0,
    double opacity = 0.06,
    Color borderColor = const Color(0x19FFFFFF),
  }) {
    return Container(
      padding: padding,
      decoration: glassDecoration(
        borderRadius: borderRadius,
        opacity: opacity,
        borderColor: borderColor,
      ),
      child: child,
    );
  }
}
