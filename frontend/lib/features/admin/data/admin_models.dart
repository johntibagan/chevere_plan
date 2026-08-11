class Category {
  const Category({
    required this.id,
    required this.slug,
    required this.nameEs,
    required this.isActive,
    required this.ageRestricted,
    required this.sortOrder,
    this.parentId,
    this.iconKey,
    this.colorHex,
    this.keywords = const [],
  });

  final String id;
  final String? parentId;
  final String slug;
  final String nameEs;
  final bool isActive;
  final bool ageRestricted;
  final int sortOrder;
  final String? iconKey;
  final String? colorHex;
  final List<String> keywords;

  bool get isRoot => parentId == null;

  /// Coincide nombre, slug o keywords (sinónimos: nadar, agua, caminar…).
  bool matchesQuery(String rawQuery) {
    final q = rawQuery.trim().toLowerCase();
    if (q.isEmpty) return false;
    if (nameEs.toLowerCase().contains(q)) return true;
    if (slug.toLowerCase().contains(q)) return true;
    for (final k in keywords) {
      final kw = k.toLowerCase().trim();
      if (kw.isEmpty) continue;
      if (kw.contains(q) || q.contains(kw)) return true;
    }
    return false;
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    final nameI18n = json['name_i18n'];
    String nameEs = json['slug'] as String? ?? '';
    if (nameI18n is Map) {
      nameEs = (nameI18n['es'] as String?) ?? nameEs;
    }
    final rawKeywords = json['keywords'];
    final keywords = <String>[];
    if (rawKeywords is List) {
      for (final e in rawKeywords) {
        if (e is String && e.trim().isNotEmpty) keywords.add(e.trim());
      }
    }
    return Category(
      id: json['id'] as String,
      parentId: json['parent_id'] as String?,
      slug: json['slug'] as String,
      nameEs: nameEs,
      isActive: json['is_active'] as bool? ?? true,
      ageRestricted: json['age_restricted'] as bool? ?? false,
      sortOrder: json['sort_order'] as int? ?? 0,
      iconKey: json['icon_key'] as String?,
      colorHex: json['color_hex'] as String?,
      keywords: keywords,
    );
  }
}

class TransportType {
  const TransportType({
    required this.id,
    required this.transportGroup,
    required this.slug,
    required this.nameEs,
    required this.isActive,
    required this.sortOrder,
    this.defaultMaxKm,
    this.iconKey,
  });

  final String id;
  final String transportGroup;
  final String slug;
  final String nameEs;
  final bool isActive;
  final int sortOrder;
  final double? defaultMaxKm;
  final String? iconKey;

  factory TransportType.fromJson(Map<String, dynamic> json) {
    final nameI18n = json['name_i18n'];
    String nameEs = json['slug'] as String? ?? '';
    if (nameI18n is Map) {
      nameEs = (nameI18n['es'] as String?) ?? nameEs;
    }
    final maxKm = json['default_max_km'];
    return TransportType(
      id: json['id'] as String,
      transportGroup: json['transport_group'] as String,
      slug: json['slug'] as String,
      nameEs: nameEs,
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 0,
      defaultMaxKm: maxKm == null ? null : (maxKm as num).toDouble(),
      iconKey: json['icon_key'] as String?,
    );
  }
}
