import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentUsername;
  final String currentEmail;
  final String? currentProfilePic;

  const EditProfileScreen({
    super.key,
    required this.currentUsername,
    required this.currentEmail,
    this.currentProfilePic,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _image;
  Uint8List? _webImage;
  final picker = ImagePicker();

  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _oldPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;

  // ─── API logic unchanged ───────────────────────────────────────────────────
  final String baseUrl =
      "https://naida-pterodactylous-chillingly.ngrok-free.dev/api";

  @override
  void initState() {
    super.initState();
    _usernameController =
        TextEditingController(text: widget.currentUsername);
    _emailController = TextEditingController(text: widget.currentEmail);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        var f = await pickedFile.readAsBytes();
        setState(() => _webImage = f);
      } else {
        setState(() => _image = File(pickedFile.path));
      }
    }
  }

  Future<void> _updateProfile() async {
    final token = await AuthService.getToken();
    if (token == null) return;

    var uri = Uri.parse("$baseUrl/me/");
    var request = http.MultipartRequest('PUT', uri);

    request.headers.addAll({
      "Authorization": "Bearer $token",
      "ngrok-skip-browser-warning": "69420",
    });

    request.fields['username'] = _usernameController.text.trim();
    request.fields['email'] = _emailController.text.trim();

    if (kIsWeb && _webImage != null) {
      request.files.add(http.MultipartFile.fromBytes(
          'profile_picture', _webImage!,
          filename: 'profile.jpg'));
    } else if (_image != null) {
      request.files.add(
          await http.MultipartFile.fromPath(
              'profile_picture', _image!.path));
    }

    try {
      var streamedResponse = await request.send();
      var response =
          await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        String? newPicUrl = responseData['profile_picture'];
        if (newPicUrl != null) {
          // إضافة /media/ لو ناقصة
          if (newPicUrl.startsWith('http') && !newPicUrl.contains('/media/')) {
            newPicUrl = newPicUrl.replaceFirst('/profile_pics/', '/media/profile_pics/');
          } else if (!newPicUrl.startsWith('http')) {
            final cleanPath = newPicUrl.startsWith('/') ? newPicUrl.substring(1) : newPicUrl;
            newPicUrl = "https://naida-pterodactylous-chillingly.ngrok-free.dev/media/$cleanPath";
          }
          newPicUrl =
              "$newPicUrl?v=${DateTime.now().millisecondsSinceEpoch}";
          AuthService.updateProfilePic(newPicUrl);
        }

        if (_newPasswordController.text.isNotEmpty) {
          await _changePassword();
        }

        if (mounted) {
          _showSuccess("Profile Updated Successfully!");
          Navigator.pop(context, true);
        }
      } else {
        _showError("Failed to update profile");
      }
    } catch (e) {
      _showError("Connection error. Check Ngrok.");
    }
  }

  Future<void> _changePassword() async {
    final token = await AuthService.getToken();
    var url = Uri.parse("$baseUrl/me/change-password/");
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "69420"
        },
        body: jsonEncode({
          "old_password": _oldPasswordController.text,
          "new_password": _newPasswordController.text,
          "new_password_confirm": _confirmPasswordController.text,
        }),
      );
      if (response.statusCode != 200) _showError("Password change failed.");
    } catch (e) {
      debugPrint("Pass Error: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md)),
    ));
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md)),
    ));
  }
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Edit Profile", style: AppTypography.titleLarge),
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
              children: [
                // ── Avatar ──
                AnimatedEntrance(child: _buildAvatarSection()),

                AppSpacing.vXxl,

                // ── Profile fields ──
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 80),
                  child: _sectionCard(
                    title: "Personal Info",
                    icon: Icons.person_outline,
                    children: [
                      _editField(
                          label: "Username",
                          icon: Icons.person_outline,
                          controller: _usernameController),
                      AppSpacing.vBase,
                      _editField(
                          label: "Email Address",
                          icon: Icons.email_outlined,
                          controller: _emailController),
                    ],
                  ),
                ),

                AppSpacing.vBase,

                // ── Password fields ──
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 140),
                  child: _sectionCard(
                    title: "Change Password",
                    icon: Icons.lock_outline,
                    children: [
                      _editField(
                          label: "Current Password",
                          icon: Icons.lock_outline,
                          isPassword: true,
                          isPasswordVisible: _oldPasswordVisible,
                          onToggle: () => setState(() =>
                              _oldPasswordVisible = !_oldPasswordVisible),
                          controller: _oldPasswordController),
                      AppSpacing.vBase,
                      _editField(
                          label: "New Password",
                          icon: Icons.lock_reset_outlined,
                          isPassword: true,
                          isPasswordVisible: _newPasswordVisible,
                          onToggle: () => setState(() =>
                              _newPasswordVisible = !_newPasswordVisible),
                          controller: _newPasswordController),
                      AppSpacing.vBase,
                      _editField(
                          label: "Confirm New Password",
                          icon: Icons.lock_reset_outlined,
                          isPassword: true,
                          isPasswordVisible: _confirmPasswordVisible,
                          onToggle: () => setState(() =>
                              _confirmPasswordVisible =
                                  !_confirmPasswordVisible),
                          controller: _confirmPasswordController),
                    ],
                  ),
                ),

                AppSpacing.vXl,

                // ── Save button ──
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 200),
                  child: _buildSaveButton(),
                ),

                AppSpacing.vBase,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    ImageProvider imageProvider;
    if (kIsWeb && _webImage != null) {
      imageProvider = MemoryImage(_webImage!);
    } else if (!kIsWeb && _image != null) {
      imageProvider = FileImage(_image!);
    } else if (widget.currentProfilePic != null) {
      imageProvider = NetworkImage(
          "${widget.currentProfilePic}?v=${DateTime.now().millisecondsSinceEpoch}");
    } else {
      imageProvider =
          const AssetImage('assets/images/genoscene_logo.png');
    }

    return Semantics(
      label: 'Profile picture, tap to change',
      button: true,
      child: Stack(
        alignment: Alignment.center,
        children: [
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
              radius: 58,
              backgroundColor: AppColors.surface,
              backgroundImage: imageProvider,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(100),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Icon(Icons.camera_alt_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: AppColors.glassCard(
        borderColor: AppColors.surfaceBorder,
        radius: AppRadius.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primaryMuted,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadius.xl),
                topRight: Radius.circular(AppRadius.xl),
              ),
              border: const Border(
                  bottom: BorderSide(color: AppColors.surfaceBorderAccent)),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 18),
                AppSpacing.hSm,
                Text(title,
                    style: AppTypography.titleSmall
                        .copyWith(color: AppColors.primary)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _editField({
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onToggle,
    required TextEditingController controller,
  }) {
    return _FocusField(
      label: label,
      icon: icon,
      controller: controller,
      isPassword: isPassword,
      isPasswordVisible: isPasswordVisible,
      onToggle: onToggle,
    );
  }

  Widget _buildSaveButton() {
    return Semantics(
      button: true,
      label: 'Save changes',
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
            onPressed: _updateProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.xl)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.save_rounded,
                    size: 20, color: Colors.white),
                AppSpacing.hSm,
                Text("Save Changes",
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

// ── Focus-aware field ─────────────────────────────────────────────────────────
class _FocusField extends StatefulWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback? onToggle;

  const _FocusField({
    required this.label,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.onToggle,
  });

  @override
  State<_FocusField> createState() => _FocusFieldState();
}

class _FocusFieldState extends State<_FocusField> {
  final FocusNode _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(
        () => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: AppTypography.labelMedium.copyWith(
                color: _focused
                    ? AppColors.primary
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w600)),
        AppSpacing.vXs,
        AnimatedContainer(
          duration: AppMotion.fast,
          decoration: BoxDecoration(
            color: _focused
                ? AppColors.surfaceCardStrong
                : AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: _focused
                  ? AppColors.primary.withAlpha(150)
                  : AppColors.surfaceBorder,
              width: _focused ? 1.5 : 1,
            ),
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focus,
            obscureText:
                widget.isPassword ? !widget.isPasswordVisible : false,
            style: AppTypography.bodyLarge,
            decoration: InputDecoration(
              prefixIcon: Icon(widget.icon,
                  color: _focused
                      ? AppColors.primary
                      : AppColors.textDisabled,
                  size: 19),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base, vertical: 15),
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
                          size: 19,
                        ),
                        onPressed: widget.onToggle,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
