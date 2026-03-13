import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/dna_loading_overlay.dart';
import '../services/auth_service.dart';
import '../widgets/custom_name_dialog.dart';
import 'package:http_parser/http_parser.dart';
class AnalysisUploadScreen extends StatefulWidget {
  const AnalysisUploadScreen({super.key});

  @override
  State<AnalysisUploadScreen> createState() => _AnalysisUploadScreenState();
}

class _AnalysisUploadScreenState extends State<AnalysisUploadScreen> {
  String? _fileName;
  String? _customName;
  PlatformFile? _pickedFile;
  bool _isAnalyzing = false;

  // ─── Logic unchanged ───────────────────────────────────────────────────────
  Future<void> _pickFile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.isGuest) {
      _showError("Guest users cannot upload DNA data. Please Register to use this feature.");
      return;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt'],
        withData: true,
      );
      if (result != null) {
        setState(() {
          _fileName = result.files.single.name;
          _pickedFile = result.files.single;
        });

        if (mounted) {
          final String? newName = await showDialog<String>(
            context: context,
            barrierDismissible: false,
            builder: (context) => CustomNameDialog(initialName: _fileName!),
          );

          if (newName != null && newName.isNotEmpty) {
            setState(() {
              _customName = newName;
            });
          }
        }
      }
    } catch (e) {
      debugPrint("File picker error: $e");
    }
  }

//static const String _analysisUrl = "http://10.0.2.2:8080/analyze";
  // تغيير العنوان ليتوافق مع الباك-إند (Port 8000) ومع الكروم (localhost)

