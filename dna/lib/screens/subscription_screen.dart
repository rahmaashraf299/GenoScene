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
        Hero(
          tag: 'subscription_icon',
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withAlpha(60)),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primary,
              size: 48,
            ),
          ),
        ),
        AppSpacing.vBase,
        Text(
          "Unlock Full Potential",
          style: AppTypography.displayXl,
          textAlign: TextAlign.center,
        ),
        AppSpacing.vXs,
        Text(
          "Choose the plan that fits your analysis needs.",
          style: AppTypography.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCategoryToggle() {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
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
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(60),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: AppTypography.titleSmall.copyWith(
              color: active ? AppColors.background : AppColors.textSecondary,
              fontWeight: active ? FontWeight.bold : FontWeight.w500,
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppColors.glassCard(
        borderColor: isFeatured ? AppColors.primary.withAlpha(100) : AppColors.surfaceBorder,
        radius: AppRadius.xl,
        backgroundColor: isFeatured ? AppColors.surfaceCardStrong : AppColors.surfaceCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isFeatured ? AppColors.primary.withAlpha(40) : AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: isFeatured ? AppColors.primary : AppColors.textSecondary, size: 24),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.xxl),
                  ),
                  child: Text(
                    badge,
                    style: AppTypography.badge.copyWith(color: AppColors.background),
                  ),
                ),
            ],
          ),
          AppSpacing.vBase,
          Text(title, style: AppTypography.displaySmall),
          AppSpacing.vXs,
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: AppTypography.displayXl.copyWith(color: AppColors.primary)),
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 4),
                child: Text("/one-time", style: AppTypography.bodySmall),
              ),
            ],
          ),
          AppSpacing.vSm,
          Text(reports, style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary)),
          Text(description, style: AppTypography.bodySmall),
          AppSpacing.vLg,
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isGuest ? null : () => _handlePurchase(title),
              style: ElevatedButton.styleFrom(
                backgroundColor: isFeatured ? AppColors.primary : AppColors.surfaceElevated,
                foregroundColor: isFeatured ? AppColors.background : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                elevation: isFeatured ? 8 : 0,
              ),
              child: Text(isGuest ? "Login to Subscribe" : "Select Plan", style: AppTypography.labelLarge),
            ),
          ),
        ],
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
    // Simulate purchase
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
              Navigator.pop(context); // Close dialog
              
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
