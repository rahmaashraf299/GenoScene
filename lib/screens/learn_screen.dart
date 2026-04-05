import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'guide_details_screen.dart';

// ═══════════════════════════════════════════════
// Data Models  (unchanged)
// ═══════════════════════════════════════════════

class GuideItem {
  final String title;
  final String description;
  final String readTime;
  final IconData icon;
  final String content;

  const GuideItem({
    required this.title,
    required this.description,
    required this.readTime,
    required this.icon,
    required this.content,
  });
}

class MediaItem {
  final String title;
  final String duration;
  final bool isVideo;
  final String? imageUrl;

  const MediaItem({
    required this.title,
    required this.duration,
    this.isVideo = false,
    this.imageUrl,
  });
}

// ReportItem removed (migrated to models/report_item.dart)

// ═══════════════════════════════════════════════
// Mock Data  (unchanged)
// ═══════════════════════════════════════════════

const _guides = [
  GuideItem(
    title: "What is DNA Phenotyping?",
    description: "Learn how genetic markers predict physical appearance traits.",
    readTime: "4 min read",
    icon: Icons.biotech_outlined,
    content:
        "DNA phenotyping is the process of predicting an organism's observable traits (phenotype) from its DNA sequence (genotype). "
        "In forensic science, this technique is used to predict the physical appearance of an unknown person from biological evidence.\n\n"
        "GenoScene uses machine learning models trained on thousands of samples to predict eye colour, hair colour, and skin tone "
        "from Single Nucleotide Polymorphisms (SNPs) — specific positions in the genome where individual variation is common.\n\n"
        "Key genes involved include:\n"
        "• HERC2 / OCA2 — Eye colour\n"
        "• MC1R — Hair colour (especially red hair)\n"
        "• SLC24A5 / SLC45A2 — Skin pigmentation\n"
        "• IRF4, TYR, TYRP1 — Multiple pigmentation traits",
  ),
  GuideItem(
    title: "Understanding SNPs",
    description: "Single Nucleotide Polymorphisms and why they matter.",
    readTime: "3 min read",
    icon: Icons.scatter_plot_outlined,
    content:
        "SNPs (pronounced 'snips') are the most common type of genetic variation among people. Each SNP represents a difference "
        "in a single DNA building block, called a nucleotide.\n\n"
        "For example, a SNP may replace the nucleotide cytosine (C) with the nucleotide thymine (T) in a certain stretch of DNA.\n\n"
        "GenoScene analyses 40 specific SNPs that have been scientifically validated to correlate with pigmentation traits. "
        "The allele values are encoded as:\n"
        "• 0 — Allele not present\n"
        "• 1 — Heterozygous (one copy)\n"
        "• 2 — Homozygous (two copies)\n"
        "• NA — Missing data",
  ),
  GuideItem(
    title: "How to Prepare Your CSV File",
    description: "Step-by-step guide for formatting your input data.",
    readTime: "2 min read",
    icon: Icons.description_outlined,
    content:
        "Your CSV file must contain columns for each of the 40 SNP markers used by GenoScene.\n\n"
        "Column format: rs[number]_[allele] (e.g., rs12913832_T)\n\n"
        "Steps:\n"
        "1. Export your raw genotype data from 23andMe, AncestryDNA, or a lab.\n"
        "2. Map each SNP to its allele count (0, 1, or 2).\n"
        "3. If a SNP is not available in your data, enter NA.\n"
        "4. Save as .csv with headers matching the expected SNP column names.\n"
        "5. Upload through the Analysis tab in GenoScene.",
  ),
  GuideItem(
    title: "Eye Colour Genetics",
    description: "HERC2, OCA2 and the science behind eye colour prediction.",
    readTime: "5 min read",
    icon: Icons.visibility_outlined,
    content:
        "Eye colour is primarily determined by the amount and type of pigment (melanin) in the iris.\n\n"
        "The two key genes are:\n"
        "• OCA2 — Produces the P protein involved in melanin production\n"
        "• HERC2 — Contains a regulatory element that controls OCA2 expression\n\n"
        "The SNP rs12913832 in HERC2 is the strongest single predictor of eye colour. "
        "The T allele is associated with blue eyes, while the G allele is associated with brown eyes.\n\n"
        "GenoScene uses 13 SNPs selected through Random Forest feature importance to predict three categories: "
        "Blue, Brown, and Intermediate (green/hazel).",
  ),
  GuideItem(
    title: "Hair Colour Prediction",
    description: "MC1R variants and hair pigmentation pathways.",
    readTime: "5 min read",
    icon: Icons.content_cut_outlined,
    content:
        "Hair colour is determined by the ratio of two types of melanin:\n"
        "• Eumelanin — Brown/black pigment\n"
        "• Pheomelanin — Red/yellow pigment\n\n"
        "The MC1R gene is crucial for red hair — certain variants shift production towards pheomelanin. "
        "Other genes like HERC2, SLC45A2, and IRF4 influence the overall darkness or lightness.\n\n"
        "GenoScene uses 35 SNPs and an XGBoost model to predict four categories: Black, Blond, Brown, and Red hair.",
  ),
  GuideItem(
    title: "Skin Tone Analysis",
    description: "How SLC24A5 and SLC45A2 influence skin pigmentation.",
    readTime: "4 min read",
    icon: Icons.person_outline,
    content:
        "Skin colour variation is driven by melanin concentration in the epidermis. Key genes include:\n\n"
        "• SLC24A5 — A single SNP (rs1426654) explains 25–38% of skin colour variation between Europeans and Africans\n"
        "• SLC45A2 — Variants strongly associated with light skin in Europeans\n"
        "• HERC2 / OCA2 — Also contribute to skin pigmentation\n\n"
        "GenoScene uses 30 SNPs and Logistic Regression to predict four categories: Dark, DarkToBlack, Intermediate, and Pale.\n\n"
        "The model achieves ~95% accuracy with a Macro-F1 of 0.94.",
  ),
  GuideItem(
    title: "Reading Your Results",
    description: "How to interpret probabilities, confidence, and entropy.",
    readTime: "3 min read",
    icon: Icons.bar_chart_outlined,
    content:
        "After analysis, GenoScene shows:\n\n"
        "1. Summary Cards — The top prediction for each trait with confidence percentage.\n\n"
        "2. Detailed Probabilities — A breakdown of all possible outcomes with animated progress bars. "
        "Higher bars mean stronger genetic signal for that trait.\n\n"
        "3. Confidence Levels:\n"
        "   • Very High (entropy < 0.3) — Strong prediction\n"
        "   • Moderate (0.3–0.7) — Reasonable but not definitive\n"
        "   • Low (> 0.7) — Uncertain, multiple traits are similarly likely\n\n"
        "Remember: DNA phenotyping provides probabilistic predictions, not certainties. "
        "Environmental factors and gene interactions can also influence traits.",
  ),
];

