import 'bigdatacloud_geocoder.dart';
import 'geo_place.dart';
import 'geoapify_geocoder.dart';
import 'geocoder_quota.dart';
import 'google_places_client.dart';
import 'nominatim_geocoder.dart';

/// Google Places si hay key; si no / cupo, Geoapify → BigDataCloud → Nominatim.
class PlaceGeocoder {
  PlaceGeocoder({
    GooglePlacesClient? google,
    GeoapifyGeocoder? geoapify,
    BigDataCloudGeocoder? bigDataCloud,
    NominatimGeocoder? nominatim,
    GeocoderQuota? quota,
  })  : _google = google ?? GooglePlacesClient(),
        _geoapify = geoapify ?? GeoapifyGeocoder(),
        _bigDataCloud = bigDataCloud ?? BigDataCloudGeocoder(),
        _nominatim = nominatim ?? NominatimGeocoder(),
        _quota = quota ?? GeocoderQuota();

  final GooglePlacesClient _google;
  final GeoapifyGeocoder _geoapify;
  final BigDataCloudGeocoder _bigDataCloud;
  final NominatimGeocoder _nominatim;
  final GeocoderQuota _quota;

  bool get usingGoogle => _google.isConfigured;
  bool get usingGeoapify => _geoapify.isConfigured;

  Future<List<GeoPlace>> search(
    String query, {
    int limit = 8,
    double? biasLat,
    double? biasLng,
  }) async {
    // Preferir Google vía LocationPicker (sesión). Aquí queda fallback Geoapify.
    if (_geoapify.isConfigured) {
      try {
        if (await _quota.tryConsume()) {
          final hits = await _geoapify.autocomplete(
            query,
            limit: limit,
            biasLat: biasLat,
            biasLng: biasLng,
          );
          if (hits.isNotEmpty) return hits;
        }
      } catch (_) {}
    }
    return _nominatim.search(query, limit: limit);
  }

  Future<GeoPlace?> reverse({
    required double lat,
    required double lng,
  }) async {
    if (_google.isConfigured) {
      try {
        final g = await _google.reverseGeocode(lat: lat, lng: lng);
        if (g != null) return g;
      } catch (_) {}
    }

    GeoPlace? acc;

    if (_geoapify.isConfigured) {
      try {
        if (await _quota.tryConsume()) {
          acc = _merge(acc, await _geoapify.reverse(lat: lat, lng: lng));
        }
      } catch (_) {}
    }
    if (_isComplete(acc)) return _withAddress(acc);

    try {
      acc = _merge(acc, await _bigDataCloud.reverse(lat: lat, lng: lng));
    } catch (_) {}
    if (_isComplete(acc)) return _withAddress(acc);

    try {
      acc = _merge(acc, await _nominatim.reverse(lat: lat, lng: lng));
    } catch (_) {}

    return _withAddress(acc);
  }

  static bool _isComplete(GeoPlace? p) {
    if (p == null) return false;
    return (p.city?.trim().isNotEmpty ?? false) &&
        (p.department?.trim().isNotEmpty ?? false);
  }

  static GeoPlace? _merge(GeoPlace? a, GeoPlace? b) {
    if (a == null) return b;
    if (b == null) return a;
    return GeoPlace(
      lat: a.lat,
      lng: a.lng,
      displayName: a.displayName ?? b.displayName,
      name: a.name ?? b.name,
      city: _or(a.city, b.city),
      department: _or(a.department, b.department),
      addressLine: _or(a.addressLine, b.addressLine),
      placeId: a.placeId ?? b.placeId,
    );
  }

  static GeoPlace? _withAddress(GeoPlace? p) {
    if (p == null) return null;
    if (p.addressLine != null && p.addressLine!.trim().isNotEmpty) return p;
    final line = [p.city, p.department]
        .where((s) => s != null && s.trim().isNotEmpty)
        .join(', ');
    if (line.isEmpty) return p;
    return GeoPlace(
      lat: p.lat,
      lng: p.lng,
      displayName: p.displayName ?? line,
      name: p.name,
      city: p.city,
      department: p.department,
      addressLine: line,
      placeId: p.placeId,
    );
  }

  static String? _or(String? a, String? b) {
    if (a != null && a.trim().isNotEmpty) return a.trim();
    if (b != null && b.trim().isNotEmpty) return b.trim();
    return null;
  }
}
