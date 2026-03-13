import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GuideDetailsScreen extends StatelessWidget {
  final String title;
  final String content;
  final String readTime;
  final IconData icon;

  const GuideDetailsScreen({
    super.key,
    required this.title,
    required this.content,
    required this.readTime,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
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
              child: const Icon(Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary, size: 16),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.background, AppColors.surface],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero card ──
                AnimatedEntrance(
                  child: Container(
                    width: double.infinity,
                    padding: AppSpacing.cardLarge,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A3A5C), Color(0xFF0F2440)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: AppRadius.card,
                      border:
                          Border.all(color: AppColors.surfaceBorderAccent),
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
                        // Icon with gradient container
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius:
                                BorderRadius.circular(AppRadius.md),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(80),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child:
                              Icon(icon, color: Colors.white, size: 30),
                        ),

                        AppSpacing.vBase,

                        Text(
                          title,
                          style: AppTypography.displaySmall,
                          textAlign: TextAlign.center,
                        ),

                        AppSpacing.vSm,

                        // Read-time badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: AppColors.primaryMuted,
                            borderRadius: AppRadius.chip,
                            border: Border.all(
                                color: AppColors.surfaceBorderAccent),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.schedule_rounded,
                                  color: AppColors.primary, size: 13),
                              AppSpacing.hXs,
                              Text(
                                readTime,
                                style: AppTypography.badge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                AppSpacing.vXl,

                // ── Article body ──
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 120),
                  child: Container(
                    decoration: AppColors.glassCard(
                      borderColor: AppColors.surfaceBorder,
                      radius: AppRadius.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section header band
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.base,
                              vertical: AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.primaryMuted,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(AppRadius.lg),
                              topRight: Radius.circular(AppRadius.lg),
                            ),
                            border: const Border(
                                bottom: BorderSide(
                                    color: AppColors.surfaceBorderAccent)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.article_outlined,
                                  color: AppColors.primary, size: 18),
                              AppSpacing.hSm,
                              Text("Article",
                                  style: AppTypography.titleSmall
                                      .copyWith(color: AppColors.primary)),
                            ],
                          ),
                        ),

                        // Body text
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.base),
                          child: Text(
                            content,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
