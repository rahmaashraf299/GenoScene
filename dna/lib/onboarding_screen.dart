import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'screens/auth_screen.dart';
import 'theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _controller = PageController();
  int _currentPage = 0;

  late final AnimationController _buttonCtrl;
  late final Animation<double> _buttonScale;

  final List<_OnboardingPageData> _pages = const [
    _OnboardingPageData(
      imagePath: 'assets/images/onboarding1.png',
      tag: 'Forensic Genetics',
      title: 'No Match?\nVisualize the Suspect',
      description:
          'Generate a visual profile directly from raw DNA evidence — no database needed.',
    ),
    _OnboardingPageData(
      imagePath: 'assets/images/onboarding2.png',
      tag: 'Disaster Response',
      title: 'Identify\nUnknown Remains',
      description:
          'Support disaster response and missing persons cases by identifying victims via DNA.',
    ),
    _OnboardingPageData(
      imagePath: 'assets/images/onboarding3.png',
      tag: 'AI Phenotyping',
      title: 'From Genes\nto Traits',
      description:
          'See how 40+ genetic markers translate into physical appearance with AI precision.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _buttonCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _buttonScale = Tween<double>(begin: 1.0, end: 0.94).animate(
        CurvedAnimation(parent: _buttonCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    _buttonCtrl.dispose();
    super.dispose();
  }

  void _handleNext() {
    final bool isLastPage = _currentPage == _pages.length - 1;
    if (!isLastPage) {
      _controller.nextPage(
        duration: AppMotion.emphasis,
        curve: AppMotion.curve,
      );
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const AuthScreen(),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: animation,
            child: child,
          ),
          transitionDuration: AppMotion.standard,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF050D1E), Color(0xFF0A1628), Color(0xFF112240)],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
              child: const SizedBox.expand(),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                AppSpacing.vBase,

                // ── Page images ──
                Expanded(
                  child: Padding(
                    padding: AppSpacing.screenH,
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: _pages.length,
                      onPageChanged: (index) =>
                          setState(() => _currentPage = index),
                      itemBuilder: (context, index) {
                        final page = _pages[index];
                        return Semantics(
                          label: page.title,
                          image: true,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.xxxl),
                            child: Image.asset(
                              page.imagePath,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                AppSpacing.vXl,

                // ── Glassmorphism bottom card ──
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 28),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.xxl + 4),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                      child: Container(
                        width: double.infinity,
                        padding: AppSpacing.cardLarge,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(AppRadius.xxl + 4),
                          color: AppColors.textPrimary.withAlpha(16),
                          border: Border.all(
                            color: AppColors.textPrimary.withAlpha(40),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Tag chip
                            AnimatedEntrance(
                              key: ValueKey('tag_$_currentPage'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(35),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.xs),
                                  border: Border.all(
                                      color: AppColors.primary.withAlpha(80)),
                                ),
                                child: Text(
                                  _pages[_currentPage].tag,
                                  style: AppTypography.badge,
                                ),
                              ),
                            ),

                            AppSpacing.vMd,

                            // Title
                            AnimatedEntrance(
                              key: ValueKey('title_$_currentPage'),
                              delay: const Duration(milliseconds: 40),
                              child: Text(
                                _pages[_currentPage].title,
                                style: AppTypography.displayLarge,
                              ),
                            ),

                            AppSpacing.vSm,

                            // Description
                            AnimatedEntrance(
                              key: ValueKey('desc_$_currentPage'),
                              delay: const Duration(milliseconds: 80),
                              child: Text(
                                _pages[_currentPage].description,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textPrimary.withAlpha(200),
                                  height: 1.5,
                                ),
                              ),
                            ),

                            AppSpacing.vLg,

                            // Indicator + button row
                            Row(
                              children: [
                                Expanded(
                                  child: SmoothPageIndicator(
                                    controller: _controller,
                                    count: _pages.length,
                                    effect: ExpandingDotsEffect(
                                      dotHeight: 4,
                                      dotWidth: 20,
                                      spacing: AppSpacing.sm,
                                      radius: 4,
                                      dotColor:
                                          AppColors.textPrimary.withAlpha(50),
                                      activeDotColor: AppColors.primary,
                                      expansionFactor: 3,
                                    ),
                                  ),
                                ),
                                AppSpacing.hBase,
                                Semantics(
                                  button: true,
                                  label: isLastPage ? 'Start' : 'Next page',
                                  child: GestureDetector(
                                    onTapDown: (_) => _buttonCtrl.forward(),
                                    onTapUp: (_) {
                                      _buttonCtrl.reverse();
                                      _handleNext();
                                    },
                                    onTapCancel: () => _buttonCtrl.reverse(),
                                    child: ScaleTransition(
                                      scale: _buttonScale,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 13),
                                        decoration: BoxDecoration(
                                          borderRadius: AppRadius.circle,
                                          gradient: const LinearGradient(
                                            colors: [
                                              AppColors.primary,
                                              AppColors.secondary
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withAlpha(90),
                                              blurRadius: 16,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              isLastPage ? 'Get Started' : 'Next',
                                              style: AppTypography.labelLarge
                                                  .copyWith(
                                                      letterSpacing: 0.5,
                                                      fontWeight:
                                                          FontWeight.w700),
                                            ),
                                            if (!isLastPage) ...[
                                              AppSpacing.hXs,
                                              const Icon(
                                                Icons.arrow_forward_rounded,
                                                size: 16,
                                                color: AppColors.textPrimary,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPageData {
  final String imagePath;
  final String tag;
  final String title;
  final String description;

  const _OnboardingPageData({
    required this.imagePath,
    required this.tag,
    required this.title,
    required this.description,
  });
}
