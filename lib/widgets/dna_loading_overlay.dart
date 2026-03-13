import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dna_loading_indicator.dart';

/// Full-screen semi-transparent overlay with animated DNA helix.
///
/// Usage (as a dialog):
/// ```dart
/// DnaLoadingOverlay.show(context, message: "Analyzing DNA...");
/// // ... do async work ...
/// DnaLoadingOverlay.hide(context);
/// ```
///
/// Or as a widget inside a Stack:
/// ```dart
/// if (_isLoading) const DnaLoadingOverlay(message: "Loading...")
/// ```
class DnaLoadingOverlay extends StatelessWidget {
  final String message;
  final String? subMessage;

  const DnaLoadingOverlay({
    super.key,
    this.message = "Loading...",
    this.subMessage,
  });

  /// Show as a modal barrier (blocks interaction behind it).
  static void show(
    BuildContext context, {
    String message = "Loading...",
    String? subMessage,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (_) => DnaLoadingOverlay(
        message: message,
        subMessage: subMessage,
      ),
    );
  }

  /// Pop the overlay dialog.
  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Material(
        color: Colors.transparent,
        child: Container(
          color: const Color(0xFF0A1628).withValues(alpha: 0.92),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // DNA Helix animation
                const DnaLoadingIndicator(size: 60),

                const SizedBox(height: 32),

                // Main message
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                if (subMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subMessage!,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF4DD0E1),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 24),

                // Pulsing dots bar
                const _PulsingDots(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Three dots that pulse sequentially — a subtle secondary indicator.
class _PulsingDots extends StatefulWidget {
  const _PulsingDots();

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            // Each dot is offset by 0.2 in phase
            final t = (_ctrl.value + i * 0.2) % 1.0;
            final scale = 0.5 + 0.5 * (t < 0.5 ? t * 2 : 2 - t * 2);
            final opacity = 0.3 + 0.7 * scale;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF4DD0E1).withValues(alpha: opacity),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
