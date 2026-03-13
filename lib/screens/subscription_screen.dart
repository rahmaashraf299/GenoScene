import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  SubscriptionCategory _category = SubscriptionCategory.individual;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.heroGradient,
        ),
        child: Stack(
          children: [
            // Background decor elements
            Positioned(
              top: -100,
              right: -50,
              child: _buildBlurCircle(AppColors.primary.withAlpha(40), 250),
            ),
            Positioned(
              bottom: 100,
              left: -80,
              child: _buildBlurCircle(AppColors.secondary.withAlpha(30), 300),
            ),

            SafeArea(
              child: Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        children: [
                          _buildHeader(),
                          AppSpacing.vXl,
                          _buildCategoryToggle(),
                          AppSpacing.vXl,
                          _buildPlansList(),
                          AppSpacing.vXl,
                          _buildPremiumFeatures(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlurCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: const SizedBox(),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            "Premium Access",
            style: AppTypography.titleLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(20),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary.withAlpha(60), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(30),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.primary,
            size: 56,
          ),
        ),
        AppSpacing.vLg,
        Text(
          "Unlock Full Potential",
          style: AppTypography.displayLarge.copyWith(fontSize: 28),
          textAlign: TextAlign.center,
        ),
        AppSpacing.vSm,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Text(
            "Choose the plan that fits your analysis needs.",
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryToggle() {
    return Container(
      height: 56,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          _buildToggleButton(
            title: "Individual",
            active: _category == SubscriptionCategory.individual,
            onTap: () =>
                setState(() => _category = SubscriptionCategory.individual),
          ),
          _buildToggleButton(
            title: "Government",
            active: _category == SubscriptionCategory.government,
            onTap: () =>
                setState(() => _category = SubscriptionCategory.government),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String title,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            gradient: active ? AppColors.accentGradient : null,
            color: active ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(90),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: AppTypography.titleSmall.copyWith(
              color: active ? Colors.white : AppColors.textTertiary,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlansList() {
    if (_category == SubscriptionCategory.individual) {
      return Column(
        children: [
          _buildPlanCard(
            title: "Basic",
            price: "\$30",
            reports: "5 Predictions",
            description: "Essential DNA analysis for enthusiasts.",
            icon: Icons.science_outlined,
            isFeatured: true, // تفعيل عشان ياخد اللون الغامق
          ),
          AppSpacing.vMd,
          _buildPlanCard(
            title: "Standard",
            price: "\$75",
            reports: "15 Predictions",
            description: "Deeper insights with multiple samples.",
            icon: Icons.biotech_outlined,
            isFeatured: true,
          ),
        ],
      );
    } else {
      return Column(
        children: [
          _buildPlanCard(
            title: "Starter",
            price: "\$250",
            reports: "100 Reports",
            description: "Perfect for research labs and clinics.",
            icon: Icons.apartment_rounded,
            isFeatured: true, // تم حذف الألوان المخصصة القديمة
          ),
          AppSpacing.vMd,
          _buildPlanCard(
            title: "Enterprise",
            price: "\$1000",
            reports: "500 Reports",
            description: "Powering national DNA initiatives.",
            icon: Icons.public_rounded,
            badge: "Best Value",
            isFeatured: true,
          ),
        ],
      );
    }
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String reports,
    required String description,
    required IconData icon,
    String? badge,
    bool isFeatured = false,
  }) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final bool isGuest = userProvider.isGuest;
    
    // الألوان موحدة الآن بناءً على كرت الـ Enterprise
    final Color textColor = Colors.white;
    final Color secondaryTextColor = AppColors.textTertiary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated.withAlpha(180), 
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: AppColors.primary.withAlpha(120), 
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(30),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: AppColors.primary.withAlpha(60),
                      ),
                    ),
                    child: Icon(
                      icon, 
                      color: AppColors.primary, 
                      size: 28,
                    ),
                  ),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(60),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        badge.toUpperCase(),
                        style: AppTypography.badge.copyWith(
                          color: Colors.white,
                          fontSize: 9,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                ],
              ),
              AppSpacing.vLg,
              Text(title, style: AppTypography.displaySmall.copyWith(fontSize: 20, color: textColor)),
              AppSpacing.vXs,
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price, 
                    style: AppTypography.displayLarge.copyWith(
                      fontSize: 32,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6, left: 6),
                    child: Text(
                      "/ one-time", 
                      style: AppTypography.labelMedium.copyWith(color: secondaryTextColor),
                    ),
                  ),
                ],
              ),
              AppSpacing.vMd,
              Text(
                reports, 
                style: AppTypography.titleLarge.copyWith(fontSize: 16, color: textColor),
              ),
              AppSpacing.vXs,
              Text(
                description, 
                style: AppTypography.bodyMedium.copyWith(color: secondaryTextColor),
              ),
              AppSpacing.vXl,
              GestureDetector(
                onTap: isGuest ? null : () => _handlePurchase(title),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(90),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    isGuest ? "Login to Subscribe" : "Select Plan", 
                    style: AppTypography.labelLarge.copyWith(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
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

  Widget _buildPremiumFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Premium Benefits", style: AppTypography.titleMedium),
        AppSpacing.vBase,
        _buildFeatureItem("Detailed DNA Phenotyping"),
        _buildFeatureItem("Export as Premium PDF Reports"),
        _buildFeatureItem("Secure Cloud Genomic Storage"),
        _buildFeatureItem("Priority Batch Processing"),
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
          AppSpacing.hBase,
          Text(text, style: AppTypography.bodyMedium),
        ],
      ),
    );
  }

  void _handlePurchase(String planName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: Text("Confirm Purchase", style: AppTypography.titleLarge),
        content: Text("Would you like to subscribe to the $planName plan?", style: AppTypography.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: AppTypography.labelLarge.copyWith(color: AppColors.textDisabled)),
          ),
          ElevatedButton(
            onPressed: () {
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              int reports = planName.contains('100') ? 100 : (planName.contains('500') ? 500 : (planName.contains('5') ? 5 : 15));
              userProvider.updateSubscription(planName, _category, reports);
              Navigator.pop(context); 
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Subscribed to $planName successfully!"),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }
}