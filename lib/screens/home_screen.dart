import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../styles.dart';
import '../widgets/dna_loading_indicator.dart';
import 'analysis_upload_screen.dart';
import 'learn_screen.dart';
import 'profile_screen.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _dailyFact;
  bool _isLoadingFact = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDailyFact();
  }

  Future<void> _loadDailyFact() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/dna_facts.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> facts = jsonData['facts'];
      if (facts.isNotEmpty) {
        setState(() {
          _dailyFact = facts[Random().nextInt(facts.length)];
          _isLoadingFact = false;
        });
      } else {
        setState(() {
          _dailyFact = "DNA contains the blueprint for your entire body.";
          _isLoadingFact = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading facts: $e");
      setState(() {
        _dailyFact = "Did you know? DNA was first isolated in 1869.";
        _isLoadingFact = false;
      });
    }
  }

  void _goToTab(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.background, AppColors.surface],
          ),
        ),
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeContent(),
            const AnalysisUploadScreen(),
            const LearnScreen(),
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ═══════════════════════════════════════
  //  HOME CONTENT
  // ═══════════════════════════════════════
  Widget _buildHomeContent() {
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: AppSpacing.vBase),

          // Header
          SliverPadding(
            padding: AppSpacing.screenH,
            sliver: SliverToBoxAdapter(child: _buildHeader()),
          ),

          SliverToBoxAdapter(child: AppSpacing.vLg),

          // 1) Hero Banner
          SliverPadding(
            padding: AppSpacing.screenH,
            sliver: SliverToBoxAdapter(
              child: AnimatedEntrance(child: _buildHeroBanner()),
            ),
          ),

          SliverToBoxAdapter(child: AppSpacing.vXl),

          // 3) Daily Insight
          SliverPadding(
            padding: AppSpacing.screenH,
            sliver: SliverToBoxAdapter(
              child: AnimatedEntrance(
                delay: const Duration(milliseconds: 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel("Daily DNA Insight", Icons.lightbulb_outline),
                    AppSpacing.vMd,
                    _buildDailyInsight(),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(child: AppSpacing.vXl),

          // 4) Predictable Traits header
          SliverPadding(
            padding: const EdgeInsetsDirectional.only(start: AppSpacing.lg),
            sliver: SliverToBoxAdapter(
              child: AnimatedEntrance(
                delay: const Duration(milliseconds: 150),
                child: _sectionLabel("Predictable Traits", Icons.biotech_outlined),
              ),
            ),
          ),
          SliverToBoxAdapter(child: AppSpacing.vMd),
          // Traits horizontal list (no extra padding — list has its own)
          SliverToBoxAdapter(
            child: AnimatedEntrance(
              delay: const Duration(milliseconds: 180),
              child: _buildTraitsRow(),
            ),
          ),

          SliverToBoxAdapter(child: AppSpacing.vXl),
 
          // 5) How It Works
          SliverPadding(
            padding: AppSpacing.screenH,
            sliver: SliverToBoxAdapter(
              child: AnimatedEntrance(
                delay: const Duration(milliseconds: 200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel("How It Works", Icons.route_outlined),
                    AppSpacing.vMd,
                    _buildHowItWorks(),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(child: AppSpacing.vXl),

          // 6) Next Step Guide (Replacing technical Model Stats)
          SliverPadding(
            padding: AppSpacing.screenH,
            sliver: SliverToBoxAdapter(
              child: AnimatedEntrance(
                delay: const Duration(milliseconds: 220),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel("Getting Started", Icons.ads_click_outlined),
                    AppSpacing.vMd,
                    _buildNextStepGuide(),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(child: AppSpacing.vXl),

          // 7) SNP Spotlight header
          SliverPadding(
            padding: const EdgeInsetsDirectional.only(start: AppSpacing.lg),
            sliver: SliverToBoxAdapter(
              child: AnimatedEntrance(
                delay: const Duration(milliseconds: 240),
                child: _sectionLabel("SNP Spotlight", Icons.scatter_plot_outlined),
              ),
            ),
          ),
          SliverToBoxAdapter(child: AppSpacing.vMd),
          SliverToBoxAdapter(
            child: AnimatedEntrance(
              delay: const Duration(milliseconds: 260),
              child: _buildSnpSpotlight(),
            ),
          ),

          SliverToBoxAdapter(child: AppSpacing.vXl),

          // 8) CTA
          SliverPadding(
            padding: AppSpacing.screenH,
            sliver: SliverToBoxAdapter(
              child: AnimatedEntrance(
                delay: const Duration(milliseconds: 280),
                child: _buildCtaBanner(),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // ── Header ──
  Widget _buildHeader() {
    return Row(
      children: [
        ValueListenableBuilder<String?>(
          valueListenable: AuthService.profilePicNotifier,
          builder: (context, pic, _) {
            return Semantics(
              label: 'Profile picture',
              child: Container(
                width: 44,
                height: 44,
                child: ClipOval(
                  child: (pic != null && pic.isNotEmpty)
                      ? Image.network(
                          pic,
                          key: ValueKey(pic),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                              'assets/images/genoscene_logo.png',
                              fit: BoxFit.cover),
                        )
                      : Image.asset('assets/images/genoscene_logo.png',
                          fit: BoxFit.cover),
                ),
              ),
            );
          },
        ),
        AppSpacing.hMd,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("GenoScene", style: AppTypography.titleLarge),
            Text(
              "DNA Phenotyping",
              style: AppTypography.labelSmall
                  .copyWith(color: AppColors.primary.withAlpha(180)),
            ),
          ],
        ),
        const Spacer(),
        _iconBtn(
          Icons.notifications_none_outlined,
          badge: true,
          semanticLabel: 'Notifications',
        ),
      ],
    );
  }

  Widget _iconBtn(IconData icon, {bool badge = false, String? semanticLabel}) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 21),
            if (badge)
              PositionedDirectional(
                end: 9,
                top: 9,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(160),
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
    );
  }

  // ── 1) HERO BANNER ──
  Widget _buildHeroBanner() {
    return Semantics(
      label: 'Welcome banner. Tap to start analysis.',
      button: true,
      child: GestureDetector(
        onTap: () => _goToTab(1),
        child: Container(
          width: double.infinity,
          height: 210,
          decoration: BoxDecoration(
            borderRadius: AppRadius.banner,
            image: const DecorationImage(
              image: AssetImage('assets/images/home.png'),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(40),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: AppRadius.banner,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.background.withAlpha(140),
                  AppColors.background.withAlpha(230),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
            padding: AppSpacing.cardLarge,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _smallBadge("Forensic Genetics"),
                AppSpacing.vSm,
                Text("Welcome to GenoScene",
                    style: AppTypography.displayLarge),
                AppSpacing.vXs,
                Text(
                  "Predict physical traits from DNA using AI-powered SNP analysis.",
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  // ── 3) DAILY INSIGHT ──
  Widget _buildDailyInsight() {
    return Container(
      padding: AppSpacing.cardInner,
      decoration: AppColors.glassCard(
        borderColor: AppColors.surfaceBorderAccent,
        radius: AppRadius.xl,
      ),
      child: _isLoadingFact
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                    color: AppColors.primary, strokeWidth: 2),
              ),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(80),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.lightbulb_outline,
                      color: Colors.white, size: 22),
                ),
                AppSpacing.hMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Did you know?",
                          style: AppTypography.titleSmall),
                      AppSpacing.vXs,
                      Text(
                        _dailyFact ?? "",
                        style: AppTypography.bodyMedium
                            .copyWith(height: 1.6),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // ── 4) PREDICTABLE TRAITS ──
  Widget _buildTraitsRow() {
    final traits = [
      {
        'icon': Icons.visibility_outlined,
        'title': 'Eye Colour',
        'genes': 'HERC2, OCA2',
        'snps': '13 SNPs',
        'acc': '96.2%',
        'color': AppColors.info,
      },
      {
        'icon': Icons.content_cut_outlined,
        'title': 'Hair Colour',
        'genes': 'MC1R, TYR',
        'snps': '35 SNPs',
        'acc': '95.1%',
        'color': const Color(0xFFAB47BC),
      },
      {
        'icon': Icons.person_outline,
        'title': 'Skin Tone',
        'genes': 'SLC24A5',
        'snps': '30 SNPs',
        'acc': '95.0%',
        'color': AppColors.warning,
      },
      {
        'icon': Icons.wc_outlined,
        'title': 'Gender',
        'genes': 'XY Chromosome',
        'snps': 'Binary',
        'acc': '—',
        'color': AppColors.success,
      },
    ];

    return SizedBox(
      height: 180,
      child: ListView.separated(
        padding: AppSpacing.screenH,
        scrollDirection: Axis.horizontal,
        itemCount: traits.length,
        separatorBuilder: (_, __) => AppSpacing.hMd,
        itemBuilder: (context, i) {
          final t = traits[i];
          final c = t['color'] as Color;
          return Container(
            width: 150,
            padding: AppSpacing.cardAll,
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: AppRadius.card,
              border: Border.all(color: c.withAlpha(50)),
              boxShadow: [
                BoxShadow(
                  color: c.withAlpha(20),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: c.withAlpha(40),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(t['icon'] as IconData, color: c, size: 18),
                    ),
                    if ((t['acc'] as String) != '—')
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: c.withAlpha(30),
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: Text(
                          t['acc'] as String,
                          style: AppTypography.badge.copyWith(color: c),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Text(t['title'] as String,
                    style: AppTypography.titleSmall),
                AppSpacing.vXs,
                Text(t['genes'] as String,
                    style: AppTypography.labelSmall),
                AppSpacing.vXs,
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: c.withAlpha(25),
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                    border: Border.all(color: c.withAlpha(40)),
                  ),
                  child: Text(
                    t['snps'] as String,
                    style: AppTypography.caption
                        .copyWith(color: c, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── 5) HOW IT WORKS ──
  Widget _buildHowItWorks() {
    const steps = [
      {
        'n': '01',
        'title': 'Upload CSV',
        'sub': 'Import your SNP genotype file',
        'icon': Icons.cloud_upload_outlined,
      },
      {
        'n': '02',
        'title': 'AI Analysis',
        'sub': 'LightGBM, XGBoost & LogReg models',
        'icon': Icons.psychology_outlined,
      },
      {
        'n': '03',
        'title': 'View Results',
        'sub': 'Probabilities, charts & confidence',
        'icon': Icons.bar_chart_outlined,
      },
    ];

    return Container(
      padding: AppSpacing.cardInner,
      decoration: AppColors.glassCard(
        borderColor: AppColors.surfaceBorder,
        radius: AppRadius.xl,
      ),
      child: Column(
        children: steps.asMap().entries.map((e) {
          final i = e.key;
          final s = e.value;
          final last = i == steps.length - 1;
          return Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.sm + 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(70),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(s['n'] as String,
                          style: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.w800, fontSize: 11)),
                    ),
                  ),
                  AppSpacing.hMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s['title'] as String,
                            style: AppTypography.titleSmall),
                        Text(s['sub'] as String,
                            style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textTertiary)),
                      ],
                    ),
                  ),
                  Icon(s['icon'] as IconData,
                      color: AppColors.primary.withAlpha(120), size: 20),
                ],
              ),
              if (!last)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 19),
                  child: Container(
                    width: 2,
                    height: 24,
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.primaryMuted, Colors.transparent],
                      ),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── 6) NEXT STEP GUIDE ──
  Widget _buildNextStepGuide() {
    return _InteractableCard(
      onTap: () => _goToTab(1),
      child: Container(
        width: double.infinity,
        padding: AppSpacing.cardInner,
        decoration: AppColors.glassCard(
          backgroundColor: AppColors.surfaceElevated.withAlpha(160),
          borderColor: AppColors.primary.withAlpha(80),
          radius: AppRadius.xl,
          shadows: [
            BoxShadow(
              color: AppColors.primary.withAlpha(15),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.rocket_launch_outlined,
                    color: AppColors.primary, size: 22),
                AppSpacing.hBase,
                Text("Your Data, Decoded",
                    style: AppTypography.titleMedium.copyWith(fontSize: 16)),
              ],
            ),
            AppSpacing.vBase,
            Text(
              "Embark on a forensic journey. Every SNP tells a story of ancestry and physical traits. Connect your data to unlock the vault of genetic secrets.",
              style:
                  AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            AppSpacing.vLg,
            Row(
              children: [
                Expanded(
                  child: _guideStep(
                    "1. Upload",
                    "CSV Sequence",
                    Icons.upload_file_outlined,
                    AppColors.primary,
                  ),
                ),
                AppSpacing.hSm,
                Expanded(
                  child: _guideStep(
                    "2. Analyze",
                    "AI processing",
                    Icons.biotech_outlined,
                    AppColors.secondary,
                  ),
                ),
                AppSpacing.hSm,
                Expanded(
                  child: _guideStep(
                    "3. Result",
                    "Trait Profile",
                    Icons.person_search_outlined,
                    AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _guideStep(String title, String sub, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          AppSpacing.vSm,
          Text(title,
              style: AppTypography.labelSmall
                  .copyWith(fontWeight: FontWeight.w700, color: color)),
          Text(sub,
              style: AppTypography.caption.copyWith(fontSize: 8, height: 1.1)),
        ],
      ),
    );
  }



  // ── 7) INTERACTABLE CARD (Scale Effect) ──
  Widget _InteractableCard({required Widget child, required VoidCallback onTap}) {
    return _PressableScale(
      onTap: onTap,
      child: child,
    );
  }

  // ── 8) SNP SPOTLIGHT ──
  Widget _buildSnpSpotlight() {
    const snps = [
      {
        'rs': 'rs12913832',
        'gene': 'HERC2',
        'trait': 'Eye Colour',
        'desc':
            'Strongest single predictor of blue vs brown eyes. The T allele shifts melanin production in the iris.',
        'color': AppColors.info,
      },
      {
        'rs': 'rs1805007',
        'gene': 'MC1R',
        'trait': 'Red Hair',
        'desc':
            'Key variant in the melanocortin-1 receptor. Shifts pigment from eumelanin to pheomelanin.',
        'color': AppColors.error,
      },
      {
        'rs': 'rs1426654',
        'gene': 'SLC24A5',
        'trait': 'Skin Tone',
        'desc':
            'Explains 25–38% of skin colour variation between European and African populations.',
        'color': AppColors.warning,
      },
      {
        'rs': 'rs16891982',
        'gene': 'SLC45A2',
        'trait': 'Pigmentation',
        'desc':
            'Associated with light skin, hair, and eye colour in European populations.',
        'color': AppColors.success,
      },
    ];

    return SizedBox(
      height: 180,
      child: ListView.separated(
        padding: AppSpacing.screenH,
        scrollDirection: Axis.horizontal,
        itemCount: snps.length,
        separatorBuilder: (_, __) => AppSpacing.hMd,
        itemBuilder: (context, i) {
          final s = snps[i];
          final c = s['color'] as Color;
          return Container(
            width: 240,
            padding: AppSpacing.cardAll,
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: AppRadius.card,
              border: Border.all(color: c.withAlpha(45)),
              boxShadow: [
                BoxShadow(
                  color: c.withAlpha(18),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: c.withAlpha(35),
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                        border: Border.all(color: c.withAlpha(60)),
                      ),
                      child: Text(s['rs'] as String,
                          style: AppTypography.mono.copyWith(
                              color: c, fontSize: 10)),
                    ),
                    AppSpacing.hSm,
                    Text(s['gene'] as String,
                        style: AppTypography.labelLarge),
                  ],
                ),
                AppSpacing.vXs,
                Text(s['trait'] as String,
                    style: AppTypography.labelSmall
                        .copyWith(color: c.withAlpha(200))),
                AppSpacing.vSm,
                Expanded(
                  child: Text(
                    s['desc'] as String,
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.textTertiary, height: 1.5),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── 8) CTA BANNER ──
  Widget _buildCtaBanner() {
    return Semantics(
      label: 'Start analysis. Upload your CSV file.',
      button: true,
      child: GestureDetector(
        onTap: () => _goToTab(1),
        child: Container(
          padding: AppSpacing.cardLarge,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D2137), Color(0xFF1A3A5C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppRadius.banner,
            border: Border.all(color: AppColors.surfaceBorderAccent),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(30),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              const DnaLoadingIndicator(
                size: 36,
                color1: AppColors.primary,
                color2: AppColors.secondary,
                rungColor: Color(0x33FFFFFF),
              ),
              AppSpacing.hBase,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Ready to Analyze?",
                        style: AppTypography.titleMedium),
                    AppSpacing.vXs,
                    Text(
                      "Upload your CSV and get trait predictions in seconds.",
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.textTertiary, height: 1.4),
                    ),
                  ],
                ),
              ),
              AppSpacing.hSm,
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF26C6DA)]),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(80),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_forward_rounded,
                    color: AppColors.background, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  //  HELPERS
  // ═══════════════════════════════════════

  Widget _sectionLabel(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primaryMuted,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, color: AppColors.primary, size: 16),
        ),
        AppSpacing.hSm,
        Text(title, style: AppTypography.sectionHeader),
      ],
    );
  }

  Widget _smallBadge(String label, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? AppColors.primary).withAlpha(28),
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(
            color: (color ?? AppColors.primary).withAlpha(60)),
      ),
      child: Text(
        label,
        style: AppTypography.badge
            .copyWith(color: color ?? AppColors.primary),
      ),
    );
  }

  // ═══════════════════════════════════════
  //  BOTTOM NAV
  // ═══════════════════════════════════════
  Widget _buildBottomNavBar() {
    final userProvider = Provider.of<UserProvider>(context);
    final bool isGuest = userProvider.isGuest;

    final items = [
      (Icons.home_outlined, Icons.home_rounded, "Home"),
      (isGuest ? Icons.lock_outline_rounded : Icons.analytics_outlined,
          isGuest ? Icons.lock_rounded : Icons.analytics_rounded, "Analysis"),
      (Icons.school_outlined, Icons.school_rounded, "Learn"),
      (isGuest ? Icons.lock_outline_rounded : Icons.person_outline,
          isGuest ? Icons.lock_rounded : Icons.person_rounded, "Profile"),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(color: AppColors.surfaceBorder, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textDisabled,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle: AppTypography.labelSmall,
        items: items
            .map((item) => BottomNavigationBarItem(
                  icon: Icon(item.$1),
                  activeIcon: Icon(item.$2),
                  label: item.$3,
                ))
            .toList(),
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
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() => _scale = 0.97);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0);
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}
