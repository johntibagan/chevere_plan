import '../../../core/l10n/display_defaults.dart';

class SitePhoto {
  const SitePhoto({
    required this.id,
    required this.siteId,
    required this.storagePath,
    this.uploadedBy,
    this.uploaderName,
    this.createdAt,
  });

  final String id;
  final String siteId;
  final String storagePath;
  final String? uploadedBy;
  final String? uploaderName;
  final DateTime? createdAt;

  factory SitePhoto.fromJson(Map<String, dynamic> json) {
    String? uploaderName;
    final profiles = json['profiles'];
    if (profiles is Map) {
      uploaderName = profiles['display_name'] as String?;
    }
    final createdRaw = json['created_at'] as String?;
    final name = uploaderName?.trim();
    return SitePhoto(
      id: json['id'] as String,
      siteId: json['site_id'] as String,
      storagePath: json['storage_path'] as String,
      uploadedBy: json['uploaded_by'] as String?,
      uploaderName: (name != null && name.isNotEmpty) ? name : null,
      createdAt: createdRaw == null ? null : DateTime.tryParse(createdRaw),
    );
  }
}

class ContentReport {
  const ContentReport({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.status,
    required this.createdAt,
    required this.reporterId,
    required this.reporterName,
    this.reason,
    this.photoPath,
    this.siteName,
    this.snippet,
  });

  final String id;
  final String targetType;
  final String targetId;
  final String? reason;
  final String status;
  final DateTime createdAt;
  final String reporterId;
  final String reporterName;
  final String? photoPath;
  final String? siteName;
  /// Vista previa del cuerpo (p. ej. reseña reportada).
  final String? snippet;

  factory ContentReport.fromJson(Map<String, dynamic> json) {
    final rawSnippet = (json['snippet'] as String?)?.trim();
    return ContentReport(
      id: json['report_id'] as String,
      targetType: json['target_type'] as String,
      targetId: json['target_id'] as String,
      reason: json['reason'] as String?,
      status: json['status'] as String? ?? 'open',
      createdAt: DateTime.parse(json['created_at'] as String),
      reporterId: json['reporter_id'] as String,
      reporterName: (json['reporter_name'] as String?) ??
          DisplayDefaults.userDisplayName,
      photoPath: json['photo_path'] as String?,
      siteName: json['site_name'] as String?,
      snippet: (rawSnippet != null && rawSnippet.isNotEmpty) ? rawSnippet : null,
    );
  }
}
