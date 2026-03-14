import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../onboarding_screen.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _barCtrl;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _glowOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _barCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack));
    _logoOpacity = CurvedAnimation(
        parent: _logoCtrl, curve: const Interval(0.0, 0.6));
    _glowOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.6), weight: 50),
    ]).animate(_logoCtrl);

    _textOpacity =
        CurvedAnimation(parent: _textCtrl, curve: AppMotion.curve);
    _textSlide = Tween<Offset>(
            begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _textCtrl, curve: AppMotion.curve));

    // Sequence: logo → text → bar → navigate
    _logoCtrl.forward().then((_) {
      _textCtrl.forward();
      _barCtrl.forward();
    });

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const OnboardingScreen(),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: animation,
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _barCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light
          .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background,
                Color(0xFF0E1F38),
                AppColors.surface,
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── Logo + Glow ──
                Center(
                  child: FadeTransition(
                    opacity: _logoOpacity,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: AnimatedBuilder(
                        animation: _glowOpacity,
                        builder: (_, child) => Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer glow
                            Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withAlpha(
                                        (110 * _glowOpacity.value).toInt()),
                                    blurRadius: 70,
                                    spreadRadius: 20,
                                  ),
                                  BoxShadow(
                                    color: AppColors.secondary.withAlpha(
                                        (60 * _glowOpacity.value).toInt()),
                                    blurRadius: 100,
                                    spreadRadius: 30,
                                  ),
                                ],
                              ),
                            ),
                            // Logo — no border circle
                            SizedBox(
                              width: 200,
                              height: 200,
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/genoscene_logo.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                AppSpacing.vXxl,

                // ── App Name ──
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textOpacity,
                    child: Column(
                      children: [
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                            children: [
                              TextSpan(
                                text: 'Geno',
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                              TextSpan(
                                text: 'Scene',
                                style: TextStyle(color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.vSm,
                        Text(
                          'We Decipher The Code of Life',
                          style: AppTypography.bodyMedium.copyWith(
                            letterSpacing: 0.3,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // ── Loading bar ──
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 60, vertical: 40),
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _barCtrl,
                        builder: (_, __) => ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: _barCtrl.value,
                            backgroundColor:
                                AppColors.surfaceBorder,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                            minHeight: 3,
                          ),
                        ),
                      ),
                      AppSpacing.vMd,
                      Text(
                        'Initializing...',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textHint,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