const _mediaItems = [
  MediaItem(
      title: "DNA Double Helix Explained", duration: "03:24", isVideo: true),
  MediaItem(
      title: "How SNPs Affect Traits", duration: "05:10", isVideo: true),
  MediaItem(
      title: "Uploading Your Data", duration: "02:15", isVideo: true),
  MediaItem(title: "SNP Heatmap", duration: "—"),
  MediaItem(title: "Eye Colour Distribution", duration: "—"),
  MediaItem(title: "Model Accuracy Chart", duration: "—"),
  MediaItem(title: "Feature Importance Plot", duration: "—"),
  MediaItem(title: "Phenotyping Workflow", duration: "—"),
];

// _mockReports removed (migrated to persistent history)

// ═══════════════════════════════════════════════
// LearnScreen
// ═══════════════════════════════════════════════

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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.background, AppColors.surface],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            AnimatedEntrance(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.base, AppSpacing.lg, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryMuted,
                        borderRadius:
                            BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(Icons.school_outlined,
                          color: AppColors.primary, size: 20),
                    ),
                    AppSpacing.hMd,
                    Text("Learn", style: AppTypography.displaySmall),
                  ],
                ),
              ),
            ),

            AppSpacing.vBase,

            // ── Hero Card ──
            AnimatedEntrance(
              delay: const Duration(milliseconds: 60),
              child: Padding(
                padding: AppSpacing.screenH,
                child: Container(
                  width: double.infinity,
                  padding: AppSpacing.cardLarge,
                  decoration: BoxDecoration(
                    gradient: AppColors.elevatedCardGradient,
                    borderRadius: AppRadius.card,
                    border: Border.all(
                        color: AppColors.surfaceBorderAccent),
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
                            Text(
                              "DNA Phenotyping Hub",
                              style: AppTypography.titleMedium,
                            ),
                            AppSpacing.vXs,
                            Text(
                              "Explore guides, media & analysis reports in one place.",
                              style: AppTypography.bodySmall
                                  .copyWith(height: 1.5),
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.hMd,
                      Container(
                        padding: const EdgeInsets.all(14),
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
                              blurRadius: 14,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.biotech,
                            color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            AppSpacing.vBase,

            // ── Tab Bar ──
            AnimatedEntrance(
              delay: const Duration(milliseconds: 100),
              child: Padding(
                padding: AppSpacing.screenH,
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
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
                    labelStyle: GoogleFonts.poppins(
                        fontSize: 13, fontWeight: FontWeight.w600),
                    unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13),
                    tabs: const [
                      Tab(text: "Guides"),
                      Tab(text: "Media"),
                    ],
                  ),
                ),
              ),
            ),

            AppSpacing.vBase,

            // ── Tab Content ──
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

  // ── Guides Tab ──
  Widget _buildGuidesTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      physics: const BouncingScrollPhysics(),
      itemCount: _guides.length,
      itemBuilder: (context, index) {
        final guide = _guides[index];
        return AnimatedEntrance(
          delay: Duration(milliseconds: index * 50),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GuideDetailsScreen(
                  title: guide.title,
                  content: guide.content,
                  readTime: guide.readTime,
                  icon: guide.icon,
                ),
              ),
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.base),
              decoration: AppColors.glassCard(
                borderColor: AppColors.surfaceBorder,
                radius: AppRadius.lg,
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.primaryMuted,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(guide.icon,
                        color: AppColors.primary, size: 22),
                  ),
                  AppSpacing.hMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(guide.title,
                            style: AppTypography.titleSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        AppSpacing.vXs,
                        Text(guide.description,
                            style: AppTypography.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  AppSpacing.hSm,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Icon(Icons.arrow_forward_ios_rounded,
                          color: AppColors.primary, size: 14),
                      AppSpacing.vXs,
                      Text(guide.readTime,
                          style: AppTypography.caption
                              .copyWith(color: AppColors.textHint)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Media Tab ──
  Widget _buildMediaTab() {
    final videos = _mediaItems.where((m) => m.isVideo).toList();
    final images = _mediaItems.where((m) => !m.isVideo).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Videos", "${videos.length} items"),
          AppSpacing.vMd,
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.05,
            ),
            itemCount: videos.length,
            itemBuilder: (context, i) => _mediaCard(videos[i]),
          ),
          AppSpacing.vXl,
          _sectionTitle("Images & Charts", "${images.length} items"),
          AppSpacing.vMd,
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.05,
            ),
            itemCount: images.length,
            itemBuilder: (context, i) => _mediaCard(images[i]),
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
        Text(title, style: AppTypography.sectionHeader),
        Text(subtitle, style: AppTypography.labelSmall),
      ],
    );
  }

  Widget _mediaCard(MediaItem item) {
    final isVideo = item.isVideo;
    final color = isVideo ? AppColors.secondary : AppColors.primary;
    return Container(
      decoration: AppColors.glassCard(
        borderColor: color.withAlpha(40),
        radius: AppRadius.lg,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isVideo ? Icons.play_circle_fill_outlined : Icons.image_outlined,
              color: color,
              size: 26,
            ),
          ),
          AppSpacing.vSm,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(
              item.title,
              style: AppTypography.labelSmall
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          AppSpacing.vXs,
          Text(
            item.duration,
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }
}
