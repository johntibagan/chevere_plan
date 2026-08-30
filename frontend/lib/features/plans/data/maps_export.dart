import '../../saves/data/google_maps_links.dart';
import '../../saves/data/navigation_apps.dart';
import 'plan_models.dart';

/// Cómo llegar: origen = tu GPS; cada parada = **nombre del sitio**.
/// Las coords del catálogo (centroide DIVIPOLA) no van en el link:
/// Maps las convierte en el negocio más cercano.
Uri buildGoogleMapsDirectionsUri({
  required double originLat,
  required double originLng,
  required List<PlanStop> stopsInOrder,
}) {
  return GoogleMapsLinks.directionsFromOrigin(
    originLat: originLat,
    originLng: originLng,
    stopsInOrder: _toRouteStops(stopsInOrder),
  );
}

List<MapsRouteStop> _toRouteStops(List<PlanStop> stopsInOrder) {
  return stopsInOrder
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
          isCatalogSite: s.isCatalogSite,
        ),
      )
      .toList();
}

/// Chooser nativo: solo Maps · Waze · Uber (Maps = ruta multi-parada).
Future<bool> openDirectionsChooser({
  required String chooserTitle,
  required double originLat,
  required double originLng,
  required List<PlanStop> stopsInOrder,
}) async {
  final stops = _toRouteStops(stopsInOrder);
  if (stops.isEmpty) return false;
  return NavigationApps.openDirectionsChooser(
    chooserTitle: chooserTitle,
    originLat: originLat,
    originLng: originLng,
    stopsInOrder: stops,
  );
}
