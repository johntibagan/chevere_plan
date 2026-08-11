/// Resultado de búsqueda / reverse geocode / autocomplete.
class GeoPlace {
  const GeoPlace({
    required this.lat,
    required this.lng,
    this.displayName,
    this.name,
    this.city,
    this.department,
    this.addressLine,
  });

  final double lat;
  final double lng;
  final String? displayName;
  final String? name;
  final String? city;
  final String? department;
  final String? addressLine;
}
