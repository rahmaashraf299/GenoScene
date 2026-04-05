import 'package:flutter/material.dart';

/// Design-token color palette for GenoScene.
/// Usage: `AppColors.primary` — never use raw hex in screens.
abstract class AppColors {
  // ── Backgrounds ──
  static const Color background = Color(0xFF070F1C);
  static const Color backgroundMid = Color(0xFF0A1628);
  static const Color surface = Color(0xFF111E33);
  static const Color surfaceElevated = Color(0xFF162544);

  // ── Cards / Glass ──
  static const Color surfaceCard = Color(0x14FFFFFF);       // white 8%
  static const Color surfaceCardStrong = Color(0x1FFFFFFF); // white 12%
  static const Color surfaceCardHover = Color(0x29FFFFFF);  // white 16%
  static const Color surfaceBorder = Color(0x1AFFFFFF);     // white 10%
  static const Color surfaceBorderSubtle = Color(0x0DFFFFFF); // white 5%
  static const Color surfaceBorderAccent = Color(0x334DD0E1); // cyan 20%

  // ── Primary (Cyan) ──
  static const Color primary = Color(0xFF4DD0E1);
  static const Color primaryLight = Color(0xFF80DEEA);
  static const Color primaryMuted = Color(0x294DD0E1); // 16%
  static const Color primarySubtle = Color(0x144DD0E1); // 8%

  // ── Secondary (Indigo) ──
  static const Color secondary = Color(0xFF5C6BC0);
  static const Color secondaryLight = Color(0xFF7986CB);
  static const Color secondaryMuted = Color(0x1F5C6BC0); // 12%

  // ── Accent / Status ──
  static const Color success = Color(0xFF4CAF82);
  static const Color successMuted = Color(0x194CAF82);
  static const Color warning = Color(0xFFFFB74D);
  static const Color warningMuted = Color(0x19FFB74D);
  static const Color error = Color(0xFFEF5350);
  static const Color errorMuted = Color(0x19EF5350);
  static const Color info = Color(0xFF42A5F5);
  static const Color infoMuted = Color(0x1942A5F5);

  // ── Feature-specific ──
  static const Color premiumGold = Color(0xFFFFD700);
  static const Color hairPurple = Color(0xFFAB47BC);

  // ── Text ──
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF); // 70%
  static const Color textTertiary = Color(0x73FFFFFF);  // 45%
  static const Color textDisabled = Color(0x4DFFFFFF);  // 30%
  static const Color textHint = Color(0x40FFFFFF);      // 25%

  // ── Gradients ──
  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [background, surface],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [surfaceElevated, surface],
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient accentGradientVertical = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient elevatedCardGradient = LinearGradient(
    colors: [Color(0xFF1A3A5C), Color(0xFF0F2440)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient ctaGradient = LinearGradient(
    colors: [Color(0xFF0D2137), Color(0xFF1A3A5C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0A1628), Color(0xFF1A3A5C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Shadows ──
  static const List<BoxShadow> shadowSm = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2)),
  ];
  static const List<BoxShadow> shadowMd = [
    BoxShadow(color: Color(0x26000000), blurRadius: 16, offset: Offset(0, 4)),
  ];
  static const List<BoxShadow> shadowLg = [
    BoxShadow(color: Color(0x33000000), blurRadius: 24, offset: Offset(0, 8)),
  ];
  static List<BoxShadow> shadowGlow(Color color, {double blur = 16}) => [
        BoxShadow(color: color.withAlpha(80), blurRadius: blur),
      ];

  // ── Glass helper ──
  static BoxDecoration glassCard({
    Color borderColor = surfaceBorder,
    double radius = 20,
    Color? backgroundColor,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? surfaceCard,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor, width: 1),
      boxShadow: shadows,
    );
  }
}
