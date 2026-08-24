/// Deep links a Google Maps (ficha del **lugar** vs **punto exacto**).
///
/// - Lugar: Place ID o búsqueda por nombre (ficha con fotos/reseñas).
/// - Punto exacto: `query=lat,lng` (pin; sin ficha).
class GoogleMapsLinks {
  GoogleMapsLinks._();

  static Uri? _coordsQuery(double? lat, double? lng) {
    if (lat == null || lng == null) return null;
    return Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
  }

  static Uri? _coordsDir(double? lat, double? lng) {
    if (lat == null || lng == null) return null;
    return Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );
  }

  /// Ver en Maps. [useExactPin] usa coords; si no, ficha/búsqueda del lugar.
  static Uri viewPlace({
    required String name,
    String? city,
    String? department,
    String? googlePlaceId,
    double? lat,
    double? lng,
    bool useExactPin = false,
  }) {
    if (useExactPin) {
      final pin = _coordsQuery(lat, lng);
      if (pin != null) return pin;
    }
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

    return _coordsQuery(lat, lng) ?? Uri.parse('https://www.google.com/maps');
  }

  /// Cómo llegar. [useExactPin] destina al pin; si no, al lugar.
  static Uri directionsTo({
    required String name,
    String? city,
    String? department,
    String? googlePlaceId,
    double? lat,
    double? lng,
    bool useExactPin = false,
  }) {
    if (useExactPin) {
      final pin = _coordsDir(lat, lng);
      if (pin != null) return pin;
    }
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
