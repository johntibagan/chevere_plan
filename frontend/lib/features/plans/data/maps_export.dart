import 'package:url_launcher/url_launcher.dart';

import 'plan_models.dart';

/// Deep link multi-destino (§7.3).
/// Formato path `/maps/dir/lat,lng/lat,lng/...` — más fiable en app Android
/// que waypoints con `|` en query.
Uri buildGoogleMapsDirectionsUri({
  required double originLat,
  required double originLng,
  required List<PlanStop> stopsInOrder,
}) {
  final withCoords = stopsInOrder
      .where((s) => s.lat != null && s.lng != null)
      .toList();

  final segments = <String>[
    '${_fmt(originLat)},${_fmt(originLng)}',
    for (final s in withCoords) '${_fmt(s.lat!)},${_fmt(s.lng!)}',
  ];

  return Uri.parse(
    'https://www.google.com/maps/dir/${segments.join('/')}',
  );
}

String _fmt(double v) => v.toStringAsFixed(6);

Future<bool> openGoogleMapsDirections({
  required double originLat,
  required double originLng,
  required List<PlanStop> stopsInOrder,
}) async {
  if (stopsInOrder.every((s) => s.lat == null || s.lng == null)) {
    return false;
  }
  final uri = buildGoogleMapsDirectionsUri(
    originLat: originLat,
    originLng: originLng,
    stopsInOrder: stopsInOrder,
  );
  if (await canLaunchUrl(uri)) {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
