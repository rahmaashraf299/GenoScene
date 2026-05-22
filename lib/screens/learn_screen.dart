import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/learn_content.dart';
import '../theme/app_theme.dart';
import 'guide_details_screen.dart';
import 'learn_media_viewer_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.mainGradient),
      child: SafeArea(
        child: Column(
          children: [
            AnimatedEntrance(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.base,
                  AppSpacing.lg,
                  0,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryMuted,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(
                        Icons.school_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    AppSpacing.hMd,
                    Text("Learn", style: AppTypography.displaySmall),
                  ],
                ),
              ),
            ),
            AppSpacing.vBase,
            AnimatedEntrance(
              delay: const Duration(milliseconds: 60),
              child: Padding(
                padding: AppSpacing.screenH,
                child: _buildHeroCard(),
              ),
            ),
            AppSpacing.vBase,
            AnimatedEntrance(
              delay: const Duration(milliseconds: 100),
              child: Padding(
                padding: AppSpacing.screenH,
                child: _buildTabBar(),
              ),
            ),
            AppSpacing.vBase,
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildGuidesTab(),
                  _buildMediaTab(),
                ],
              ),
            ),
          ],
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
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("DNA Phenotyping Hub", style: AppTypography.titleMedium),
                AppSpacing.vXs,
                Text(
                  "Learn how GenoScene turns SNP data into trait probabilities and visual forensic clues.",
                  style: AppTypography.bodySmall.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
          AppSpacing.hMd,
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: AppColors.shadowGlow(AppColors.primary, blur: 14),
            ),
            child: const Icon(Icons.biotech, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        key: const ValueKey("learn-tabs"),
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppColors.accentGradient,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(70),
              blurRadius: 8,
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textTertiary,
        labelStyle:
            GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13),
        tabs: const [
          Tab(text: "Guides"),
          Tab(text: "Media"),
        ],
      ),
    );
  }

  Widget _buildGuidesTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      physics: const BouncingScrollPhysics(),
      itemCount: learnGuides.length,
      itemBuilder: (context, index) {
        final guide = learnGuides[index];
        return AnimatedEntrance(
          delay: Duration(milliseconds: index * 45),
          child: _PressableScale(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GuideDetailsScreen(currentIndex: index),
              ),
            ),
            child: _guideCard(guide, index),
          ),
        );
      },
    );
  }

  Widget _guideCard(GuideItem guide, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: AppColors.glassCard(
        borderColor: index == 0
            ? AppColors.primary.withAlpha(75)
            : AppColors.surfaceBorder,
        radius: AppRadius.lg,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: index == 0
                  ? AppColors.primary.withAlpha(35)
                  : AppColors.primaryMuted,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(guide.icon, color: AppColors.primary, size: 22),
          ),
          AppSpacing.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guide.title,
                  style: AppTypography.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.vXs,
                Text(
                  guide.description,
                  style: AppTypography.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          AppSpacing.hSm,
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: AppColors.surfaceBorderAccent),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
              AppSpacing.vXs,
              Text(
                guide.readTime,
                style:
                    AppTypography.caption.copyWith(color: AppColors.textHint),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMediaTab() {
    final featured = learnMediaItems.firstWhere((item) => item.isFeatured);
    final gridItems =
        learnMediaItems.where((item) => !item.isFeatured).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Featured", "Tap to watch"),
          AppSpacing.vMd,
          AnimatedEntrance(child: _featuredMediaCard(featured)),
          AppSpacing.vXl,
          _sectionTitle("Images & Guides", "${gridItems.length} items"),
          AppSpacing.vMd,
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 540 ? 3 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: columns == 2 ? 0.82 : 0.9,
                ),
                itemCount: gridItems.length,
                itemBuilder: (context, index) => AnimatedEntrance(
                  delay: Duration(milliseconds: index * 55),
                  child: _mediaCard(gridItems[index]),
                ),
              );
            },
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: Text(title, style: AppTypography.sectionHeader)),
        AppSpacing.hSm,
        Text(subtitle, style: AppTypography.labelSmall),
      ],
    );
  }

  Widget _featuredMediaCard(LearnMediaItem item) {
    return _PressableScale(
      onTap: () => _openMedia(item),
      child: Container(
        height: 210,
        decoration: AppColors.glassCard(
          borderColor: item.accentColor.withAlpha(75),
          radius: AppRadius.xl,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              item.thumbnailPath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _mediaFallback(item),
            ),
            _mediaGradientOverlay(),
            Positioned(
              left: AppSpacing.base,
              right: AppSpacing.base,
              bottom: AppSpacing.base,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _mediaBadge(item),
                  AppSpacing.vSm,
                  Text(
                    item.title,
                    style: AppTypography.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.vXs,
                  Text(
                    item.description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Positioned(
              right: AppSpacing.base,
              top: AppSpacing.base,
              child: _playGlyph(item),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mediaCard(LearnMediaItem item) {
    return _PressableScale(
      onTap: () => _openMedia(item),
      child: Container(
        decoration: AppColors.glassCard(
          borderColor: item.accentColor.withAlpha(58),
          radius: AppRadius.lg,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    item.thumbnailPath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _mediaFallback(item),
                  ),
                  _mediaGradientOverlay(light: true),
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: _playGlyph(item, compact: true),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _mediaBadge(item, compact: true),
                  AppSpacing.vXs,
                  Text(
                    item.title,
                    style: AppTypography.labelLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.vXs,
                  Text(
                    item.description,
                    style: AppTypography.caption.copyWith(height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mediaFallback(LearnMediaItem item) {
    return Container(
      color: item.accentColor.withAlpha(24),
      child: Center(
        child: Icon(item.icon, color: item.accentColor, size: 38),
      ),
    );
  }

  Widget _mediaGradientOverlay({bool light = false}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppColors.background.withAlpha(light ? 90 : 120),
            AppColors.background.withAlpha(light ? 190 : 235),
          ],
          stops: const [0, 0.55, 1],
        ),
      ),
    );
  }

  Widget _playGlyph(LearnMediaItem item, {bool compact = false}) {
    return Container(
      width: compact ? 34 : 46,
      height: compact ? 34 : 46,
      decoration: BoxDecoration(
        color: AppColors.background.withAlpha(185),
        shape: BoxShape.circle,
        border: Border.all(color: item.accentColor.withAlpha(120)),
      ),
      child: Icon(
        item.isVideo ? Icons.play_arrow_rounded : Icons.open_in_full_rounded,
        color: item.accentColor,
        size: compact ? 20 : 28,
      ),
    );
  }

  Widget _mediaBadge(LearnMediaItem item, {bool compact = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 9,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: item.accentColor.withAlpha(35),
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(color: item.accentColor.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, color: item.accentColor, size: compact ? 12 : 14),
          AppSpacing.hXs,
          Text(
            item.duration,
            style: AppTypography.badge.copyWith(
              color: item.accentColor,
              fontSize: compact ? 9 : 10,
            ),
          ),
        ],
      ),
    );
  }

  void _openMedia(LearnMediaItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LearnMediaViewerScreen(item: item),
      ),
    );
  }
}

class _PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressableScale({required this.child, required this.onTap});

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  double _scale = 1;

  void _setScale(double value) {
    if (mounted) setState(() => _scale = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setScale(0.98),
      onTapUp: (_) => _setScale(1),
      onTapCancel: () => _setScale(1),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}
