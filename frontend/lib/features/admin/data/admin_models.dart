class Category {
  const Category({
    required this.id,
    required this.slug,
    required this.nameEs,
    required this.isActive,
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
  final int sortOrder;
  final String? iconKey;
  final String? colorHex;
  final List<String> keywords;

  bool get isRoot => parentId == null;

  /// Primera categoría del sitio → nombre de la padre (o ella si ya es raíz).
  static String? parentNameEs(List<Category> catalog, List<String> names) {
    if (names.isEmpty) return null;
    final first = names.first.trim();
    if (first.isEmpty) return null;
    Category? found;
    for (final c in catalog) {
      if (c.nameEs.trim().toLowerCase() == first.toLowerCase()) {
        found = c;
        break;
      }
    }
    if (found == null) return first;
    if (found.parentId == null) return found.nameEs;
    for (final p in catalog) {
      if (p.id == found.parentId) return p.nameEs;
    }
    return found.nameEs;
  }

  Map<String, dynamic> toCacheJson() => {
        'id': id,
        'parent_id': parentId,
        'slug': slug,
        'name_i18n': {'es': nameEs},
        'is_active': isActive,
        'sort_order': sortOrder,
        'icon_key': iconKey,
        'color_hex': colorHex,
        'keywords': keywords,
      };

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
    } else if (nameI18n is String) {
      // Por si llega serializado como texto JSON.
      try {
        final decoded = nameI18n;
        if (decoded.contains('"es"')) {
          final match = RegExp(r'"es"\s*:\s*"([^"]*)"').firstMatch(decoded);
          if (match != null) nameEs = match.group(1) ?? nameEs;
        }
      } catch (_) {}
    }
    final rawKeywords = json['keywords'];
    final keywords = <String>[];
    if (rawKeywords is List) {
      for (final e in rawKeywords) {
        if (e != null && '$e'.trim().isNotEmpty) {
          keywords.add('$e'.trim());
        }
      }
    }
    final rawParent = json['parent_id'];
    String? parentId;
    if (rawParent != null) {
      final s = '$rawParent'.trim();
      if (s.isNotEmpty && s.toLowerCase() != 'null') {
        parentId = s;
      }
    }

    return Category(
      id: '${json['id']}',
      parentId: parentId,
      slug: json['slug'] as String? ?? '',
      nameEs: nameEs,
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
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

  Map<String, dynamic> toCacheJson() => {
        'id': id,
        'transport_group': transportGroup,
        'slug': slug,
        'name_i18n': {'es': nameEs},
        'is_active': isActive,
        'sort_order': sortOrder,
        'default_max_km': defaultMaxKm,
        'icon_key': iconKey,
      };

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
