import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  // ─── Logic unchanged ───────────────────────────────────────────────────────
  Future<Map<String, dynamic>> _loadPrivacyPolicy() async {
    final String response =
        await rootBundle.loadString('assets/data/privacy_policy.json');
    return json.decode(response);
  }
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Privacy Policy",
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
          child: FutureBuilder<Map<String, dynamic>>(
            future: _loadPrivacyPolicy(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.error, size: 48),
                      AppSpacing.vBase,
                      Text("Error loading policy",
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.error)),
                    ],
                  ),
                );
              } else if (!snapshot.hasData) {
                return Center(
                  child: Text("No data available",
                      style: AppTypography.bodyLarge),
                );
              }

              final data = snapshot.data!;
              final sections = data['sections'] as List;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Intro card ──
                    AnimatedEntrance(
                      child: Container(
                        padding: AppSpacing.cardLarge,
                        decoration: BoxDecoration(
                          gradient: AppColors.elevatedCardGradient,
                          borderRadius: AppRadius.card,
                          border: Border.all(
                              color: AppColors.surfaceBorderAccent),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryMuted,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                              ),
                              child: const Icon(Icons.shield_outlined,
                                  color: AppColors.primary, size: 28),
                            ),
                            AppSpacing.hMd,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Your Privacy Matters",
                                      style: AppTypography.titleSmall),
                                  AppSpacing.vXs,
                                  Text(
                                    data['introduction'] ?? "",
                                    style: AppTypography.bodySmall
                                        .copyWith(height: 1.5),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    AppSpacing.vXl,

                    // ── Sections ──
                    ...sections.asMap().entries.map((entry) {
                      final i = entry.key;
                      final section = entry.value;
                      return AnimatedEntrance(
                        delay: Duration(milliseconds: 60 * (i + 1)),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppSpacing.base),
                          child: Container(
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
                                      vertical: AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryMuted,
                                    borderRadius: BorderRadius.only(
                                      topLeft:
                                          Radius.circular(AppRadius.lg),
                                      topRight:
                                          Radius.circular(AppRadius.lg),
                                    ),
                                    border: const Border(
                                        bottom: BorderSide(
                                            color: AppColors
                                                .surfaceBorderAccent)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              AppColors.primary,
                                              AppColors.secondary
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "${i + 1}",
                                            style: AppTypography.caption
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.w800,
                                                    fontSize: 11),
                                          ),
                                        ),
                                      ),
                                      AppSpacing.hSm,
                                      Expanded(
                                        child: Text(
                                          section['title'],
                                          style: AppTypography.titleSmall
                                              .copyWith(
                                                  color: AppColors.primary),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(
                                      AppSpacing.base),
                                  child: Column(
                                    children: (section['content'] as List)
                                        .map<Widget>((point) => Padding(
                                              padding:
                                                  const EdgeInsets.only(
                                                      bottom:
                                                          AppSpacing.sm),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 6,
                                                    height: 6,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 6,
                                                            right: 10),
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: AppColors.primary,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      point,
                                                      style: AppTypography
                                                          .bodySmall
                                                          .copyWith(
                                                              height: 1.6),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                    AppSpacing.vMd,

                    // Last updated
                    Center(
                      child: Text(
                        "Last Updated: ${data['last_updated']}",
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textHint,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                    AppSpacing.vXl,

                    // Accept button
                    Semantics(
                      button: true,
                      label: 'Accept and continue',
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.secondary
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius:
                                BorderRadius.circular(AppRadius.xl),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(100),
                                blurRadius: 16,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppRadius.xl)),
                            ),
                            child: Text("Accept & Continue",
                                style: AppTypography.titleSmall
                                    .copyWith(color: Colors.white)),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
