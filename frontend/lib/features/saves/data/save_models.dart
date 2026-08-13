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
}

class PossibleDuplicate {
  const PossibleDuplicate({
    required this.siteId,
    required this.siteName,
    this.city,
    this.distanceM,
    this.nameScore,
    this.contributorCount = 0,
  });

  final String siteId;
  final String siteName;
  final String? city;
  final double? distanceM;
  final double? nameScore;
  final int contributorCount;

  factory PossibleDuplicate.fromJson(Map<String, dynamic> json) {
    return PossibleDuplicate(
      siteId: json['site_id'] as String,
      siteName: json['site_name'] as String? ?? 'Sitio',
      city: json['city'] as String?,
      distanceM: json['distance_m'] == null
          ? null
          : (json['distance_m'] as num).toDouble(),
      nameScore: json['name_score'] == null
          ? null
          : (json['name_score'] as num).toDouble(),
      contributorCount: (json['contributor_count'] as num?)?.toInt() ?? 0,
    );
  }
}


/// Persona ligada a un sitio (creador o contribuidor).
class SitePerson {
  const SitePerson({
    required this.userId,
    this.displayName,
    this.avatarUrl,
  });

  final String userId;
  final String? displayName;
  final String? avatarUrl;

  String get tooltipName {
    final n = displayName?.trim();
    if (n != null && n.isNotEmpty) return n;
    return 'Usuario';
  }

  Map<String, dynamic> toCacheJson() => {
        'user_id': userId,
        'display_name': displayName,
        'avatar_url': avatarUrl,
      };

