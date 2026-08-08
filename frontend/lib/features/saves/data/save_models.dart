enum SiteStatus {
  draft,
  pendingLocation,
  complete;

  static SiteStatus fromDb(String? value) {
    switch (value) {
      case 'pending_location':
        return SiteStatus.pendingLocation;
      case 'complete':
        return SiteStatus.complete;
      default:
        return SiteStatus.draft;
    }
  }

  String get dbValue {
    switch (this) {
      case SiteStatus.pendingLocation:
        return 'pending_location';
      case SiteStatus.complete:
        return 'complete';
      case SiteStatus.draft:
        return 'draft';
    }
  }

  String get labelEs {
    switch (this) {
      case SiteStatus.pendingLocation:
        return 'Pendiente de ubicación';
      case SiteStatus.complete:
        return 'Completo';
      case SiteStatus.draft:
        return 'Borrador';
    }
  }
}

class UserSave {
  const UserSave({
    required this.id,
    required this.userId,
    required this.siteId,
    required this.status,
    required this.isPublic,
    required this.siteName,
    this.sourceUrl,
    this.sourceNetwork,
    this.notes,
    this.city,
    this.department,
    this.addressLine,
    this.categoryNames = const [],
    this.createdAt,
  });

  final String id;
  final String userId;
  final String siteId;
  final SiteStatus status;
  final bool isPublic;
  final String siteName;
  final String? sourceUrl;
  final String? sourceNetwork;
  final String? notes;
  final String? city;
  final String? department;
  final String? addressLine;
  final List<String> categoryNames;
  final DateTime? createdAt;

  factory UserSave.fromJoinedJson(Map<String, dynamic> json) {
    final site = Map<String, dynamic>.from(json['sites'] as Map? ?? {});
    final catsRaw = site['site_categories'] as List? ?? const [];
    final names = <String>[];
    for (final row in catsRaw) {
      if (row is! Map) continue;
      final cat = row['categories'];
      if (cat is Map) {
        final i18n = cat['name_i18n'];
        if (i18n is Map && i18n['es'] is String) {
          names.add(i18n['es'] as String);
        }
      }
    }
    return UserSave(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      siteId: json['site_id'] as String,
      status: SiteStatus.fromDb(json['status'] as String?),
      isPublic: json['is_public'] as bool? ?? false,
      siteName: (site['name'] as String?) ?? 'Sin nombre',
      sourceUrl: json['source_url'] as String?,
      sourceNetwork: json['source_network'] as String?,
      notes: json['notes'] as String?,
      city: site['city'] as String?,
      department: site['department'] as String?,
      addressLine: site['address_line'] as String?,
      categoryNames: names,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}

class SaveDraftInput {
  const SaveDraftInput({
    required this.name,
    this.sourceUrl,
    this.sourceNetwork,
    this.city,
    this.department,
    this.addressLine,
    this.latitude,
    this.longitude,
    this.categoryIds = const [],
    this.isPublic = false,
    this.isPhysicalPlace = true,
    this.notes,
  });

  final String name;
  final String? sourceUrl;
  final String? sourceNetwork;
  final String? city;
  final String? department;
  final String? addressLine;
  final double? latitude;
  final double? longitude;
  final List<String> categoryIds;
  final bool isPublic;
  final bool isPhysicalPlace;
  final String? notes;
}
