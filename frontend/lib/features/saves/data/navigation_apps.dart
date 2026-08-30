import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'google_maps_links.dart';

/// Chooser nativo: solo **Maps · Waze · Uber** (Maps = ruta completa; resto 1.ª parada).
abstract final class NavigationApps {
  static const _channel = MethodChannel('com.chevere.plan/navigation');

  static const mapsPackage = 'com.google.android.apps.maps';
  static const wazePackage = 'com.waze';
  static const uberPackage = 'com.ubercab';

  /// Cómo llegar. Maps recibe **todas** las paradas; el resto solo la 1.ª.
  static Future<bool> openDirectionsChooser({
    required String chooserTitle,
    double? originLat,
    double? originLng,
    required List<MapsRouteStop> stopsInOrder,
  }) async {
    final stops = stopsInOrder
        .where(
          (s) =>
              s.name.trim().isNotEmpty ||
              (s.lat != null && s.lng != null) ||
              (s.googlePlaceId ?? '').trim().isNotEmpty,
        )
        .toList();
    if (stops.isEmpty) return false;

    final googleUri = (originLat != null && originLng != null)
        ? GoogleMapsLinks.directionsFromOrigin(
            originLat: originLat,
            originLng: originLng,
            stopsInOrder: stops,
          )
        : GoogleMapsLinks.directionsTo(
            name: stops.last.name,
            city: stops.last.city,
            department: stops.last.department,
            googlePlaceId: stops.last.googlePlaceId,
            lat: stops.last.lat,
            lng: stops.last.lng,
            useExactPin: stops.last.useExactPin,
          );

    final first = stops.first;
    return _openNativeChooser(
      title: chooserTitle,
      googleMapsUri: googleUri,
      wazeUri: wazeNavigateUri(first),
      uberUri: uberDropoffUri(first),
      fallback: googleUri,
    );
  }

  /// Ver lugar (sin ruta multi-parada).
  static Future<bool> openViewChooser({
    required String chooserTitle,
    required MapsRouteStop place,
  }) async {
    final googleUri = GoogleMapsLinks.viewPlace(
      name: place.name,
      city: place.city,
      department: place.department,
      googlePlaceId: place.googlePlaceId,
      lat: place.lat,
      lng: place.lng,
      useExactPin: place.useExactPin,
    );
    return _openNativeChooser(
      title: chooserTitle,
      googleMapsUri: googleUri,
      wazeUri: wazeViewUri(place),
      uberUri: uberDropoffUri(place),
      fallback: googleUri,
    );
  }

  static Future<bool> _openNativeChooser({
    required String title,
    required Uri googleMapsUri,
    required Uri wazeUri,
    required Uri uberUri,
    required Uri fallback,
  }) async {
    try {
      final ok = await _channel.invokeMethod<bool>('openChooser', {
        'title': title,
        'googleMapsUri': googleMapsUri.toString(),
        'wazeUri': wazeUri.toString(),
        'uberUri': uberUri.toString(),
      });
      if (ok == true) return true;
    } on MissingPluginException {
      // Tests / plataforma sin canal.
    } on PlatformException {
      // Fallo del chooser nativo → fallback.
    }
    return launchUrl(fallback, mode: LaunchMode.externalApplication);
  }

  /// Otras apps de mapas: búsqueda por nombre (no centroide), salvo punto exacto.
  static Uri geoUri(MapsRouteStop s) {
    final label = _label(s);
    if (s.useExactPin && s.lat != null && s.lng != null) {
      final q = label.isNotEmpty
          ? '${s.lat},${s.lng}($label)'
          : '${s.lat},${s.lng}';
      return Uri(
        scheme: 'geo',
        path: '${s.lat},${s.lng}',
        queryParameters: {'q': q},
      );
    }
    if (label.isNotEmpty) {
      return Uri(
        scheme: 'geo',
        path: '0,0',
        queryParameters: {'q': '$label, Colombia'},
      );
    }
    if (s.lat != null && s.lng != null && !s.isCatalogSite) {
      return Uri(scheme: 'geo', path: '${s.lat},${s.lng}');
    }
    return Uri(
      scheme: 'geo',
      path: '0,0',
      queryParameters: const {'q': 'Colombia'},
    );
  }

  static Uri wazeNavigateUri(MapsRouteStop s) => _wazeUri(s, navigate: true);

  static Uri wazeViewUri(MapsRouteStop s) => _wazeUri(s, navigate: false);

  static Uri _wazeUri(MapsRouteStop s, {required bool navigate}) {
    final params = <String, String>{};
    if (navigate) params['navigate'] = 'yes';

    if (s.useExactPin && s.lat != null && s.lng != null) {
      params['ll'] = '${s.lat},${s.lng}';
      return Uri.https('waze.com', '/ul', params);
    }

    final q = _label(s);
    if (q.isNotEmpty) {
      params['q'] = '$q, Colombia';
      return Uri.https('waze.com', '/ul', params);
    }

    if (s.lat != null && s.lng != null && !s.isCatalogSite) {
      params['ll'] = '${s.lat},${s.lng}';
      return Uri.https('waze.com', '/ul', params);
    }

    params['q'] = 'Colombia';
    return Uri.https('waze.com', '/ul', params);
  }

  /// Uber siempre en el chooser; lat/lng solo si son fiables (no centroide catálogo).
  static bool coordsTrustedForRide(MapsRouteStop s) {
    if (s.lat == null || s.lng == null) return false;
    if (s.useExactPin) return true;
    if (s.isCatalogSite) return false;
    return true;
  }

  static Uri uberDropoffUri(MapsRouteStop s) {
    final nick = s.name.trim().isNotEmpty ? s.name.trim() : 'Destino';
    final address = _label(s);
    final params = <String, String>{
      'action': 'setPickup',
      'pickup': 'my_location',
      'dropoff[nickname]': nick,
    };
    if (address.isNotEmpty) {
      params['dropoff[formatted_address]'] = '$address, Colombia';
    }
    if (coordsTrustedForRide(s)) {
      params['dropoff[latitude]'] = '${s.lat}';
      params['dropoff[longitude]'] = '${s.lng}';
    }
    return Uri(
      scheme: 'https',
      host: 'm.uber.com',
      path: '/ul/',
      queryParameters: params,
    );
  }

  static String _label(MapsRouteStop s) {
    final parts = <String>[
      s.name.trim(),
      if ((s.city ?? '').trim().isNotEmpty) s.city!.trim(),
      if ((s.department ?? '').trim().isNotEmpty) s.department!.trim(),
    ];
    return parts.where((p) => p.isNotEmpty).join(', ');
  }
}