  factory SitePerson.fromCacheJson(Map<String, dynamic> json) {
    return SitePerson(
      userId: json['user_id'] as String? ?? '',
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  static List<SitePerson> parseContributorRows(List? raw) {
    final out = <SitePerson>[];
    final seen = <String>{};
    for (final row in raw ?? const []) {
      if (row is! Map) continue;
      final uid = row['user_id'] as String?;
      if (uid == null || uid.isEmpty || !seen.add(uid)) continue;
      final profile = row['profiles'];
      String? name;
      String? avatar;
      if (profile is Map) {
        name = profile['display_name'] as String?;
        avatar = profile['avatar_url'] as String?;
      }
      out.add(SitePerson(userId: uid, displayName: name, avatarUrl: avatar));
    }
    return out;
  }

  static List<SitePerson> withCreator({
    String? createdById,
    Map? creatorProfile,
    required List<SitePerson> contributors,
  }) {
    final out = <SitePerson>[];
    final seen = <String>{};
    if (createdById != null && createdById.isNotEmpty) {
      String? name;
      String? avatar;
      if (creatorProfile is Map) {
        name = creatorProfile['display_name'] as String?;
        avatar = creatorProfile['avatar_url'] as String?;
      }
      out.add(SitePerson(userId: createdById, displayName: name, avatarUrl: avatar));
      seen.add(createdById);
    }
    for (final p in contributors) {
      if (seen.add(p.userId)) out.add(p);
    }
    return out;
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
    this.cityId,
    this.department,
    this.departmentId,
    this.addressLine,
    this.categoryNames = const [],
    this.createdAt,
    this.isPossibleDuplicate = false,
    this.possibleDuplicateOfSiteId,
    this.alsoSharedBy = const [],
    this.sharedPeople = const [],
    this.createdByUserId,
    this.isPhysicalPlace = true,
    this.googlePlaceId,
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
  final String? cityId;
  final String? department;
  final String? departmentId;
  final String? addressLine;
  final List<String> categoryNames;
  final DateTime? createdAt;
  final bool isPossibleDuplicate;
  final String? possibleDuplicateOfSiteId;
  /// Legacy: solo nombres (caché vieja). Preferir [sharedPeople].
  final List<String> alsoSharedBy;
  final List<SitePerson> sharedPeople;
  final String? createdByUserId;
  final bool isPhysicalPlace;
  final String? googlePlaceId;

  bool get isIncomplete => status != SiteStatus.complete;

  Map<String, dynamic> toCacheJson() => {
        'id': id,
        'user_id': userId,
        'site_id': siteId,
        'status': status.dbValue,
        'is_public': isPublic,
        'site_name': siteName,
        'source_url': sourceUrl,
        'source_network': sourceNetwork,
        'notes': notes,
        'city': city,
        'city_id': cityId,
        'department': department,
        'department_id': departmentId,
        'address_line': addressLine,
        'category_names': categoryNames,
        'created_at': createdAt?.toUtc().toIso8601String(),
        'is_possible_duplicate': isPossibleDuplicate,
        'possible_duplicate_of_site_id': possibleDuplicateOfSiteId,
        'also_shared_by': alsoSharedBy,
        'shared_people': sharedPeople.map((e) => e.toCacheJson()).toList(),
        'created_by_user_id': createdByUserId,
        'is_physical_place': isPhysicalPlace,
        'google_place_id': googlePlaceId,
      };

  factory UserSave.fromCacheJson(Map<String, dynamic> json) {
    final peopleRaw = json['shared_people'] as List?;
    final people = peopleRaw == null
        ? const <SitePerson>[]
        : peopleRaw
            .whereType<Map>()
            .map((e) => SitePerson.fromCacheJson(Map<String, dynamic>.from(e)))
            .where((p) => p.userId.isNotEmpty)
            .toList();
    final legacyNames = (json['also_shared_by'] as List?)
            ?.map((e) => '$e')
            .toList() ??
        const <String>[];
    return UserSave(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      siteId: json['site_id'] as String,
      status: SiteStatus.fromDb(json['status'] as String?),
      isPublic: json['is_public'] as bool? ?? false,
      siteName: json['site_name'] as String? ?? 'Sin nombre',
      sourceUrl: json['source_url'] as String?,
      sourceNetwork: json['source_network'] as String?,
      notes: json['notes'] as String?,
      city: json['city'] as String?,
      cityId: json['city_id'] as String?,
      department: json['department'] as String?,
      departmentId: json['department_id'] as String?,
      addressLine: json['address_line'] as String?,
      categoryNames: (json['category_names'] as List?)
              ?.map((e) => '$e')
              .toList() ??
          const [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      isPossibleDuplicate: json['is_possible_duplicate'] as bool? ?? false,
      possibleDuplicateOfSiteId:
          json['possible_duplicate_of_site_id'] as String?,
      alsoSharedBy: legacyNames,
      sharedPeople: people.isNotEmpty
          ? people
          : legacyNames
              .map((n) => SitePerson(userId: n, displayName: n))
              .toList(),
      createdByUserId: json['created_by_user_id'] as String?,
      isPhysicalPlace: json['is_physical_place'] as bool? ?? true,
      googlePlaceId: json['google_place_id'] as String?,
    );
  }

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
    final createdBy = site['created_by'] as String?;
    final creatorProf = site['profiles'];
    final people = SitePerson.withCreator(
      createdById: createdBy,
      creatorProfile: creatorProf is Map ? creatorProf : null,
      contributors: SitePerson.parseContributorRows(
        site['site_contributors'] as List?,
      ),
    );
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
      cityId: site['city_id'] as String?,
      department: site['department'] as String?,
      departmentId: site['department_id'] as String?,
      addressLine: site['address_line'] as String?,
      categoryNames: names,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      isPossibleDuplicate: json['is_possible_duplicate'] as bool? ?? false,
      possibleDuplicateOfSiteId:
          json['possible_duplicate_of_site_id'] as String?,
      alsoSharedBy: people.map((p) => p.tooltipName).toList(),
      sharedPeople: people,
      createdByUserId: createdBy,
      isPhysicalPlace: site['is_physical_place'] as bool? ?? true,
      googlePlaceId: site['google_place_id'] as String?,
    );
  }
}

/// Datos para editar un guardado existente.
class SaveEditData {
  const SaveEditData({
    required this.save,
    required this.categoryIds,
    this.latitude,
    this.longitude,
  });

  final UserSave save;
  final List<String> categoryIds;
  final double? latitude;
  final double? longitude;
}

/// Edición de sitio público (catálogo) por admin/root, sin `user_saves`.
class SiteEditData {
  const SiteEditData({
    required this.siteId,
    required this.name,
    required this.categoryIds,
    this.city,
    this.cityId,
    this.department,
    this.departmentId,
    this.addressLine,
    this.isPublic = true,
    this.isPhysicalPlace = true,
    this.latitude,
    this.longitude,
    this.googlePlaceId,
  });

  final String siteId;
  final String name;
  final String? city;
  final String? cityId;
  final String? department;
  final String? departmentId;
  final String? addressLine;
  final bool isPublic;
  final bool isPhysicalPlace;
  final List<String> categoryIds;
  final double? latitude;
  final double? longitude;
  final String? googlePlaceId;
}

class SaveDraftInput {
  const SaveDraftInput({
    required this.name,
    this.sourceUrl,
    this.sourceNetwork,
    this.city,
    this.cityId,
    this.department,
    this.departmentId,
    this.addressLine,
    this.latitude,
    this.longitude,
    this.categoryIds = const [],
    this.isPublic = false,
    this.isPhysicalPlace = true,
    this.notes,
    this.linkToExistingSiteId,
    this.categoryIsExplicit = true,
  });

  final String name;
  final String? sourceUrl;
  final String? sourceNetwork;
  final String? city;
  final String? cityId;
  final String? department;
  final String? departmentId;
  final String? addressLine;
  final double? latitude;
  final double? longitude;
  final List<String> categoryIds;
  final bool isPublic;
  final bool isPhysicalPlace;
  final String? notes;
  /// Si el usuario confirma duplicado = mismo sitio público existente.
  final String? linkToExistingSiteId;
  /// False si la categoría es solo el default (Otros) autoasignado.
  final bool categoryIsExplicit;
}