Future<void> _uploadAndAnalyze() async {
  if (_pickedFile == null) return;
  setState(() => _isAnalyzing = true);
  DnaLoadingOverlay.show(context, message: "Uploading...");

  try {
    final token = await AuthService.getToken();
    final baseUrl = "https://naida-pterodactylous-chillingly.ngrok-free.dev/api";

    // --- الخطوة 1: الرفع ---
    var uploadRequest = http.MultipartRequest('POST', Uri.parse('$baseUrl/dna-samples/upload-file/'));
    uploadRequest.headers.addAll({
      "Authorization": "Bearer $token",
      "ngrok-skip-browser-warning": "69420",
    });

    uploadRequest.fields['name'] = _customName ?? _fileName ?? "Sample";

    if (_pickedFile!.bytes != null) {
  uploadRequest.files.add(http.MultipartFile.fromBytes(
    'file', // غيري دي من dna_file لـ file
    _pickedFile!.bytes!,
    filename: _fileName ?? 'data.csv',
    contentType: MediaType('text', 'csv'), 
  ));
}

    var streamedResponse = await uploadRequest.send();
    var uploadResponse = await http.Response.fromStream(streamedResponse);

    // لو السيرفر رفض (400)، هنطبع السبب اللي هو كاتبه بنفسه
    if (uploadResponse.statusCode != 200 && uploadResponse.statusCode != 201) {
      print("SERVER ERROR BODY: ${uploadResponse.body}"); // ده أهم سطر دلوقتي
      throw "Server says: ${uploadResponse.body}";
    }

    final uploadData = jsonDecode(uploadResponse.body);
    final sampleId = uploadData['id'];
    // --- الانتظار لمدة 3 ثواني (عشان السيرفر يلحق يسيف الملف) ---
    DnaLoadingOverlay.show(context, message: "Finalizing storage...");
    await Future.delayed(const Duration(seconds: 3));

    // --- الخطوة 2: التحليل ---
    final analyzeResponse = await http.post(
      Uri.parse('$baseUrl/analyze/'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "ngrok-skip-browser-warning": "69420",
      },
      body: jsonEncode({"dna_sample_id": sampleId}),
    );

    if (analyzeResponse.statusCode == 200 || analyzeResponse.statusCode == 201) {
      if (mounted) {
        DnaLoadingOverlay.hide(context);
        _showSuccess("Analysis Started!");
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.loadReports();
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } else {
      throw "Analyze Step Failed: ${analyzeResponse.body}";
    }
  } catch (e) {
    if (mounted) {
      DnaLoadingOverlay.hide(context);
      print("CRITICAL LOG: $e");
      _showError("Details: $e");
    }
  } finally {
    if (mounted) setState(() => _isAnalyzing = false);
  }
}
  // ── Genomic Stats (Migrated from Home) ──
  Widget _buildGenomicStats() {
    final stats = [
      {
        'value': '78',
        'unit': 'SNPs',
        'label': 'Genetic\nMarkers',
        'icon': Icons.scatter_plot_outlined,
        'color': AppColors.primary,
      },
      {
        'value': '3',
        'unit': 'Traits',
        'label': 'Eye · Hair\n· Skin',
        'icon': Icons.biotech_outlined,
        'color': AppColors.secondary,
      },
      {
        'value': '95%',
        'unit': '+',
        'label': 'Model\nAccuracy',
        'icon': Icons.verified_outlined,
        'color': AppColors.success,
      },
    ];

    return Row(
      children: stats.asMap().entries.map((entry) {
        final i = entry.key;
        final s = entry.value;
        final color = s['color'] as Color;
        return Expanded(
          child: AnimatedEntrance(
            delay: Duration(milliseconds: 80 + i * 60),
            child: Container(
              margin: EdgeInsets.only(
                left: i == 0 ? 0 : 6,
                right: i == stats.length - 1 ? 0 : 6,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: color.withAlpha(50)),
                boxShadow: [
                  BoxShadow(
                    color: color.withAlpha(20),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withAlpha(170)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withAlpha(90),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(s['icon'] as IconData,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: s['value'] as String,
                          style: AppTypography.displayLarge.copyWith(
                            color: color,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                        if ((s['unit'] as String).isNotEmpty &&
                            s['unit'] != 'SNPs' &&
                            s['unit'] != 'Traits')
                          TextSpan(
                            text: s['unit'] as String,
                            style: AppTypography.labelSmall.copyWith(
                              color: color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (s['unit'] == 'SNPs' || s['unit'] == 'Traits')
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withAlpha(30),
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Text(
                        s['unit'] as String,
                        style: AppTypography.badge.copyWith(color: color),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    s['label'] as String,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 10,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }


  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(message, style: const TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(message, style: const TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
        duration: const Duration(seconds: 3),
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
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ──
                AnimatedEntrance(
                  child: _buildHeader(),
                ),

                const SizedBox(height: 32),

                // ── Page title ──
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 60),
                  child: Column(
                    children: [
                      Text(
                        "Upload DNA Data",
                        textAlign: TextAlign.center,
                        style: AppTypography.displayLarge,
                      ),
                      AppSpacing.vSm,
                      Text(
                        "Import your CSV file to start predicting physical traits.",
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Upload zone ──
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 120),
                  child: _buildUploadZone(),
                ),

                AppSpacing.vXl,

                // ── Instructions card ──
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 180),
                  child: _buildInstructionsCard(),
                ),

                AppSpacing.vXl,

                // ── Analyze button ──
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 240),
                  child: _buildAnalyzeButton(),
                ),

                AppSpacing.vBase,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: ClipOval(
                child: Image.asset('assets/images/genoscene_logo.png',
                    fit: BoxFit.cover),
              ),
            ),
            AppSpacing.hMd,
            Text("Genome Analysis",
                style: AppTypography.titleLarge.copyWith(fontSize: 22)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: const Icon(Icons.help_outline_rounded,
                  color: AppColors.primary, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          "Analysis Parameters",
          style: AppTypography.sectionHeader.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        _buildGenomicStats(),
      ],
    );
  }

  Widget _buildUploadZone() {
    final bool hasFile = _fileName != null;
    return Semantics(
      button: true,
      label: hasFile ? 'Selected file: $_fileName' : 'Tap to select CSV file',
      child: GestureDetector(
        onTap: _pickFile,
        child: AnimatedContainer(
          duration: AppMotion.standard,
          curve: AppMotion.curve,
          constraints: const BoxConstraints(minHeight: 180),
          decoration: BoxDecoration(
            color: hasFile ? AppColors.primaryMuted : AppColors.surfaceCard,
            borderRadius: AppRadius.card,
            border: Border.all(
              color: hasFile
                  ? AppColors.primary.withAlpha(120)
                  : AppColors.surfaceBorder,
              width: hasFile ? 1.5 : 1,
            ),
            boxShadow: hasFile
                ? [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(40),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: hasFile
                  ? [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(30),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const Icon(Icons.description_outlined,
                            size: 40, color: AppColors.primary),
                      ),
                      AppSpacing.vBase,
                      Text(_fileName!,
                          style: AppTypography.titleSmall,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      AppSpacing.vSm,
                      Text('Tap to change file',
                          style: AppTypography.labelSmall
                              .copyWith(color: AppColors.primary)),
                      AppSpacing.vSm,
                      TextButton.icon(
                        onPressed: () => setState(() {
                          _fileName = null;
                          _pickedFile = null;
                        }),
                        icon: const Icon(Icons.close_rounded,
                            size: 16, color: AppColors.error),
                        label: Text('Remove',
                            style: AppTypography.labelSmall
                                .copyWith(color: AppColors.error)),
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6)),
                      ),
                    ]
                  : [
                      // Dashed border hint
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.primaryMuted,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                              color: AppColors.primary.withAlpha(80),
                              style: BorderStyle.solid),
                        ),
                        child: const Icon(Icons.cloud_upload_outlined,
                            size: 36, color: AppColors.primary),
                      ),
                      AppSpacing.vBase,
                      Text('Tap to select file',
                          style: AppTypography.titleSmall),
                      AppSpacing.vXs,
                      Text('CSV format supported',
                          style: AppTypography.bodySmall),
                    ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    const instructions = [
      ('0', 'No allele present', 'Enter 0 — the input allele is not detected.'),
      ('1', 'Heterozygous', 'One allele present — enter 1 in the box.'),
      ('2', 'Homozygous', 'Only the input allele present — enter 2.'),
      ('NA', 'Missing SNP', 'If SNP data is missing, enter NA.'),
    ];

    const warnings = [
      'Missing HERC2 rs12913832 → no eye colour prediction.',
      'Missing all MC1R (11 SNPs) → no hair colour prediction.',
      'Missing HERC2-SLC45A2-IRF4 → no eye or hair colour prediction.',
    ];

    return Container(
      decoration: AppColors.glassCard(
        borderColor: AppColors.surfaceBorder,
        radius: AppRadius.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
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
                const Icon(Icons.info_outline,
                    color: AppColors.primary, size: 18),
                AppSpacing.hSm,
                Text('Allele Encoding Guide',
                    style: AppTypography.titleSmall
                        .copyWith(color: AppColors.primary)),
              ],
            ),
          ),

          // Instructions
          Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Column(
              children: [
                ...instructions
                    .map((item) => _instructionRow(item.$1, item.$2, item.$3)),
                AppSpacing.vMd,
                const Divider(color: AppColors.surfaceBorder, height: 1),
                AppSpacing.vMd,
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.warning, size: 16),
                    AppSpacing.hXs,
                    Text('Important Warnings',
                        style: AppTypography.labelSmall.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                AppSpacing.vSm,
                ...warnings.map((w) => _warningRow(w)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _instructionRow(String badge, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Text(
              badge,
              style: AppTypography.labelLarge
                  .copyWith(fontWeight: FontWeight.w800, fontSize: 11),
            ),
          ),
          AppSpacing.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleSmall),
                Text(desc,
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.textTertiary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _warningRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(
                  color: AppColors.warning,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          Expanded(
            child: Text(text,
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textTertiary, height: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    final bool canAnalyze = _fileName != null && !_isAnalyzing;
    return Semantics(
      button: true,
      label: 'Start analysis',
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: canAnalyze
                ? const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: canAnalyze ? null : AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border:
                canAnalyze ? null : Border.all(color: AppColors.surfaceBorder),
            boxShadow: canAnalyze
                ? [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(90),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: ElevatedButton(
            onPressed: canAnalyze ? _uploadAndAnalyze : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.xl)),
            ),
            child: _isAnalyzing
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.textPrimary),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.science_outlined,
                        size: 20,
                        color: canAnalyze
                            ? AppColors.textPrimary
                            : AppColors.textDisabled,
                      ),
                      AppSpacing.hSm,
                      Text(
                        "Start Analysis",
                        style: AppTypography.titleSmall.copyWith(
                          color: canAnalyze
                              ? AppColors.textPrimary
                              : AppColors.textDisabled,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
