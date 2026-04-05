import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../theme/app_theme.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  // ─── API logic unchanged ───────────────────────────────────────────────────
  Future<void> _sendMessage() async {
    final contactData = {
      "username": _usernameController.text.trim(),
      "email": _emailController.text.trim(),
      "subject": _subjectController.text.trim(),
      "body": _bodyController.text.trim(),
    };

    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.apiUrl}${ApiConfig.contactUsEndpoint}"),
        headers: {
          "Content-Type": "application/json",
          ...ApiConfig.ngrokHeaders,
        },
        body: jsonEncode(contactData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar("Message sent successfully!", isSuccess: true);
        _usernameController.clear();
        _emailController.clear();
        _subjectController.clear();
        _bodyController.clear();
      } else {
        debugPrint("Status Code: ${response.statusCode}");
        _showSnackBar(
            "Failed to send message. Server returned ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error: $e");
      _showSnackBar("Error connecting to server. Check your connection.");
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isSuccess ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
    );
  }

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: 'genoscenee@gmail.com',
        query: 'subject=Support Request');
    if (!await launchUrl(emailLaunchUri)) {
      debugPrint('Could not launch email');
    }
  }
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Contact Us",
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero ──
                AnimatedEntrance(
                  child: Container(
                    width: double.infinity,
                    padding: AppSpacing.cardLarge,
                    decoration: BoxDecoration(
                      gradient: AppColors.elevatedCardGradient,
                      borderRadius: AppRadius.card,
                      border: Border.all(
                          color: AppColors.surfaceBorderAccent),
                    ),
                    child: Column(
                      children: [
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
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.support_agent_rounded,
                              color: Colors.white, size: 30),
                        ),
                        AppSpacing.vBase,
                        Text("We're here to help!",
                            style: AppTypography.titleMedium),
                        AppSpacing.vXs,
                        Text(
                          "Have questions about your DNA analysis? Reach out to us.",
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall
                              .copyWith(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),

                AppSpacing.vXl,

                // ── Email card ──
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 80),
                  child: Semantics(
                    button: true,
                    label: 'Send email to genoscenee@gmail.com',
                    child: GestureDetector(
                      onTap: _launchEmail,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.base),
                        decoration: AppColors.glassCard(
                          borderColor: AppColors.surfaceBorderAccent,
                          radius: AppRadius.lg,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryMuted,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                              ),
                              child: const Icon(Icons.email_outlined,
                                  color: AppColors.primary, size: 22),
                            ),
                            AppSpacing.hMd,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Official Support",
                                      style: AppTypography.titleSmall),
                                  Text(
                                    "genoscenee@gmail.com",
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.primary,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.open_in_new_rounded,
                                color: AppColors.primary, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                AppSpacing.vXl,

                // ── Form ──
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 140),
                  child: Container(
                    decoration: AppColors.glassCard(
                      borderColor: AppColors.surfaceBorder,
                      radius: AppRadius.xl,
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
                              topLeft: Radius.circular(AppRadius.xl),
                              topRight: Radius.circular(AppRadius.xl),
                            ),
                            border: const Border(
                                bottom: BorderSide(
                                    color: AppColors.surfaceBorderAccent)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.message_outlined,
                                  color: AppColors.primary, size: 18),
                              AppSpacing.hSm,
                              Text("Send a Message",
                                  style: AppTypography.titleSmall
                                      .copyWith(color: AppColors.primary)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.base),
                          child: Column(
                            children: [
                              _formField(
                                label: "Username",
                                hint: "e.g., saloma123",
                                icon: Icons.person_outline,
                                controller: _usernameController,
                              ),
                              AppSpacing.vBase,
                              _formField(
                                label: "Your Email",
                                hint: "Enter your email",
                                icon: Icons.email_outlined,
                                controller: _emailController,
                              ),
                              AppSpacing.vBase,
                              _formField(
                                label: "Subject",
                                hint: "Technical Issue",
                                icon: Icons.subject_rounded,
                                controller: _subjectController,
                              ),
                              AppSpacing.vBase,
                              _formField(
                                label: "Message",
                                hint: "Type your message here...",
                                icon: Icons.message_outlined,
                                controller: _bodyController,
                                maxLines: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                AppSpacing.vXl,

                // ── Send button ──
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 200),
                  child: _buildSendButton(),
                ),

                AppSpacing.vBase,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _formField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600)),
        AppSpacing.vXs,
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: AppTypography.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMedium
                .copyWith(color: AppColors.textHint),
            prefixIcon: maxLines == 1
                ? Icon(icon,
                    color: AppColors.textDisabled, size: 19)
                : null,
            filled: true,
            fillColor: AppColors.surfaceCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide:
                  const BorderSide(color: AppColors.surfaceBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                  color: AppColors.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSendButton() {
    return Semantics(
      button: true,
      label: 'Send message',
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
            onPressed: () {
              HapticFeedback.mediumImpact();
              _sendMessage();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.xl)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.send_rounded,
                    size: 18, color: Colors.white),
                AppSpacing.hSm,
                Text("Send Message",
                    style: AppTypography.titleSmall
                        .copyWith(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
