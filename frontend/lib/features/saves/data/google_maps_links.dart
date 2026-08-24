/// Parada para armar una ruta en Maps (nombre, no pin de centroide).
class MapsRouteStop {
  const MapsRouteStop({
    required this.name,
    this.city,
    this.department,
    this.googlePlaceId,
    this.lat,
    this.lng,
    this.useExactPin = false,
  });

  final String name;
  final String? city;
  final String? department;
  final String? googlePlaceId;
  final double? lat;
  final double? lng;
  final bool useExactPin;
}

/// Deep links a Google Maps (ficha del **lugar** vs **punto exacto**).
///
/// - Lugar: Place ID o búsqueda por nombre (ficha con fotos/reseñas).
/// - Punto exacto: `query=lat,lng` (el buscador muestra coords, no el nombre).
///
/// Cómo llegar en un plan: **origen = GPS**, **destino = nombre del sitio**.
/// No usar `/maps/dir/lat,lng/lat,lng`: Maps pega el pin al POI más cercano
/// (p. ej. una academia, no la plaza del catálogo).
class GoogleMapsLinks {
  GoogleMapsLinks._();

  static Uri? _coordsQuery(double? lat, double? lng) {
    if (lat == null || lng == null) return null;
    // Solo lat,lng. map_action=map / geo: suelen resolver el POI y
    // rellenan el buscador con el nombre del lugar.
    return Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
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

  /// Cómo llegar. [useExactPin] destina al pin; si no, al lugar (nombre).
  static Uri directionsTo({
    required String name,
    String? city,
    String? department,
    String? googlePlaceId,
    double? lat,
    double? lng,
    bool useExactPin = false,
    double? originLat,
    double? originLng,
  }) {
    if (originLat != null && originLng != null) {
      return directionsFromOrigin(
        originLat: originLat,
        originLng: originLng,
        stopsInOrder: [
          MapsRouteStop(
            name: name,
            city: city,
            department: department,
            googlePlaceId: googlePlaceId,
            lat: lat,
            lng: lng,
            useExactPin: useExactPin,
          ),
        ],
      );
    }
    final dest = _destination(
      MapsRouteStop(
        name: name,
        city: city,
        department: department,
        googlePlaceId: googlePlaceId,
        lat: lat,
        lng: lng,
        useExactPin: useExactPin,
      ),
    );
    final params = <String, String>{
      'api': '1',
      'destination': dest.query,
    };
    if (dest.placeId != null) {
      params['destination_place_id'] = dest.placeId!;
    }
    return Uri.https('www.google.com', '/maps/dir/', params);
  }

  /// Ruta: origen GPS + paradas por **nombre** (salvo punto exacto).
  static Uri directionsFromOrigin({
    required double originLat,
    required double originLng,
    required List<MapsRouteStop> stopsInOrder,
  }) {
    if (stopsInOrder.isEmpty) {
      return Uri.parse('https://www.google.com/maps');
    }
    final dests = stopsInOrder.map(_destination).toList();
    final last = dests.last;
    final ways = dests.sublist(0, dests.length - 1);
    final params = <String, String>{
      'api': '1',
      'origin': '$originLat,$originLng',
      'destination': last.query,
    };
    if (last.placeId != null) {
      params['destination_place_id'] = last.placeId!;
    }
    if (ways.isNotEmpty) {
      params['waypoints'] = ways.map((w) => w.query).join('|');
      if (ways.every((w) => w.placeId != null && w.placeId!.isNotEmpty)) {
        params['waypoint_place_ids'] = ways.map((w) => w.placeId!).join('|');
      }
    }
    return Uri.https('www.google.com', '/maps/dir/', params);
  }

  static ({String query, String? placeId}) _destination(MapsRouteStop s) {
    if (s.useExactPin && s.lat != null && s.lng != null) {
      return (query: '${s.lat},${s.lng}', placeId: null);
    }
    final label = _label(s.name, s.city, s.department);
    final pid = s.googlePlaceId?.trim();
    final placeId = (pid != null && pid.isNotEmpty) ? pid : null;
    if (label.trim().isNotEmpty) {
      return (query: '$label, Colombia', placeId: placeId);
    }
    if (s.lat != null && s.lng != null) {
      return (query: '${s.lat},${s.lng}', placeId: null);
    }
    return (query: 'Colombia', placeId: null);
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
