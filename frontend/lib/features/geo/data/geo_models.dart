class GeoDepartment {
  const GeoDepartment({
    required this.id,
    required this.countryCode,
    required this.code,
    required this.name,
    required this.nameNorm,
  });

  final String id;
  final String countryCode;
  final String code;
  final String name;
  final String nameNorm;

  factory GeoDepartment.fromJson(Map<String, dynamic> json) {
    return GeoDepartment(
      id: json['id'] as String,
      countryCode: (json['country_code'] as String? ?? 'CO').trim(),
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nameNorm: json['name_norm'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'country_code': countryCode,
        'code': code,
        'name': name,
        'name_norm': nameNorm,
      };
}

class GeoCity {
  const GeoCity({
    required this.id,
    required this.departmentId,
    required this.code,
    required this.name,
    required this.nameNorm,
    this.kind,
  });

  final String id;
  final String departmentId;
  final String code;
  final String name;
  final String nameNorm;
  final String? kind;

  factory GeoCity.fromJson(Map<String, dynamic> json) {
    return GeoCity(
      id: json['id'] as String,
      departmentId: json['department_id'] as String,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nameNorm: json['name_norm'] as String? ?? '',
      kind: json['kind'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'department_id': departmentId,
        'code': code,
        'name': name,
        'name_norm': nameNorm,
        'kind': kind,
      };
}

class GeoCatalog {
  const GeoCatalog({
    required this.departments,
    required this.cities,
    this.countryCode = 'CO',
  });

  final List<GeoDepartment> departments;
  final List<GeoCity> cities;
  final String countryCode;

  List<GeoDepartment> get activeDepartments =>
      departments.where((d) => d.countryCode == countryCode).toList();

  List<GeoCity> citiesIn(String departmentId) =>
      cities.where((c) => c.departmentId == departmentId).toList();

  GeoDepartment? departmentById(String id) {
    for (final d in departments) {
      if (d.id == id) return d;
    }
    return null;
  }

  GeoCity? cityById(String id) {
    for (final c in cities) {
      if (c.id == id) return c;
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'country_code': countryCode,
        'departments': departments.map((d) => d.toJson()).toList(),
        'cities': cities.map((c) => c.toJson()).toList(),
      };

  factory GeoCatalog.fromJson(Object? raw) {
    final json = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
    final depts = (json['departments'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => GeoDepartment.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final cities = (json['cities'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => GeoCity.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return GeoCatalog(
      countryCode: json['country_code'] as String? ?? 'CO',
      departments: depts,
      cities: cities,
    );
  }
}
