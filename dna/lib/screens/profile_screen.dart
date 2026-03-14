import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'edit_profile_screen.dart';
import 'privacy_policy_screen.dart';
import 'contact_us_screen.dart';
import 'auth_screen.dart';
import 'subscription_screen.dart';
import 'analysis_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.fetchUserProfile();
      userProvider.loadReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (userProvider.isGuest) {
          return _buildLockedState();
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.base),
          child: Column(
            children: [
              AppSpacing.vBase,

              // ── Profile avatar & info ──
              AnimatedEntrance(
                child: _buildProfileCard(userProvider),
              ),

              AppSpacing.vXl,

              // ── Menu items ──
              AnimatedEntrance(
                delay: const Duration(milliseconds: 80),
                child: _buildMenuSection(userProvider),
              ),

              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLockedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
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
                Icons.lock_outline_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "Account Locked",
              style: AppTypography.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "Profile management and personalized DNA reports are exclusive to registered members.",
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(80),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Reset guest mode before going to Auth screen
                    Provider.of<UserProvider>(context, listen: false).clearUser();
                    
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const AuthScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.xl)),
                  ),
                  child: Text(
                    "Register Now",
                    style: AppTypography.titleMedium.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(UserProvider userProvider) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardLarge,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A3A5C), Color(0xFF0F2440)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.surfaceBorderAccent),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(30),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar with gradient ring
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(100),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            padding: const EdgeInsets.all(3),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.surface,
              backgroundImage: (userProvider.profilePicture != null &&
                      userProvider.profilePicture!.isNotEmpty)
                  ? NetworkImage(userProvider.profilePicture!)
                  : const AssetImage('assets/images/genoscene_logo.png')
                      as ImageProvider,
            ),
          ),

          AppSpacing.vBase,

          Text(
            userProvider.username ?? "User",
            style: AppTypography.displaySmall,
          ),

          AppSpacing.vXs,

          Text(
            userProvider.email ?? "No email set",
            style: AppTypography.bodyMedium,
          ),

          AppSpacing.vBase,

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _statChip(Icons.science_outlined, "DNA Analyst"),
              AppSpacing.hMd,
              _statChip(Icons.verified_outlined, "Verified"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryMuted,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.surfaceBorderAccent),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 14),
          AppSpacing.hXs,
          Text(
            label,
            style: AppTypography.badge,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(UserProvider userProvider) {
    final menuItems = [
      _MenuItem(
        icon: Icons.edit_outlined,
        title: "Edit Profile",
        subtitle: "Update your info & photo",
        color: AppColors.primary,
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfileScreen(
                currentUsername: userProvider.username ?? "",
                currentEmail: userProvider.email ?? "",
                currentProfilePic: userProvider.profilePicture,
              ),
            ),
          );
          if (result == true && mounted) {
            Provider.of<UserProvider>(context, listen: false)
                .fetchUserProfile();
          }
        },
      ),
      _MenuItem(
        icon: Icons.card_membership_rounded,
        title: "Subscription Plans",
        subtitle: "Upgrade for premium insights",
        color: const Color(0xFFFFD700), // Premium Gold
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SubscriptionScreen(),
          ),
        ),
      ),
      _MenuItem(
        icon: Icons.history_rounded,
        title: "Analysis History",
        subtitle: "View your past DNA results",
        color: AppColors.secondary,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AnalysisHistoryScreen(),
          ),
        ),
      ),
      _MenuItem(
        icon: Icons.privacy_tip_outlined,
        title: "Privacy Policy",
        subtitle: "How we handle your data",
        color: AppColors.info,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const PrivacyPolicyScreen()),
        ),
      ),
      _MenuItem(
        icon: Icons.headset_mic_outlined,
        title: "Contact Us",
        subtitle: "Get help & support",
        color: AppColors.success,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const ContactUsScreen()),
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: AppSpacing.md),
          child: Text("Account", style: AppTypography.sectionHeader),
        ),
        ...menuItems.asMap().entries.map((e) => AnimatedEntrance(
              delay: Duration(milliseconds: 80 + e.key * 60),
              child: _buildMenuItem(e.value),
            )),
        AppSpacing.vBase,
        AnimatedEntrance(
          delay: const Duration(milliseconds: 320),
          child: _buildLogoutTile(),
        ),
      ],
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Semantics(
        button: true,
        label: item.title,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: item.onTap,
            borderRadius: AppRadius.card,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.base),
              decoration: AppColors.glassCard(
                borderColor: item.color.withAlpha(40),
                radius: AppRadius.lg,
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: item.color.withAlpha(25),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: item.title == "Subscription Plans"
                        ? Hero(
                            tag: 'subscription_icon',
                            child: Icon(item.icon, color: item.color, size: 20),
                          )
                        : Icon(item.icon, color: item.color, size: 20),
                  ),
                  AppSpacing.hMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: AppTypography.titleSmall),
                        Text(item.subtitle,
                            style: AppTypography.bodySmall
                                .copyWith(color: AppColors.textTertiary)),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: AppColors.textDisabled, size: 14),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutTile() {
    return Semantics(
      button: true,
      label: 'Log out',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLogoutDialog(context),
          borderRadius: AppRadius.card,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(
              color: AppColors.errorMuted,
              borderRadius: AppRadius.card,
              border: Border.all(color: AppColors.error.withAlpha(60)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(30),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(Icons.logout_rounded,
                      color: AppColors.error, size: 20),
                ),
                AppSpacing.hMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Log Out",
                          style: AppTypography.titleSmall
                              .copyWith(color: AppColors.error)),
                      Text("Sign out of your account",
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.error.withAlpha(160))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: AppSpacing.screenAll,
            decoration: BoxDecoration(
              color: AppColors.surface.withAlpha(240),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              border: const Border(
                top: BorderSide(color: AppColors.surfaceBorder),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  AppSpacing.vXl,
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.errorMuted,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.logout_rounded,
                        color: AppColors.error, size: 32),
                  ),
                  AppSpacing.vBase,
                  Text("Stepping out?",
                      style: AppTypography.displaySmall),
                  AppSpacing.vSm,
                  Text(
                    "Are you sure you want to log out?",
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium,
                  ),
                  AppSpacing.vXl,
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.error.withAlpha(80),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          await AuthService.removeToken();
                          if (context.mounted) {
                            Provider.of<UserProvider>(context, listen: false)
                                .clearUser();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const AuthScreen()),
                              (route) => false,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.xl)),
                        ),
                        child: Text("Log Out",
                            style: AppTypography.titleMedium
                                .copyWith(color: Colors.white)),
                      ),
                    ),
                  ),
                  AppSpacing.vMd,
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Stay Logged In",
                        style: AppTypography.bodyLarge
                            .copyWith(color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}
