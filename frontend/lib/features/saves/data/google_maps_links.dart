/// Deep links a Google Maps (ficha del lugar vs pin crudo).
///
/// `query=lat,lng` solo marca un punto sin nombre/fotos/reseñas.
/// Preferir Place ID o búsqueda por nombre.
class GoogleMapsLinks {
  GoogleMapsLinks._();

  /// Ver el lugar en Maps (tarjeta del sitio si Google lo reconoce).
  static Uri viewPlace({
    required String name,
    String? city,
    String? department,
    String? googlePlaceId,
    double? lat,
    double? lng,
  }) {
    final placeId = googlePlaceId?.trim();
    if (placeId != null && placeId.isNotEmpty) {
      final q = Uri.encodeQueryComponent(_label(name, city, department));
      return Uri.parse(
        'https://www.google.com/maps/search/?api=1'
        '&query=$q'
        '&query_place_id=${Uri.encodeQueryComponent(placeId)}',
      );
    }

    final label = _label(name, city, department);
    if (label.trim().isNotEmpty) {
      return Uri.parse(
        'https://www.google.com/maps/search/?api=1'
        '&query=${Uri.encodeQueryComponent('$label, Colombia')}',
      );
    }

    if (lat != null && lng != null) {
      return Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
      );
    }

    return Uri.parse('https://www.google.com/maps');
  }

  /// Cómo llegar: Place ID → nombre → coords.
  static Uri directionsTo({
    required String name,
    String? city,
    String? department,
    String? googlePlaceId,
    double? lat,
    double? lng,
  }) {
    final placeId = googlePlaceId?.trim();
    if (placeId != null && placeId.isNotEmpty) {
      final dest = Uri.encodeQueryComponent(_label(name, city, department));
      return Uri.parse(
        'https://www.google.com/maps/dir/?api=1'
        '&destination=$dest'
        '&destination_place_id=${Uri.encodeQueryComponent(placeId)}',
      );
    }

    final label = _label(name, city, department);
    if (label.trim().isNotEmpty) {
      return Uri.parse(
        'https://www.google.com/maps/dir/?api=1'
        '&destination=${Uri.encodeQueryComponent('$label, Colombia')}',
      );
    }

    if (lat != null && lng != null) {
      return Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
      );
    }

    return Uri.parse('https://www.google.com/maps');
  }

  static String _label(String name, String? city, String? department) {
    final parts = <String>[
      name.trim(),
      if (city != null &&
          city.trim().isNotEmpty &&
          !_same(name, city))
        city.trim(),
      if (department != null &&
          department.trim().isNotEmpty &&
          !_same(name, department) &&
          !_same(city ?? '', department))
        department.trim(),
    ];
    return parts.where((p) => p.isNotEmpty).join(', ');
  }

  static bool _same(String a, String b) =>
      a.trim().toLowerCase() == b.trim().toLowerCase();
}
