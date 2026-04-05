import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PdfExportService {
  // Brand colors
  static const _cyan = PdfColor.fromInt(0xFF4DD0E1);
  static const _navy = PdfColor.fromInt(0xFF0A1628);
  static const _darkBlue = PdfColor.fromInt(0xFF1A3A5C);
  static const _grey = PdfColor.fromInt(0xFF888888);
  static const _lightGrey = PdfColor.fromInt(0xFFCCCCCC);
  static const _bgGrey = PdfColor.fromInt(0xFFF5F5F5);
  static const _white = PdfColor.fromInt(0xFFFFFFFF);
  static const _green = PdfColor.fromInt(0xFF4CAF82);
  static const _blue = PdfColor.fromInt(0xFF42A5F5);
  static const _orange = PdfColor.fromInt(0xFFFFB74D);
  static const _red = PdfColor.fromInt(0xFFEF5350);

  /// Export and share the analysis report as PDF.
  /// Returns true on success, false on failure.
  static Future<bool> exportReport({
    required BuildContext context,
    required Map<String, double> hairResults,
    required Map<String, double> eyeResults,
    required Map<String, double> skinResults,
    String? analysisId,
  }) async {
    try {
      // Load Google Font with full Unicode support
      final regularFont = await PdfGoogleFonts.poppinsRegular();
      final boldFont = await PdfGoogleFonts.poppinsBold();

      final baseStyle = pw.TextStyle(font: regularFont, fontFallback: [regularFont]);
      final boldStyle = pw.TextStyle(font: boldFont, fontFallback: [boldFont]);

      final pdf = pw.Document(
        title: 'GenoScene DNA Analysis Report',
        author: 'GenoScene App',
        creator: 'GenoScene DNA Phenotyping Platform',
        theme: pw.ThemeData(
          defaultTextStyle: baseStyle,
          paragraphStyle: baseStyle,
          header0: boldStyle.copyWith(fontSize: 24),
          header1: boldStyle.copyWith(fontSize: 20),
          header2: boldStyle.copyWith(fontSize: 16),
          header3: boldStyle.copyWith(fontSize: 14),
          header4: boldStyle.copyWith(fontSize: 12),
          header5: boldStyle.copyWith(fontSize: 10),
          bulletStyle: baseStyle,
          tableHeader: boldStyle,
          tableCell: baseStyle,
        ),
      );

      final topHair = _getTop(hairResults);
      final topEye = _getTop(eyeResults);
      final topSkin = _getTop(skinResults);
      final now = DateTime.now();
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          header: (ctx) => _buildHeader(ctx, dateStr, analysisId, boldFont, regularFont),
          footer: (ctx) => _buildFooter(ctx, regularFont),
          build: (ctx) => [
            pw.SizedBox(height: 16),

            // Title Section
            _buildTitleSection(analysisId, dateStr, boldFont, regularFont),
            pw.SizedBox(height: 24),

            // Summary
            _buildSummarySection(topHair, topEye, topSkin,
                hairResults, eyeResults, skinResults, boldFont, regularFont),
            pw.SizedBox(height: 28),

            // Detail sections
            _buildDetailSection('Hair Colour Analysis', hairResults, _cyan, boldFont, regularFont),
            pw.SizedBox(height: 20),
            _buildDetailSection('Eye Colour Analysis', eyeResults, _blue, boldFont, regularFont),
            pw.SizedBox(height: 20),
            _buildDetailSection('Skin Tone Analysis', skinResults, _orange, boldFont, regularFont),
            pw.SizedBox(height: 32),

            // Methodology
            _buildMethodologyNote(boldFont, regularFont),
            pw.SizedBox(height: 20),

            // Disclaimer
            _buildDisclaimer(boldFont, regularFont),
          ],
        ),
      );

      final bytes = await pdf.save();

      // Save to temp file and share via share_plus
      final dir = await getTemporaryDirectory();
      final fileName = 'GenoScene_Report_${analysisId ?? 'analysis'}_${now.millisecondsSinceEpoch}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'GenoScene DNA Analysis Report',
        ),
      );

      return true;
    } catch (e) {
      debugPrint('PDF export error: $e');
      return false;
    }
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  static pw.Widget _buildHeader(
      pw.Context ctx, String dateStr, String? analysisId,
      pw.Font bold, pw.Font regular) {
    return pw.Column(children: [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Row(children: [
            pw.Container(
              width: 28,
              height: 28,
              decoration: pw.BoxDecoration(
                color: _cyan,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Center(
                child: pw.Text('G',
                    style: pw.TextStyle(
                      font: bold,
                      fontSize: 16,
                      color: _navy,
                    )),
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('GenoScene',
                    style: pw.TextStyle(
                      font: bold,
                      fontSize: 12,
                      color: _darkBlue,
                    )),
                pw.Text('DNA Phenotyping Platform',
                    style: pw.TextStyle(font: regular, fontSize: 7, color: _grey)),
              ],
            ),
          ]),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(dateStr,
                  style: pw.TextStyle(font: regular, fontSize: 8, color: _grey)),
              if (analysisId != null)
                pw.Text('ID: $analysisId',
                    style: pw.TextStyle(font: regular, fontSize: 7, color: _lightGrey)),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 8),
      pw.Container(height: 2, color: _cyan),
      pw.SizedBox(height: 4),
      pw.Container(height: 0.5, color: _lightGrey),
    ]);
  }

  // ─── Footer ───────────────────────────────────────────────────────────────

  static pw.Widget _buildFooter(pw.Context ctx, pw.Font regular) {
    return pw.Column(children: [
      pw.Container(height: 0.5, color: _lightGrey),
      pw.SizedBox(height: 6),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Generated by GenoScene App - For Research Purposes Only',
              style: pw.TextStyle(font: regular, fontSize: 7, color: _lightGrey)),
          pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
              style: pw.TextStyle(font: regular, fontSize: 7, color: _lightGrey)),
        ],
      ),
    ]);
  }

  // ─── Title ────────────────────────────────────────────────────────────────

  static pw.Widget _buildTitleSection(
      String? analysisId, String dateStr, pw.Font bold, pw.Font regular) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: _navy,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'DNA PHENOTYPE ANALYSIS REPORT',
            style: pw.TextStyle(
              font: bold,
              fontSize: 20,
              color: _cyan,
              letterSpacing: 1.5,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Forensic Genetics & AI-Powered SNP Analysis',
            style: pw.TextStyle(font: regular, fontSize: 10, color: _lightGrey),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              _infoPill('Date', dateStr, bold, regular),
              pw.SizedBox(width: 16),
              if (analysisId != null)
                _infoPill('Analysis ID', analysisId, bold, regular),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _infoPill(
      String label, String value, pw.Font bold, pw.Font regular) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: pw.BoxDecoration(
        color: _darkBlue,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Row(children: [
        pw.Text('$label: ',
            style: pw.TextStyle(font: regular, fontSize: 8, color: _grey)),
        pw.Text(value,
            style: pw.TextStyle(font: bold, fontSize: 8, color: _cyan)),
      ]),
    );
  }

  // ─── Summary Section ──────────────────────────────────────────────────────

  static pw.Widget _buildSummarySection(
    MapEntry<String, double> hair,
    MapEntry<String, double> eye,
    MapEntry<String, double> skin,
    Map<String, double> hairData,
    Map<String, double> eyeData,
    Map<String, double> skinData,
    pw.Font bold,
    pw.Font regular,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('TRAIT SUMMARY', bold),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: _lightGrey, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(2.5),
            1: const pw.FlexColumnWidth(3),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: _navy),
              children: ['Trait', 'Prediction', 'Probability', 'Confidence']
                  .map((h) => pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: pw.Text(h,
                            style: pw.TextStyle(
                              font: bold,
                              fontSize: 10,
                              color: _cyan,
                            )),
                      ))
                  .toList(),
            ),
            _dataRow('Hair Colour', hair.key, hair.value,
                _confLabel(hairData), _bgGrey, bold, regular),
            _dataRow('Eye Colour', eye.key, eye.value,
                _confLabel(eyeData), _white, bold, regular),
            _dataRow('Skin Tone', skin.key, skin.value,
                _confLabel(skinData), _bgGrey, bold, regular),
          ],
        ),
      ],
    );
  }

  static pw.TableRow _dataRow(String trait, String prediction, double prob,
      String confidence, PdfColor bgColor, pw.Font bold, pw.Font regular) {
    final confColor = _confColor(confidence);
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: bgColor),
      children: [
        _cell(trait, bold: true, boldFont: bold, regularFont: regular),
        _cell(prediction, boldFont: bold, regularFont: regular),
        _cell('${prob.toStringAsFixed(1)}%', boldFont: bold, regularFont: regular),
        pw.Padding(
          padding:
              const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: pw.Container(
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: pw.BoxDecoration(
              color: confColor.shade(0.9),
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: confColor, width: 0.5),
            ),
            child: pw.Text(confidence,
                style: pw.TextStyle(
                    font: bold,
                    fontSize: 8,
                    color: confColor)),
          ),
        ),
      ],
    );
  }

  static pw.Widget _cell(String text,
      {bool bold = false,
      required pw.Font boldFont,
      required pw.Font regularFont}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(text,
          style: pw.TextStyle(
            font: bold ? boldFont : regularFont,
            fontSize: 10,
          )),
    );
  }

  // ─── Detail Section ───────────────────────────────────────────────────────

  static pw.Widget _buildDetailSection(String title,
      Map<String, double> data, PdfColor accentColor,
      pw.Font bold, pw.Font regular) {
    final sorted = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxVal = sorted.isNotEmpty ? sorted.first.value : 100.0;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle(title.toUpperCase(), bold),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.all(14),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: _lightGrey, width: 0.5),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Row(children: [
                  pw.SizedBox(
                    width: 90,
                    child: pw.Text('Variant',
                        style: pw.TextStyle(
                            font: bold, fontSize: 8, color: _grey)),
                  ),
                  pw.Expanded(
                    child: pw.Text('Distribution',
                        style: pw.TextStyle(
                            font: bold, fontSize: 8, color: _grey)),
                  ),
                  pw.SizedBox(
                    width: 50,
                    child: pw.Text('Value',
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(
                            font: bold, fontSize: 8, color: _grey)),
                  ),
                ]),
              ),
              pw.Container(height: 0.5, color: _lightGrey),
              pw.SizedBox(height: 4),
              ...sorted.asMap().entries.map((entry) {
                final i = entry.key;
                final e = entry.value;
                final isTop = i == 0;
                final barColor = isTop ? accentColor : _lightGrey;
                final textColor = isTop ? accentColor : _grey;

                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 3),
                  child: pw.Row(
                    children: [
                      pw.SizedBox(
                        width: 90,
                        child: pw.Text(
                          e.key,
                          style: pw.TextStyle(
                            font: isTop ? bold : regular,
                            fontSize: 9,
                          ),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.LayoutBuilder(
                          builder: (context, constraints) {
                            final availW = constraints?.maxWidth ?? 200;
                            final barW =
                                (e.value / maxVal).clamp(0.0, 1.0) * availW;
                            return pw.Stack(children: [
                              pw.Container(
                                height: 14,
                                decoration: pw.BoxDecoration(
                                  color: _bgGrey,
                                  borderRadius: pw.BorderRadius.circular(3),
                                ),
                              ),
                              pw.Container(
                                height: 14,
                                width: barW,
                                decoration: pw.BoxDecoration(
                                  color: barColor,
                                  borderRadius: pw.BorderRadius.circular(3),
                                ),
                              ),
                            ]);
                          },
                        ),
                      ),
                      pw.SizedBox(width: 8),
                      pw.SizedBox(
                        width: 50,
                        child: pw.Text(
                          '${e.value.toStringAsFixed(1)}%',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            font: bold,
                            fontSize: 9,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Methodology ──────────────────────────────────────────────────────────

  static pw.Widget _buildMethodologyNote(pw.Font bold, pw.Font regular) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFE8F5FE),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: _cyan.shade(0.8), width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Methodology',
              style: pw.TextStyle(font: bold, fontSize: 11, color: _darkBlue)),
          pw.SizedBox(height: 4),
          pw.Text(
            'Predictions are computed using an ensemble of machine learning models '
            '(LightGBM, XGBoost, Logistic Regression) trained on curated SNP datasets. '
            'Confidence is derived from Shannon entropy across the probability distribution - '
            'lower entropy indicates higher prediction certainty.',
            style: pw.TextStyle(font: regular, fontSize: 8, color: _grey),
          ),
        ],
      ),
    );
  }

  // ─── Disclaimer ───────────────────────────────────────────────────────────

  static pw.Widget _buildDisclaimer(pw.Font bold, pw.Font regular) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFFFF8E1),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(
            color: const PdfColor.fromInt(0xFFFFE082), width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Disclaimer',
              style: pw.TextStyle(
                  font: bold,
                  fontSize: 11,
                  color: const PdfColor.fromInt(0xFFE65100))),
          pw.SizedBox(height: 4),
          pw.Text(
            'This report is generated for educational and research purposes only. '
            'Predictions are based on statistical models analyzing SNP data and may not '
            'accurately reflect actual physical traits. Results represent probabilities, '
            'not definitive outcomes. This document is not intended for medical, legal, '
            'or forensic identification purposes.',
            style: pw.TextStyle(font: regular, fontSize: 8, color: _grey),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  static pw.Widget _sectionTitle(String title, pw.Font bold) {
    return pw.Row(children: [
      pw.Container(width: 3, height: 14, color: _cyan),
      pw.SizedBox(width: 8),
      pw.Text(title,
          style: pw.TextStyle(
            font: bold,
            fontSize: 12,
            color: _darkBlue,
            letterSpacing: 0.5,
          )),
    ]);
  }

  static MapEntry<String, double> _getTop(Map<String, double> data) {
    if (data.isEmpty) return const MapEntry('Unknown', 0.0);
    return data.entries.reduce((a, b) => a.value > b.value ? a : b);
  }

  static String _confLabel(Map<String, double> data) {
    if (data.isEmpty) return 'N/A';
    final total = data.values.fold<double>(0, (a, b) => a + b);
    if (total == 0) return 'N/A';
    double entropy = 0;
    for (final v in data.values) {
      final p = v / total;
      if (p > 0) entropy -= p * (log(p) / log(data.length));
    }
    entropy = entropy.clamp(0.0, 1.0);
    if (entropy < 0.3) return 'Very High';
    if (entropy < 0.5) return 'High';
    if (entropy < 0.7) return 'Moderate';
    return 'Low';
  }

  static PdfColor _confColor(String label) {
    switch (label) {
      case 'Very High':
        return _green;
      case 'High':
        return _blue;
      case 'Moderate':
        return _orange;
      case 'Low':
        return _red;
      default:
        return _grey;
    }
  }
}
