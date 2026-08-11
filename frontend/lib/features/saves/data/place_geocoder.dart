import '../../../core/config/env.dart';
import '../../../core/errors/user_facing_error.dart';
import 'geo_place.dart';
import 'geoapify_geocoder.dart';
import 'geocoder_quota.dart';
import 'nominatim_geocoder.dart';

/// Geocoder de la app: Geoapify (preferido) con fallback Nominatim.
class PlaceGeocoder {
  PlaceGeocoder({
    GeoapifyGeocoder? geoapify,
    NominatimGeocoder? nominatim,
    GeocoderQuota? quota,
  })  : _geoapify = geoapify ?? GeoapifyGeocoder(),
        _nominatim = nominatim ?? NominatimGeocoder(),
        _quota = quota ?? GeocoderQuota();

  final GeoapifyGeocoder _geoapify;
  final NominatimGeocoder _nominatim;
  final GeocoderQuota _quota;

  bool get usingGeoapify => _geoapify.isConfigured;

  Future<List<GeoPlace>> search(
    String query, {
    int limit = 8,
    double? biasLat,
    double? biasLng,
  }) async {
    if (_geoapify.isConfigured) {
      final ok = await _quota.tryConsume();
      if (!ok) {
        throw AppUserError(
          'Límite diario de búsquedas alcanzado '
          '(${Env.geoapifyDailyLimit}/día en prueba). Intenta mañana.',
        );
      }
      final hits = await _geoapify.autocomplete(
        query,
        limit: limit,
        biasLat: biasLat,
        biasLng: biasLng,
      );
      if (hits.isNotEmpty) return hits;
    }
    return _nominatim.search(query, limit: limit);
  }

  Future<GeoPlace?> reverse({
    required double lat,
    required double lng,
  }) async {
    if (_geoapify.isConfigured) {
      final ok = await _quota.tryConsume();
      if (ok) {
        final place = await _geoapify.reverse(lat: lat, lng: lng);
        if (place != null) return place;
      }
    }
    return _nominatim.reverse(lat: lat, lng: lng);
  }
}
