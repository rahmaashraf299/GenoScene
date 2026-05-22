import 'package:flutter/material.dart';

import '../data/learn_content.dart';
import '../theme/app_theme.dart';

class GuideDetailsScreen extends StatelessWidget {
  final int currentIndex;

  const GuideDetailsScreen({
    super.key,
    required this.currentIndex,
  });

  GuideItem get guide => learnGuides[currentIndex];

  @override
  Widget build(BuildContext context) {
    final canGoPrevious = currentIndex > 0;
    final canGoNext = currentIndex < learnGuides.length - 1;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Guide", style: AppTypography.titleLarge),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Semantics(
          button: true,
          label: 'Go back',
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.textPrimary,
                size: 16,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.base,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedEntrance(child: _buildHeroCard()),
                      AppSpacing.vXl,
                      AnimatedEntrance(
                        delay: const Duration(milliseconds: 120),
                        child: _buildArticleCard(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              _buildBottomNav(context, canGoPrevious, canGoNext),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardLarge,
      decoration: BoxDecoration(
        gradient: AppColors.elevatedCardGradient,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.surfaceBorderAccent),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(30),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: AppColors.shadowGlow(AppColors.primary),
            ),
            child: Icon(guide.icon, color: Colors.white, size: 30),
          ),
          AppSpacing.vBase,
          Text(
            guide.title,
            style: AppTypography.displaySmall,
            textAlign: TextAlign.center,
          ),
          AppSpacing.vSm,
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _heroBadge(Icons.schedule_rounded, guide.readTime),
              _heroBadge(
                Icons.article_outlined,
                "${currentIndex + 1} of ${learnGuides.length}",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryMuted,
        borderRadius: AppRadius.chip,
        border: Border.all(color: AppColors.surfaceBorderAccent),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 13),
          AppSpacing.hXs,
          Text(text, style: AppTypography.badge),
        ],
      ),
    );
  }

  Widget _buildArticleCard() {
    return Container(
      decoration: AppColors.glassCard(
        borderColor: AppColors.surfaceBorder,
        radius: AppRadius.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryMuted,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadius.lg),
                topRight: Radius.circular(AppRadius.lg),
              ),
              border: const Border(
                bottom: BorderSide(color: AppColors.surfaceBorderAccent),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.article_outlined,
                  color: AppColors.primary,
                  size: 18,
                ),
                AppSpacing.hSm,
                Text(
                  "Article",
                  style: AppTypography.titleSmall
                      .copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Text(
              guide.content,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(
    BuildContext context,
    bool canGoPrevious,
    bool canGoNext,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(245),
        border: const Border(
          top: BorderSide(color: AppColors.surfaceBorder),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _navButton(
              label: "Previous",
              icon: Icons.arrow_back_rounded,
              enabled: canGoPrevious,
              onTap: () => _goToGuide(context, currentIndex - 1),
            ),
          ),
          AppSpacing.hMd,
          Expanded(
            child: _navButton(
              label: "Next",
              icon: Icons.arrow_forward_rounded,
              enabled: canGoNext,
              isPrimary: true,
              onTap: () => _goToGuide(context, currentIndex + 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navButton({
    required String label,
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    final foreground = enabled
        ? (isPrimary ? AppColors.background : AppColors.textPrimary)
        : AppColors.textDisabled;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedOpacity(
          opacity: enabled ? 1 : 0.55,
          duration: AppMotion.fast,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              gradient: isPrimary && enabled ? AppColors.accentGradient : null,
              color: isPrimary && enabled ? null : AppColors.surfaceCard,
              borderRadius: AppRadius.button,
              border: Border.all(
                color: enabled
                    ? AppColors.surfaceBorderAccent
                    : AppColors.surfaceBorder,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isPrimary) Icon(icon, color: foreground, size: 18),
                if (!isPrimary) AppSpacing.hSm,
                Flexible(
                  child: Text(
                    label,
                    style: AppTypography.labelLarge.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isPrimary) AppSpacing.hSm,
                if (isPrimary) Icon(icon, color: foreground, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goToGuide(BuildContext context, int index) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GuideDetailsScreen(currentIndex: index),
      ),
    );
  }
}
