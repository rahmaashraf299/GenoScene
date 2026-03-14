import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomNameDialog extends StatefulWidget {
  final String initialName;

  const CustomNameDialog({
    super.key,
    required this.initialName,
  });

  @override
  State<CustomNameDialog> createState() => _CustomNameDialogState();
}

class _CustomNameDialogState extends State<CustomNameDialog> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
        decoration: AppColors.glassCard(
          backgroundColor: AppColors.surface.withAlpha(245), // Deep Dark Navy
          borderColor: AppColors.surfaceBorderAccent.withAlpha(80),
          radius: AppRadius.xl,
          shadows: [
            BoxShadow(
              color: AppColors.primary.withAlpha(25),
              blurRadius: 40,
              spreadRadius: 2,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl, horizontal: AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Header
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withAlpha(40)),
                  ),
                  child: const Icon(
                    Icons.drive_file_rename_outline_rounded,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                AppSpacing.vMd,
                
                // Title
                Text(
                  "Sample Identity",
                  style: AppTypography.displayLarge.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                AppSpacing.vXs,
                Text(
                  "Give this analysis a name for easier identification:",
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                AppSpacing.vXl,

                // Main Content - Edit TextField
                _buildEditingMode(),
                
                // Final Action Buttons
                AppSpacing.vXl,
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditingMode() {
    return Container(
      key: const ValueKey("edit_mode"),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withAlpha(150),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.primary.withAlpha(100)),
      ),
      child: TextField(
        controller: _nameController,
        autofocus: true,
        style: AppTypography.bodyLarge.copyWith(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Enter sample name...",
          hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.base),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.description_outlined, color: AppColors.primary, size: 20),
        ),
        onSubmitted: (_) => Navigator.pop(context, _nameController.text.trim()),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pop(context, widget.initialName),
            child: Text(
              "Use Filename",
              style: AppTypography.labelLarge.copyWith(color: AppColors.textTertiary),
            ),
          ),
        ),
        AppSpacing.hMd,
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(50),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, _nameController.text.trim()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              child: Text(
                "Save & Continue",
                style: AppTypography.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
