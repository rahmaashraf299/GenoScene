import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import '../widgets/dna_loading_overlay.dart';
import 'home_screen.dart';
import '../theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool isLogin = true;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  late final AnimationController _logoController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _logoScale = Tween<double>(begin: 0.75, end: 1.0).animate(
        CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack));
    _logoOpacity = CurvedAnimation(
        parent: _logoController, curve: const Interval(0.0, 0.7));
    _logoController.forward();
    
    // Ensure we start with a clean state on entry to Auth Screen
    // This is critical to prevent guest state leakage from previous sessions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<UserProvider>(context, listen: false).clearUser();
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  // ─── API logic unchanged ───────────────────────────────────────────────────
  Future<void> _handleAuth() async {
    final String baseUrl =
        "https://naida-pterodactylous-chillingly.ngrok-free.dev/api";
    final String endpoint = isLogin ? "/token/" : "/register/";

    Map<String, String> bodyData = {};
    if (isLogin) {
      bodyData = {
        "username": _usernameController.text.trim(),
        "password": _passwordController.text,
      };
    } else {
      bodyData = {
        "username": _usernameController.text.trim(),
        "email": _emailController.text.trim(),
        "password": _passwordController.text,
        "password2": _confirmPasswordController.text,
      };
    }

    try {
      final response = await http.post(
        Uri.parse(baseUrl + endpoint),
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "69420",
        },
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        debugPrint("Success! Access Token: ${responseData['access']}");

        if (isLogin) {
          await AuthService.saveToken(responseData['access']);

          if (!mounted) return;

          DnaLoadingOverlay.show(
            context,
            message: "Welcome Back!",
            subMessage: "Preparing your dashboard...",
          );

          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          
          // CRITICAL: Always ensure guest mode is false on successful login
          userProvider.setGuestMode(false);
          await userProvider.fetchUserProfile();

          await Future.delayed(const Duration(milliseconds: 1200));

          if (!mounted) return;
          DnaLoadingOverlay.hide(context);

          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        } else {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Account created successfully! Please login.'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
          );

          // Also reset guest mode on successful registration success
          Provider.of<UserProvider>(context, listen: false).setGuestMode(false);

          setState(() {
            isLogin = true;
            _usernameController.clear();
            _emailController.clear();
            _passwordController.clear();
            _confirmPasswordController.clear();
          });
        }
      } else {
        debugPrint("Server Error Status: ${response.statusCode}");
        debugPrint("Server Response: ${response.body}");
        _showError(
            "Login failed. Check username/password or Server CORS settings.");
      }
    } catch (e) {
      debugPrint("Connection Catch Error: $e");
      _showError(
          "Connection error: Make sure the Ngrok server is still online.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
    );
  }
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: AppSpacing.screenH,
            child: Column(
              children: [
                const SizedBox(height: 32),

                // ── Logo ──
                ScaleTransition(
                  scale: _logoScale,
                  child: FadeTransition(
                    opacity: _logoOpacity,
                    child: _buildLogo(),
                  ),
                ),

                AppSpacing.vXl,

                AnimatedEntrance(
                  delay: const Duration(milliseconds: 200),
                  child: Column(
                    children: [
                      Text(
                        'Welcome to GenoScene',
                        style: AppTypography.displayLarge,
                        textAlign: TextAlign.center,
                      ),
                      AppSpacing.vXs,
                      Text(
                        'DNA Phenotyping Platform',
                        style: AppTypography.bodyMedium
                            .copyWith(color: AppColors.primary.withAlpha(180)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                AnimatedEntrance(
                  delay: const Duration(milliseconds: 280),
                  child: _buildToggle(),
                ),

                const SizedBox(height: 28),

                AnimatedEntrance(
                  delay: const Duration(milliseconds: 340),
                  child: _buildFormSection(),
                ),

                const SizedBox(height: 28),

                AnimatedEntrance(
                  delay: const Duration(milliseconds: 400),
                  child: Column(
                    children: [
                      _buildSubmitButton(),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () async {
                          final userProvider =
                              Provider.of<UserProvider>(context, listen: false);

                          // Clear any existing tokens to ensure a clean guest session
                          await AuthService.removeToken();
                          userProvider.setGuestMode(true);

                          if (!mounted) return;
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomeScreen()),
                            (route) => false,
                          );
                        },
                        child: Text(
                          "Continue as Guest",
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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

  Widget _buildLogo() {
    return Semantics(
      label: 'GenoScene logo',
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: AppColors.primary.withAlpha(100), blurRadius: 50,
                spreadRadius: 4),
            BoxShadow(
                color: AppColors.secondary.withAlpha(60), blurRadius: 80,
                spreadRadius: 8),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/genoscene_logo.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.biotech,
                size: 60,
                color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _toggleBtn("Login", isLogin, () => setState(() => isLogin = true)),
          _toggleBtn(
              "Register", !isLogin, () => setState(() => isLogin = false)),
        ],
      ),
    );
  }

  Widget _toggleBtn(String title, bool active, VoidCallback onTap) {
    return Expanded(
      child: Semantics(
        button: true,
        label: title,
        selected: active,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: AppMotion.standard,
            curve: AppMotion.curve,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              gradient: active
                  ? const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(60),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                title,
                style: AppTypography.labelLarge.copyWith(
                  color: active
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return Column(
      children: [
        _buildTextField(
          label: 'Username',
          hint: 'Enter your username',
          icon: Icons.person_outline,
          controller: _usernameController,
        ),
        AppSpacing.vBase,
        if (!isLogin) ...[
          _buildTextField(
            label: 'Email',
            hint: 'example@gmail.com',
            icon: Icons.email_outlined,
            controller: _emailController,
          ),
          AppSpacing.vBase,
        ],
        _buildTextField(
          label: 'Password',
          hint: 'Enter your password',
          icon: Icons.lock_outline,
          isPassword: true,
          isPasswordVisible: _passwordVisible,
          onToggleVisibility: () =>
              setState(() => _passwordVisible = !_passwordVisible),
          controller: _passwordController,
        ),
        if (!isLogin) ...[
          AppSpacing.vBase,
          _buildTextField(
            label: 'Confirm Password',
            hint: 'Re-enter your password',
            icon: Icons.lock_outline,
            isPassword: true,
            isPasswordVisible: _confirmPasswordVisible,
            onToggleVisibility: () => setState(
                () => _confirmPasswordVisible = !_confirmPasswordVisible),
            controller: _confirmPasswordController,
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMedium
              .copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
        ),
        AppSpacing.vSm,
        _FocusTextField(
          controller: controller,
          hint: hint,
          icon: icon,
          isPassword: isPassword,
          isPasswordVisible: isPasswordVisible,
          onToggleVisibility: onToggleVisibility,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Semantics(
      button: true,
      label: isLogin ? 'Login' : 'Create Account',
      child: SizedBox(
        width: double.infinity,
        height: 56,
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
                color: AppColors.primary.withAlpha(100),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _handleAuth,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
            ),
            child: Text(
              isLogin ? "Login" : "Create Account",
              style: AppTypography.titleMedium
                  .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Focus-aware text field ──────────────────────────────────────────────────
class _FocusTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback? onToggleVisibility;

  const _FocusTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.onToggleVisibility,
  });

  @override
  State<_FocusTextField> createState() => _FocusTextFieldState();
}

class _FocusTextFieldState extends State<_FocusTextField> {
  final FocusNode _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.fast,
      decoration: BoxDecoration(
        color: _focused
            ? AppColors.surfaceCardStrong
            : AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: _focused ? AppColors.primary.withAlpha(150) : AppColors.surfaceBorder,
          width: _focused ? 1.5 : 1,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        obscureText: widget.isPassword ? !widget.isPasswordVisible : false,
        style: AppTypography.bodyLarge,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: AppTypography.bodyMedium
              .copyWith(color: AppColors.textHint),
          prefixIcon: Icon(widget.icon,
              color: _focused ? AppColors.primary : AppColors.textDisabled,
              size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base, vertical: 16),
          suffixIcon: widget.isPassword
              ? Semantics(
                  label: widget.isPasswordVisible
                      ? 'Hide password'
                      : 'Show password',
                  button: true,
                  child: IconButton(
                    icon: Icon(
                      widget.isPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                    onPressed: widget.onToggleVisibility,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
