import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../theme/app_theme.dart';
import '../providers/user_provider.dart';
import '../models/report_item.dart';

class AnalysisResultScreen extends StatefulWidget {
  final Map<String, double> hairResults;
  final Map<String, double> eyeResults;
  final Map<String, double> skinResults;
  final String? analysisId;

  const AnalysisResultScreen({
    super.key,
    required this.hairResults,
    required this.eyeResults,
    required this.skinResults,
    this.analysisId,
  });

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen>
    with TickerProviderStateMixin {
  bool _isGeneratingFace = false;
  bool _faceGenerated = false;
  Uint8List? _faceImageBytes;
  String? _faceError;
  late AnimationController _pulseController;
  late AnimationController _stageController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _stageController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _stageController.dispose();
    super.dispose();
  }

  // ─── Logic ───────────────────────────────────────────────────────────────
  MapEntry<String, double> _getTopTrait(Map<String, double> data) {
    if (data.isEmpty) return const MapEntry("Unknown", 0.0);
    return data.entries.reduce((a, b) => a.value > b.value ? a : b);
  }

  String _mapHairColor(String trait) {
    switch (trait.toLowerCase()) {
      case 'blond':
        return 'blonde';
      case 'red':
        return 'red ginger';
      case 'brown':
        return 'brown';
      case 'black':
        return 'black';
      default:
        return trait.toLowerCase();
    }
  }

  String _mapEyeColor(String trait) {
    switch (trait.toLowerCase()) {
      case 'intermediate':
        return 'hazel green';
      case 'blue':
        return 'blue';
      case 'brown':
        return 'brown';
      default:
        return trait.toLowerCase();
    }
  }

  String _mapSkinTone(String trait) {
    switch (trait.toLowerCase()) {
      case 'light':
      case 'pale':
        return 'fair pale';
      case 'verypale':
        return 'very fair pale';
      case 'intermediate':
        return 'medium olive';
      case 'dark':
        return 'dark brown';
      case 'darktoblack':
        return 'very dark deep brown';
      default:
        return trait.toLowerCase();
    }
  }

