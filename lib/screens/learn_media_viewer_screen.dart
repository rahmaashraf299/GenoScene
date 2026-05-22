import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../data/learn_content.dart';
import '../theme/app_theme.dart';

class LearnMediaViewerScreen extends StatefulWidget {
  final LearnMediaItem item;

  const LearnMediaViewerScreen({
    super.key,
    required this.item,
  });

  @override
  State<LearnMediaViewerScreen> createState() => _LearnMediaViewerScreenState();
}

class _LearnMediaViewerScreenState extends State<LearnMediaViewerScreen> {
  VideoPlayerController? _videoController;
  Future<void>? _initializeVideo;

  @override
  void initState() {
    super.initState();
    if (widget.item.isVideo) {
      _videoController = VideoPlayerController.asset(widget.item.assetPath);
      _initializeVideo = _videoController!.initialize().then((_) {
        _videoController!.setLooping(false);
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.item.isVideo ? "Video" : "Image",
            style: AppTypography.titleLarge),
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
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.base,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: widget.item.isVideo
                      ? _buildVideoPlayer()
                      : _buildImageViewer(),
                ),
              ),
              _buildInfoPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    final controller = _videoController;
    if (controller == null || _initializeVideo == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<void>(
      future: _initializeVideo,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          );
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: AppColors.glassCard(
                borderColor: widget.item.accentColor.withAlpha(90),
                radius: AppRadius.xl,
              ),
              clipBehavior: Clip.antiAlias,
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(controller),
                    if (!controller.value.isPlaying)
                      _roundControlButton(
                        Icons.play_arrow_rounded,
                        _togglePlayback,
                      ),
                  ],
                ),
              ),
            ),
            AppSpacing.vBase,
            VideoProgressIndicator(
              controller,
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: widget.item.accentColor,
                bufferedColor: AppColors.surfaceCardStrong,
                backgroundColor: AppColors.surfaceBorder,
              ),
            ),
            AppSpacing.vBase,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _roundControlButton(
                  controller.value.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  _togglePlayback,
                  compact: true,
                ),
                AppSpacing.hMd,
                _roundControlButton(
                  Icons.replay_rounded,
                  () {
                    controller.seekTo(Duration.zero);
                    controller.play();
                    setState(() {});
                  },
                  compact: true,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageViewer() {
    return Container(
      width: double.infinity,
      decoration: AppColors.glassCard(
        borderColor: widget.item.accentColor.withAlpha(90),
        radius: AppRadius.xl,
      ),
      clipBehavior: Clip.antiAlias,
      child: InteractiveViewer(
        minScale: 0.8,
        maxScale: 4,
        child: Center(
          child: Image.asset(
            widget.item.assetPath,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.broken_image_outlined,
              color: AppColors.textTertiary,
              size: 40,
            ),
          ),
        ),
      ),
    );
  }

  Widget _roundControlButton(
    IconData icon,
    VoidCallback onTap, {
    bool compact = false,
  }) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: compact ? 44 : 62,
          height: compact ? 44 : 62,
          decoration: BoxDecoration(
            gradient: AppColors.accentGradient,
            shape: BoxShape.circle,
            boxShadow: AppColors.shadowGlow(widget.item.accentColor),
          ),
          child: Icon(
            icon,
            color: AppColors.background,
            size: compact ? 24 : 34,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(245),
        border: const Border(top: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.item.accentColor.withAlpha(35),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  widget.item.icon,
                  color: widget.item.accentColor,
                  size: 18,
                ),
              ),
              AppSpacing.hMd,
              Expanded(
                child: Text(
                  widget.item.title,
                  style: AppTypography.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppSpacing.hSm,
              _typeBadge(),
            ],
          ),
          AppSpacing.vSm,
          Text(
            widget.item.description,
            style: AppTypography.bodySmall.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _typeBadge() {
    final label = widget.item.isVideo ? "Video" : "Image";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: widget.item.accentColor.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(color: widget.item.accentColor.withAlpha(70)),
      ),
      child: Text(
        label,
        style: AppTypography.badge.copyWith(color: widget.item.accentColor),
      ),
    );
  }

  void _togglePlayback() {
    final controller = _videoController;
    if (controller == null) return;

    setState(() {
      controller.value.isPlaying ? controller.pause() : controller.play();
    });
  }
}
