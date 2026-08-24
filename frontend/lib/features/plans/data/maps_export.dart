import 'package:url_launcher/url_launcher.dart';

import '../../saves/data/google_maps_links.dart';
import 'plan_models.dart';

/// Cómo llegar: origen = tu GPS; cada parada = **nombre del sitio**.
/// Las coords del catálogo (centroide DIVIPOLA) no van en el link:
/// Maps las convierte en el negocio más cercano.
Uri buildGoogleMapsDirectionsUri({
  required double originLat,
  required double originLng,
  required List<PlanStop> stopsInOrder,
}) {
  final stops = stopsInOrder
      .where(
        (s) =>
            s.siteName.trim().isNotEmpty ||
            (s.lat != null && s.lng != null),
      )
      .map(
        (s) => MapsRouteStop(
          name: s.siteName,
          city: s.city,
          department: s.department,
          googlePlaceId: s.googlePlaceId,
          lat: s.lat,
          lng: s.lng,
          useExactPin: s.useExactPin,
        ),
      )
      .toList();

  return GoogleMapsLinks.directionsFromOrigin(
    originLat: originLat,
    originLng: originLng,
    stopsInOrder: stops,
  );
}

Future<bool> openGoogleMapsDirections({
  required double originLat,
  required double originLng,
  required List<PlanStop> stopsInOrder,
}) async {
  if (stopsInOrder.every(
    (s) => s.siteName.trim().isEmpty && (s.lat == null || s.lng == null),
  )) {
    return false;
  }
  final uri = buildGoogleMapsDirectionsUri(
    originLat: originLat,
    originLng: originLng,
    stopsInOrder: stopsInOrder,
  );
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