  Future<void> _startFaceGeneration() async {
    if (widget.analysisId == null) return;

    final topHair = _getTopTrait(widget.hairResults);
    final topEye = _getTopTrait(widget.eyeResults);
    final topSkin = _getTopTrait(widget.skinResults);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.generateFaceAI(
      analysisId: widget.analysisId!,
      hair: topHair.key,
      eye: topEye.key,
      skin: topSkin.key,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Generation failed. Please try again later.")),
      );
    }
  }

  Future<void> _savePortrait(String url) async {
    try {
      final response = await Dio()
          .get(url, options: Options(responseType: ResponseType.bytes));
      final result =
          await ImageGallerySaver.saveImage(Uint8List.fromList(response.data));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Portrait saved to gallery!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save: $e")),
        );
      }
    }
  }

  Future<void> _sharePortrait(String url) async {
    try {
      final response = await Dio()
          .get(url, options: Options(responseType: ResponseType.bytes));
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/dna_portrait.png').create();
      await file.writeAsBytes(response.data);
      await Share.shareXFiles([XFile(file.path)],
          text: 'Check out my DNA-predicted portrait!');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to share: $e")),
        );
      }
    }
  }

  void _showFullFace() {
    if (_faceImageBytes == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text("AI Face Prediction", style: AppTypography.titleMedium),
            centerTitle: true,
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Padding(
                padding: AppSpacing.cardAll,
                child: ClipRRect(
                  borderRadius: AppRadius.banner,
                  child: Image.memory(_faceImageBytes!, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topHair = _getTopTrait(widget.hairResults);
    final topEye = _getTopTrait(widget.eyeResults);
    final topSkin = _getTopTrait(widget.skinResults);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.background, AppColors.surface],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.base, vertical: AppSpacing.md),
                  child: _buildHeader(context),
                ),
              ),
              SliverToBoxAdapter(child: AppSpacing.vMd),
              SliverPadding(
                padding: AppSpacing.screenH,
                sliver: SliverToBoxAdapter(
                  child: AnimatedEntrance(
                    child: Row(
                      children: [
                        Expanded(
                            child: _buildSummaryCard("Hair", topHair.key,
                                topHair.value, AppColors.info.withAlpha(180))),
                        AppSpacing.hSm,
                        Expanded(
                            child: _buildSummaryCard("Eyes", topEye.key,
                                topEye.value, AppColors.primary)),
                        AppSpacing.hSm,
                        Expanded(
                            child: _buildSummaryCard("Skin", topSkin.key,
                                topSkin.value, AppColors.warning)),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: AppSpacing.vXl),
              SliverPadding(
                padding: AppSpacing.screenH,
                sliver: SliverToBoxAdapter(
                  child: AnimatedEntrance(
                    delay: const Duration(milliseconds: 80),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryMuted,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: const Icon(Icons.bar_chart_rounded,
                              color: AppColors.primary, size: 16),
                        ),
                        AppSpacing.hSm,
                        Text("Detailed Probabilities",
                            style: AppTypography.sectionHeader),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: AppSpacing.vMd),
              SliverPadding(
                padding: AppSpacing.screenH,
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      AnimatedEntrance(
                        delay: const Duration(milliseconds: 120),
                        child: _buildDetailedCard(
                          "Hair Colour",
                          widget.hairResults,
                          topHair.key,
                          AppColors.info.withAlpha(180),
                          Icons.content_cut_outlined,
                        ),
                      ),
                      AppSpacing.vMd,
                      AnimatedEntrance(
                        delay: const Duration(milliseconds: 180),
                        child: _buildDetailedCard(
                          "Eye Colour",
                          widget.eyeResults,
                          topEye.key,
                          AppColors.primary,
                          Icons.visibility_outlined,
                        ),
                      ),
                      AppSpacing.vMd,
                      AnimatedEntrance(
                        delay: const Duration(milliseconds: 240),
                        child: _buildDetailedCard(
                          "Skin Tone",
                          widget.skinResults,
                          topSkin.key,
                          AppColors.warning,
                          Icons.person_outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: AppSpacing.vXl),
              SliverPadding(
                padding: AppSpacing.screenH,
                sliver: SliverToBoxAdapter(
                  child: AnimatedEntrance(
                    delay: const Duration(milliseconds: 280),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryMuted,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: const Icon(Icons.face_retouching_natural,
                              color: AppColors.primary, size: 16),
                        ),
                        AppSpacing.hSm,
                        Text("Phenotype Visualisation",
                            style: AppTypography.sectionHeader),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: AppSpacing.vMd),
              SliverPadding(
                padding: AppSpacing.screenH,
                sliver: SliverToBoxAdapter(
                  child: AnimatedEntrance(
                    delay: const Duration(milliseconds: 320),
                    child: _buildFaceGeneratorCard(),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Semantics(
          button: true,
          label: 'Go back',
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary, size: 18),
            ),
          ),
        ),
        Expanded(
          child: Text(
            "Analysis Results",
            style: AppTypography.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
        Semantics(
          button: true,
          label: 'Share results',
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: const Icon(Icons.share_outlined,
                color: AppColors.textPrimary, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, String trait, double probability, Color color) {
    IconData icon;
    switch (title) {
      case "Hair":
        icon = Icons.content_cut_outlined;
        break;
      case "Eyes":
        icon = Icons.visibility_outlined;
        break;
      default:
        icon = Icons.person_outline;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.card,
        border: Border.all(color: color.withAlpha(55)),
        boxShadow: [
          BoxShadow(
              color: color.withAlpha(22),
              blurRadius: 18,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withAlpha(170)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              boxShadow: [
                BoxShadow(
                    color: color.withAlpha(85),
                    blurRadius: 10,
                    offset: const Offset(0, 3))
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            trait,
            style: AppTypography.titleSmall.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(title,
              style: AppTypography.caption
                  .copyWith(color: AppColors.textTertiary, fontSize: 10),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutQuart,
              tween: Tween(begin: 0.0, end: probability),
              builder: (_, v, __) => LinearProgressIndicator(
                value: v / 100.0,
                minHeight: 4,
                backgroundColor: AppColors.surfaceBorder,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "${probability.toInt()}%",
            style: AppTypography.labelSmall.copyWith(
                color: color, fontWeight: FontWeight.w800, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedCard(String title, Map<String, double> data,
      String topTrait, Color accentColor, IconData icon) {
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      decoration: AppColors.glassCard(
        borderColor: accentColor.withAlpha(45),
        radius: AppRadius.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor.withAlpha(22), accentColor.withAlpha(8)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadius.xl),
                topRight: Radius.circular(AppRadius.xl),
              ),
              border:
                  Border(bottom: BorderSide(color: accentColor.withAlpha(35))),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentColor, accentColor.withAlpha(170)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.xs + 2),
                    boxShadow: [
                      BoxShadow(
                          color: accentColor.withAlpha(80),
                          blurRadius: 8,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 15),
                ),
                AppSpacing.hSm,
                Text(title,
                    style: AppTypography.titleSmall
                        .copyWith(color: AppColors.textPrimary)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentColor.withAlpha(22),
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                    border: Border.all(color: accentColor.withAlpha(50)),
                  ),
                  child: Text("# $topTrait",
                      style: AppTypography.badge
                          .copyWith(color: accentColor, fontSize: 9)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Column(
              children: sortedEntries.asMap().entries.map((entry) {
                final e = entry.value;
                final isTop = e.key == topTrait;
                final barColor =
                    isTop ? accentColor : accentColor.withAlpha(70);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: barColor,
                              boxShadow: isTop
                                  ? [
                                      BoxShadow(
                                          color: accentColor.withAlpha(120),
                                          blurRadius: 5)
                                    ]
                                  : null,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              e.key,
                              style: AppTypography.bodyMedium.copyWith(
                                color: isTop
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                                fontWeight:
                                    isTop ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ),
                          Text(
                            "${e.value.toInt()}%",
                            style: AppTypography.titleSmall.copyWith(
                              color:
                                  isTop ? accentColor : AppColors.textTertiary,
                              fontWeight:
                                  isTop ? FontWeight.w800 : FontWeight.w500,
                              fontSize: isTop ? 14 : 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOutQuart,
                        tween: Tween<double>(begin: 0, end: e.value),
                        builder: (context, value, _) {
                          return Stack(
                            children: [
                              Container(
                                height: 10,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceBorder,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: value / 100.0,
                                child: Container(
                                  height: 10,
                                  decoration: BoxDecoration(
                                    gradient: isTop
                                        ? LinearGradient(
                                            colors: [
                                              accentColor.withAlpha(180),
                                              accentColor
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          )
                                        : null,
                                    color: isTop
                                        ? null
                                        : accentColor.withAlpha(60),
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: isTop
                                        ? [
                                            BoxShadow(
                                                color:
                                                    accentColor.withAlpha(80),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2))
                                          ]
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
Widget _buildFaceGeneratorCard() {
    // استخدمنا Consumer هنا عشان الشاشة تحس بتغيير الصورة وتعمل Rebuild لوحدها
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // البحث عن التقرير الحالي في قائمة التقارير بالـ Provider
        final report = userProvider.reports.cast<ReportItem?>().firstWhere(
              (r) => r?.id == widget.analysisId,
              orElse: () => null,
            );

        // حالة التحليل (الأنيميشن الرهيب اللي عملتيه)
        if (userProvider.isFaceLoading) {
          return _buildLoadingView(); // أو _buildLoadingViewShimmer() حسب ما تحبي
        }

        // لو الصورة وصلت فعلاً في الـ Provider
        if (report?.faceImageUrl != null) {
          return _buildGeneratedFaceViewLive(
              report!.faceImageUrl!, report.facePrompt ?? "DNA Reconstruction Result");
        }

        // لو لسه مفيش صورة، نعرض زرار التوليد العادي
        final topHair = _getTopTrait(widget.hairResults);
        final topEye = _getTopTrait(widget.eyeResults);
        final topSkin = _getTopTrait(widget.skinResults);

        return _buildGeneratePrompt(topHair.key, topEye.key, topSkin.key);
      },
    );
  }

  Widget _buildLoadingViewShimmer() {
    return Container(
      height: 380,
      decoration: AppColors.glassCard(radius: AppRadius.xl),
      child: Shimmer.fromColors(
        baseColor: AppColors.surfaceBorder,
        highlightColor: AppColors.primaryMuted,
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
            ),
            Container(
              height: 20,
              width: 200,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratedFaceViewLive(String imageUrl, String prompt) {
    return Container(
      decoration: AppColors.glassCard(
        borderColor: AppColors.primary.withAlpha(80),
        radius: AppRadius.xl,
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Image.network(
                  imageUrl,
                  height: 350, // زودت الطول شوية عشان الصورة تبان أوضح
                  width: double.infinity,
                  fit: BoxFit.cover,
                  // الهيدرز دي أهم حاجة عشان الـ Ngrok يرضى يعرض الصورة على الويب
                  headers: const {
                    "ngrok-skip-browser-warning": "69420",
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _buildLoadingViewShimmer();
                  },
                  errorBuilder: (context, error, stackTrace) {
                    print("Image Load Error: $error");
                    return Container(
                      height: 300,
                      color: AppColors.surfaceCard,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 50, color: AppColors.error),
                          SizedBox(height: 10),
                          Text("Failed to load AI Portrait"),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Row(
                  children: [
                    _actionBtn(Icons.share_outlined, () => _sharePortrait(imageUrl)),
                    AppSpacing.hSm,
                    _actionBtn(Icons.download_rounded, () => _savePortrait(imageUrl)),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_awesome, color: AppColors.secondary, size: 16),
                    AppSpacing.hSm,
                    Text("AI Insights", style: AppTypography.titleSmall),
                  ],
                ),
                AppSpacing.vXs,
                Text(
                  prompt,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(120),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildGeneratePrompt(String hair, String eye, String skin) {
    return Container(
      padding: AppSpacing.cardLarge,
      decoration: AppColors.glassCard(
        borderColor: AppColors.surfaceBorderAccent,
        radius: AppRadius.xl,
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadius.card,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(80),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.face_retouching_natural,
                color: Colors.white, size: 34),
          ),
          AppSpacing.vBase,
          Text("AI Face Prediction", style: AppTypography.titleMedium),
          AppSpacing.vSm,
          Text(
            _faceError ??
                "Generate a photorealistic face based on your predicted DNA traits.",
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color:
                  _faceError != null ? AppColors.error : AppColors.textTertiary,
              height: 1.5,
            ),
          ),
          AppSpacing.vBase,
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            alignment: WrapAlignment.center,
            children: [
              _traitChip(Icons.content_cut_outlined, "Hair", hair),
              _traitChip(Icons.visibility_outlined, "Eyes", eye),
              _traitChip(Icons.palette_outlined, "Skin", skin),
            ],
          ),
          AppSpacing.vLg,
          Semantics(
            button: true,
            label: _faceError != null ? 'Retry' : 'Generate face',
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(90),
                      blurRadius: 16,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _startFaceGeneration,
                  icon: Icon(
                    _faceError != null
                        ? Icons.refresh_rounded
                        : Icons.auto_awesome,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: Text(
                    _faceError != null ? "Retry Generation" : "Generate Face",
                    style:
                        AppTypography.titleSmall.copyWith(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.xl)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _traitChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceCardStrong,
        borderRadius: AppRadius.circle,
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primary),
          const SizedBox(width: 5),
          Text("$label: ",
              style: AppTypography.caption
                  .copyWith(color: AppColors.textTertiary, fontSize: 10)),
          Text(
            value,
            style: AppTypography.labelSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    const stages = [
      (
        Icons.scatter_plot_outlined,
        'Reading SNP Markers',
        'Scanning your genetic variants...'
      ),
      (
        Icons.biotech_outlined,
        'Mapping Traits',
        'Eye · Hair · Skin analysis...'
      ),
      (
        Icons.auto_awesome,
        'Synthesising Portrait',
        'AI compositing features...'
      ),
      (
        Icons.face_retouching_natural,
        'Rendering Face',
        'Finalising your portrait...'
      ),
    ];

    return Container(
      decoration: AppColors.glassCard(
        borderColor: AppColors.surfaceBorderAccent,
        radius: AppRadius.xl,
      ),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: const Icon(Icons.biotech,
                    color: AppColors.primary, size: 13),
              ),
              const SizedBox(width: 8),
              Text(
                'DNA → Phenotype Rendering',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          AnimatedBuilder(
            animation: _stageController,
            builder: (_, __) => SizedBox(
              width: double.infinity,
              height: 88,
              child: CustomPaint(
                painter: _DnaHelixPainter(phase: _stageController.value),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 55,
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.transparent,
                    AppColors.primary.withAlpha(90),
                  ]),
                ),
              ),
              const SizedBox(width: 10),
              AnimatedBuilder(
                animation: _pulseController,
                builder: (_, __) => Icon(
                  Icons.keyboard_double_arrow_down_rounded,
                  color: AppColors.primary
                      .withAlpha((90 + (_pulseController.value * 165).toInt())),
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 55,
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    AppColors.secondary.withAlpha(90),
                    Colors.transparent,
                  ]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AnimatedBuilder(
            animation: Listenable.merge([_pulseController, _stageController]),
            builder: (_, __) {
              final p = _pulseController.value;
              final scanFrac = (_stageController.value * 6) % 1.0;
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 118 + p * 22,
                    height: 118 + p * 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            AppColors.primary.withAlpha((28 * (1 - p)).toInt()),
                        width: 1,
                      ),
                    ),
                  ),
                  Container(
                    width: 100 + p * 12,
                    height: 100 + p * 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.secondary
                            .withAlpha((38 * (1 - p)).toInt()),
                        width: 1.2,
                      ),
                    ),
                  ),
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                      border: Border.all(
                        color: AppColors.primary
                            .withAlpha((100 + (p * 90).toInt())),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary
                              .withAlpha((50 + (p * 80).toInt())),
                          blurRadius: 22 + p * 14,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: AppColors.secondary
                              .withAlpha((22 + (p * 35).toInt())),
                          blurRadius: 40,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Stack(
                        children: [
                          Center(
                            child: Icon(
                              Icons.face_retouching_natural,
                              size: 50,
                              color: AppColors.primary
                                  .withAlpha((148 + (p * 107).toInt())),
                            ),
                          ),
                          Positioned(
                            top: scanFrac * 92 - 1,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AppColors.primary.withAlpha(210),
                                    AppColors.secondary.withAlpha(170),
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withAlpha(100),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          AnimatedBuilder(
            animation: _stageController,
            builder: (_, __) {
              final idx = (_stageController.value * stages.length)
                  .floor()
                  .clamp(0, stages.length - 1);
              final s = stages[idx];
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(s.$1, color: AppColors.primary, size: 15),
                      const SizedBox(width: 8),
                      Text(s.$2, style: AppTypography.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    s.$3,
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.textTertiary),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          AnimatedBuilder(
            animation: _stageController,
            builder: (_, __) {
              final idx = (_stageController.value * stages.length)
                  .floor()
                  .clamp(0, stages.length - 1);
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(stages.length, (i) {
                  final isActive = i == idx;
                  final isDone = i < idx;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: isDone
                          ? AppColors.primary.withAlpha(110)
                          : isActive
                              ? AppColors.primary
                              : AppColors.surfaceBorder,
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            "This may take up to a minute",
            style: AppTypography.caption
                .copyWith(color: AppColors.textHint, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratedFaceView() {
    return Column(
      children: [
        Semantics(
          label: 'Generated face, tap to view full screen',
          button: true,
          child: GestureDetector(
            onTap: _showFullFace,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: AppRadius.card,
                border: Border.all(
                  color: AppColors.primary.withAlpha(80),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(50),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: AppRadius.card,
                child: Image.memory(
                  _faceImageBytes!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          ),
        ),
        AppSpacing.vMd,
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _showFullFace,
                icon: const Icon(Icons.zoom_in_rounded,
                    size: 18, color: AppColors.textPrimary),
                label: Text("View Full",
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.textPrimary)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.surfaceBorder),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            ),
            AppSpacing.hMd,
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _faceGenerated = false;
                    _faceImageBytes = null;
                    _faceError = null;
                  });
                  _startFaceGeneration();
                },
                icon: const Icon(Icons.refresh_rounded,
                    size: 18, color: AppColors.primary),
                label: Text("Regenerate",
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.primary)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DnaHelixPainter extends CustomPainter {
  final double phase;

  _DnaHelixPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cy = h / 2;
    final amp = h * 0.40;
    final freq = (2 * pi / w) * 2.4;
    final phaseRad = phase * 2 * pi;

    const c1 = AppColors.primary;
    const c2 = AppColors.secondary;
    const rungCount = 13;

    for (int i = 0; i <= rungCount; i++) {
      final t = i / rungCount;
      final x = t * w;
      final y1 = cy + amp * sin(freq * x + phaseRad);
      final y2 = cy + amp * sin(freq * x + phaseRad + pi);
      final crossFactor = cos(freq * x + phaseRad).abs();

      canvas.drawLine(
        Offset(x, y1),
        Offset(x, y2),
        Paint()
          ..color = Color.lerp(c1, c2, t)!
              .withAlpha((32 + (crossFactor * 75).toInt()))
          ..strokeWidth = 1.2 + crossFactor * 1.6
          ..strokeCap = StrokeCap.round,
      );
    }

    final path1 = Path();
    final path2 = Path();
    for (int px = 0; px <= w.toInt(); px++) {
      final x = px.toDouble();
      final y1 = cy + amp * sin(freq * x + phaseRad);
      final y2 = cy + amp * sin(freq * x + phaseRad + pi);
      if (px == 0) {
        path1.moveTo(x, y1);
        path2.moveTo(x, y2);
      } else {
        path1.lineTo(x, y1);
        path2.lineTo(x, y2);
      }
    }
    canvas.drawPath(
        path1,
        Paint()
          ..color = c1.withAlpha(200)
          ..strokeWidth = 2.4
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);
    canvas.drawPath(
        path2,
        Paint()
          ..color = c2.withAlpha(200)
          ..strokeWidth = 2.4
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);

    for (int i = 0; i <= rungCount; i++) {
      final t = i / rungCount;
      final x = t * w;
      final y1 = cy + amp * sin(freq * x + phaseRad);
      final y2 = cy + amp * sin(freq * x + phaseRad + pi);
      final depth1 = ((y1 - cy) / amp + 1) / 2;
      final depth2 = 1 - depth1;
      final r1 = 3.5 + depth1 * 3.2;
      final r2 = 3.5 + depth2 * 3.2;

      canvas.drawCircle(
          Offset(x, y1),
          r1 + 3,
          Paint()
            ..color = c1.withAlpha((55 * depth1).toInt())
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
      canvas.drawCircle(
          Offset(x, y2),
          r2 + 3,
          Paint()
            ..color = c2.withAlpha((55 * depth2).toInt())
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));

      canvas.drawCircle(Offset(x, y1), r1,
          Paint()..color = c1.withAlpha((125 + (depth1 * 130).toInt())));
      canvas.drawCircle(Offset(x, y2), r2,
          Paint()..color = c2.withAlpha((125 + (depth2 * 130).toInt())));
    }
  }

  @override
  bool shouldRepaint(_DnaHelixPainter old) => old.phase != phase;
}
