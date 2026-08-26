class ProximitySite {
  const ProximitySite({
    required this.siteId,
    required this.name,
    required this.lat,
    required this.lng,
    required this.isOwn,
    this.city,
    this.department,
    this.coverStoragePath,
  });

  final String siteId;
  final String name;
  final double lat;
  final double lng;
  final bool isOwn;
  final String? city;
  final String? department;
  final String? coverStoragePath;

  factory ProximitySite.fromJson(Map<String, dynamic> json) {
    return ProximitySite(
      siteId: json['site_id'] as String,
      name: (json['name'] as String?) ?? 'Lugar',
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      isOwn: json['is_own'] as bool? ?? false,
      city: json['city'] as String?,
      department: json['department'] as String?,
      coverStoragePath: json['cover_storage_path'] as String?,
    );
  }
}
