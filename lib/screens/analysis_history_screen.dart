import 'dart:ui';
import 'package:flutter/material.dart';
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
    // استدعاء البيانات من الباك-إند فور فتح الشاشة
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
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.error),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Dialog(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: AppColors.glassCard(
                        backgroundColor: AppColors.surfaceElevated.withAlpha(230),
                        borderColor: AppColors.error.withAlpha(80),
                        radius: AppRadius.xl,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.error.withAlpha(25),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.warning_amber_rounded, size: 40, color: AppColors.error),
                          ),
                          AppSpacing.vLg,
                          Text("Clear All History?", style: AppTypography.displaySmall, textAlign: TextAlign.center),
                          AppSpacing.vSm,
                          Text(
                            "This action cannot be undone. All your previous DNA analysis reports will be permanently deleted.", 
                            style: AppTypography.bodyMedium, 
                            textAlign: TextAlign.center,
                          ),
                          AppSpacing.vXl,
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                                  ),
                                  child: Text("Cancel", style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary)),
                                ),
                              ),
                              AppSpacing.hMd,
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                                  ),
                                  child: Text("Clear All", style: AppTypography.labelLarge.copyWith(color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
              if (confirmed == true) {
                final provider = Provider.of<UserProvider>(context, listen: false);
                await provider.clearAllReports();
                await provider.loadReports();
              }
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
              // حالة التحميل (Loading)
              if (userProvider.isReportsLoading && userProvider.reports.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final reports = userProvider.reports;

              // حالة عدم وجود بيانات (Empty State)
              if (reports.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () => userProvider.loadReports(),
                color: AppColors.primary,
                backgroundColor: AppColors.surfaceCard,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, vertical: AppSpacing.base),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    return AnimatedEntrance(
                      delay: Duration(milliseconds: index * 60),
                      child: _HistoryReportCard(report: reports[index]),
                    );
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
}

class _HistoryReportCard extends StatelessWidget {
  final ReportItem report;

  const _HistoryReportCard({required this.report});

  // منطق الألوان بناءً على حالة الريبورت القادم من الباك-إند
  Color get _statusColor {
    switch (report.status) {
      case "Completed":
        return AppColors.success;
      case "Processing":
        return AppColors.warning;
      case "Failed":
        return AppColors.error;
      default:
        return AppColors.textDisabled;
    }
  }

  IconData get _statusIcon {
    switch (report.status) {
      case "Completed":
        return Icons.check_circle_outline_rounded;
      case "Processing":
        return Icons.hourglass_top_rounded;
      case "Failed":
        return Icons.error_outline_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    // تنسيق التاريخ المستلم من الباك-إند
    final List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dateStr = "${months[report.date.month - 1]} ${report.date.day}, ${report.date.year}";

    String topTrait = "Inconclusive";
    double maxConfidence = -1;

    // دالة لتحديد السمة الغالبة بناءً على أعلى نسبة مئوية راجعة من الـ AI
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
                Text(
                  (report.sampleName == null || report.sampleName == "Unknown Sample" || report.sampleName.isEmpty)
                      ? 'Report #${report.id}'
                      : report.sampleName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.vXs,
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.textTertiary),
                    AppSpacing.hXs,
                    Text(dateStr, style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
                    AppSpacing.hBase,
                    Icon(Icons.auto_awesome_rounded, size: 12, color: AppColors.primary),
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
          // زر العرض لا يظهر إلا إذا كانت الحالة مكتملة والبيانات موجودة
          if (report.status == "Completed" && 
              report.hairResults != null && 
              report.eyeResults != null)
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
          const SizedBox(width: 8),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 24),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Dialog(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: AppColors.glassCard(
                        backgroundColor: AppColors.surfaceElevated.withAlpha(230),
                        borderColor: AppColors.error.withAlpha(80),
                        radius: AppRadius.xl,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.error.withAlpha(25),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.delete_outline_rounded, size: 40, color: AppColors.error),
                          ),
                          AppSpacing.vLg,
                          Text("Delete Report?", style: AppTypography.displaySmall, textAlign: TextAlign.center),
                          AppSpacing.vSm,
                          Text(
                            "Are you sure you want to delete this report? This action cannot be undone.", 
                            style: AppTypography.bodyMedium, 
                            textAlign: TextAlign.center,
                          ),
                          AppSpacing.vXl,
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                                  ),
                                  child: Text("Cancel", style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary)),
                                ),
                              ),
                              AppSpacing.hMd,
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                                  ),
                                  child: Text("Delete", style: AppTypography.labelLarge.copyWith(color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );

              if (confirmed == true) {
                final provider = Provider.of<UserProvider>(context, listen: false);
                await provider.removeReport(report.id.toString());
                await provider.loadReports();
              }
            },
          ),
        ],
      ),
    );
  }

  void _navigateToResults(BuildContext context) {
    // الانتقال لصفحة النتائج مع تمرير البيانات الحية المستلمة
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AnalysisResultScreen(
          hairResults: report.hairResults!,
          eyeResults: report.eyeResults!,
          skinResults: report.skinResults ?? {}, // التعامل مع احتمالية عدم وجود بيانات للجلد
          analysisId: report.id,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}