import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../models/report_item.dart';
import 'analysis_result_screen.dart';

class AnalysisHistoryScreen extends StatefulWidget {
  const AnalysisHistoryScreen({super.key});

  @override
  State<AnalysisHistoryScreen> createState() => _AnalysisHistoryScreenState();
}

class _AnalysisHistoryScreenState extends State<AnalysisHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).loadReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Analysis History", style: AppTypography.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              if (userProvider.reports.isEmpty) return const SizedBox.shrink();
              return TextButton.icon(
                onPressed: () => _showClearAllConfirmation(context, userProvider),
                icon: const Icon(Icons.delete_sweep_rounded, size: 18, color: AppColors.error),
                label: Text("Clear All", 
                  style: AppTypography.labelMedium.copyWith(color: AppColors.error, fontWeight: FontWeight.bold)),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.background, AppColors.surface],
          ),
        ),
        child: SafeArea(
          child: Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              if (userProvider.isReportsLoading && userProvider.reports.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final reports = userProvider.reports;

              return RefreshIndicator(
                onRefresh: () => userProvider.loadReports(),
                color: AppColors.primary,
                backgroundColor: AppColors.surfaceCard,
                child: reports.isEmpty 
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.7,
                        alignment: Alignment.center,
                        child: _buildEmptyState(),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.base),
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        // هنا تأكدي إن عندك Widget اسمه AnimatedEntrance أو استبدليه بـ Padding عادي لو فيه Error
                        return _HistoryReportCard(report: reports[index]);
                      },
                    ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: const Icon(
              Icons.history_rounded,
              size: 64,
              color: AppColors.textDisabled,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No History Yet",
            style: AppTypography.displaySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Your DNA analysis results will appear here once completed.",
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearAllConfirmation(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text("Clear All History?", style: AppTypography.titleLarge),
        content: const Text("This will permanently remove all analysis records. This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: AppColors.textTertiary)),
          ),
          ElevatedButton(
            onPressed: () async {
              await userProvider.clearAllReports(); // استدعاء الدالة المعدلة
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("History cleared from server"), backgroundColor: AppColors.error),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text("Clear All", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _HistoryReportCard extends StatelessWidget {
  final ReportItem report;

  const _HistoryReportCard({required this.report});

  Color get _statusColor {
    switch (report.status) {
      case "Completed": return AppColors.success;
      case "Processing": return AppColors.warning;
      case "Failed": return AppColors.error;
      default: return AppColors.textDisabled;
    }
  }

  IconData get _statusIcon {
    switch (report.status) {
      case "Completed": return Icons.check_circle_outline_rounded;
      case "Processing": return Icons.hourglass_top_rounded;
      case "Failed": return Icons.error_outline_rounded;
      default: return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateStr = "${months[report.date.month - 1]} ${report.date.day}, ${report.date.year}";

    String topTrait = "Inconclusive";
    double maxConfidence = -1;

    void updateTopTrait(Map<String, double>? results) {
      if (results != null && results.isNotEmpty) {
        results.forEach((key, value) {
          if (value > maxConfidence) {
            maxConfidence = value;
            topTrait = key;
          }
        });
      }
    }

    updateTopTrait(report.eyeResults);
    updateTopTrait(report.hairResults);
    updateTopTrait(report.skinResults);

    final displayTrait = topTrait.contains(':') ? topTrait.split(':').last : topTrait;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: AppColors.glassCard(
        borderColor: _statusColor.withAlpha(40),
        radius: AppRadius.lg,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _statusColor.withAlpha(25),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(_statusIcon, color: _statusColor, size: 22),
          ),
          AppSpacing.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<UserProvider>(
                  builder: (context, userProvider, _) {
                    // الأولوية لـ sample_name اللي جاي من الـ JSON الجديد
                    final displayName = (report.sampleName.isNotEmpty) 
                        ? report.sampleName 
                        : "Report #${report.id}";
                        
                    return Text(
                      displayName,
                      style: AppTypography.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
                AppSpacing.vXs,
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.textTertiary),
                    AppSpacing.hXs,
                    Text(dateStr, style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
                    AppSpacing.hBase,
                    const Icon(Icons.auto_awesome_rounded, size: 12, color: AppColors.primary),
                    AppSpacing.hXs,
                    Text(
                      "Primary: $displayTrait",
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showDeleteConfirmation(context),
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textTertiary, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Delete',
          ),
          const SizedBox(width: 12),
          if (report.status == "Completed")
            ElevatedButton(
              onPressed: () => _navigateToResults(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  side: const BorderSide(color: AppColors.primary),
                ),
              ),
              child: Text(
                "View",
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(150),
      builder: (context) => Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated.withAlpha(200),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon at top
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.base),
                          decoration: BoxDecoration(
                            color: AppColors.error.withAlpha(20),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.error_outline_rounded,
                            color: AppColors.error,
                            size: 40,
                          ),
                        ),
                        AppSpacing.vLg,
                        // Title
                        Text(
                          "Delete Analysis?",
                          textAlign: TextAlign.center,
                          style: AppTypography.displayLarge,
                        ),
                        AppSpacing.vSm,
                        // Content Text
                        Text(
                          "This will permanently remove the record.",
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
                        ),
                        AppSpacing.vXl,
                        // Actions
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                                ),
                                child: Text(
                                  "Cancel",
                                  style: AppTypography.labelLarge.copyWith(color: AppColors.textTertiary),
                                ),
                              ),
                            ),
                            AppSpacing.hMd,
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: () async {
                                  await Provider.of<UserProvider>(context, listen: false).removeReport(report.id);
                                  if (context.mounted) Navigator.pop(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFEF5350), Color(0xFFD32F2F)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(100),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.error.withAlpha(60),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Delete",
                                    style: AppTypography.labelLarge.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
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
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToResults(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AnalysisResultScreen(
          hairResults: report.hairResults ?? {},
          eyeResults: report.eyeResults ?? {},
          skinResults: report.skinResults ?? {},
          analysisId: report.id,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    );
  }
}