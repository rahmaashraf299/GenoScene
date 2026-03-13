class ReportItem {
  final String id;
  final String sampleName;
  final DateTime date;
  final String status;
  final Map<String, double>? hairResults;
  final Map<String, double>? eyeResults;
  final Map<String, double>? skinResults;
  final String? faceImageUrl;
  final String? facePrompt;

  ReportItem({
    required this.id,
    required this.sampleName,
    required this.date,
    required this.status,
    this.hairResults,
    this.eyeResults,
    this.skinResults,
    this.faceImageUrl,
    this.facePrompt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sample_name': sampleName,
      'created_at': date.toIso8601String(),
      'status': status,
      'hair_results': hairResults,
      'eye_results': eyeResults,
      'skin_results': skinResults,
      'face_image_url': faceImageUrl,
      'face_prompt': facePrompt,
    };
  }

  factory ReportItem.fromJson(Map<String, dynamic> json) {
    // 1. استخراج الـ ID بأمان سواء كان int أو String
    final dynamic rawId = json['id'] ?? json['analysis_id'] ?? '';
    final String extractedId = rawId.toString();

    // 2. تعديل الأولوية لقراءة الاسم: 
    // أولاً: sample_name (الاسم اللي كتبتيه)
    // ثانياً: filename (اسم الملف الأصلي)
    // ثالثاً: اسم افتراضي بالـ ID
    final String name = json['sample_name'] ?? json['filename'] ?? "Report #$extractedId";

    return ReportItem(
      id: extractedId,
      sampleName: name,
      
      date: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      
      status: json['status'] ?? 'Completed',
      
      // معالجة نتائج الشعر
      hairResults: (json['hair_results'] ?? json['hair']) != null
          ? Map<String, double>.from((json['hair_results'] ?? json['hair'])
              .map((k, v) => MapEntry(k.toString(), (v as num).toDouble())))
          : null,
      
      // معالجة نتائج العين
      eyeResults: (json['eye_results'] ?? json['eye']) != null
          ? Map<String, double>.from((json['eye_results'] ?? json['eye'])
              .map((k, v) => MapEntry(k.toString(), (v as num).toDouble())))
          : null,
      
      // معالجة نتائج البشرة
      skinResults: (json['skin_results'] ?? json['skin']) != null
          ? Map<String, double>.from((json['skin_results'] ?? json['skin'])
              .map((k, v) => MapEntry(k.toString(), (v as num).toDouble())))
          : null,
      
      faceImageUrl: json['face_image_url'],
      facePrompt: json['face_prompt'],
    );
  }

  ReportItem copyWith({
    String? id,
    String? sampleName,
    DateTime? date,
    String? status,
    Map<String, double>? hairResults,
    Map<String, double>? eyeResults,
    Map<String, double>? skinResults,
    String? faceImageUrl,
    String? facePrompt,
  }) {
    return ReportItem(
      id: id ?? this.id,
      sampleName: sampleName ?? this.sampleName,
      date: date ?? this.date,
      status: status ?? this.status,
      hairResults: hairResults ?? this.hairResults,
      eyeResults: eyeResults ?? this.eyeResults,
      skinResults: skinResults ?? this.skinResults,
      faceImageUrl: faceImageUrl ?? this.faceImageUrl,
      facePrompt: facePrompt ?? this.facePrompt,
    );
  }
}