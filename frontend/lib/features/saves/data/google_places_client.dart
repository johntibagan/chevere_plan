import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../../core/config/env.dart';
import '../../../core/errors/user_facing_error.dart';
import '../../../core/logging/app_log.dart';
import 'geo_place.dart';
import 'google_places_cache.dart';
import 'google_places_quota.dart';

/// Cliente Places API (New) + Geocoding + Place Details por CID (legacy).
///
/// Anti-fugas: cupo diario, caché, field mask Essentials, sesiones Autocomplete.
class GooglePlacesClient {
  GooglePlacesClient({
    http.Client? httpClient,
    GooglePlacesQuota? quota,
    GooglePlacesCache? cache,
    String? apiKey,
  })  : _http = httpClient ?? http.Client(),
        _quota = quota ?? GooglePlacesQuota(),
        _cache = cache ?? GooglePlacesCache(),
        _apiKey = apiKey ?? Env.googleMapsApiKey;

  final http.Client _http;
  final GooglePlacesQuota _quota;
  final GooglePlacesCache _cache;
  final String _apiKey;

  bool get isConfigured => _apiKey.trim().isNotEmpty;

  /// Nuevo token de sesión Autocomplete (una búsqueda → un Details).
  String newSessionToken() => const Uuid().v4();

  /// Place Details Essentials por `place_id` (ChIJ…).
  Future<GeoPlace?> placeDetails({
    required String placeId,
    String? sessionToken,
  }) async {
    if (!isConfigured) return null;
    final safeId = placeId.startsWith('places/')
        ? placeId.substring('places/'.length)
        : placeId;
    final id = safeId.trim();
    if (id.isEmpty) return null;

    final cached = await _cache.read('details_$id');
    if (cached != null) return cached;

    if (!await _quota.tryConsume()) {
      throw const AppUserError(
        'Límite diario de búsquedas de ubicación. Intenta mañana o usa el mapa.',
      );
    }

    final uri = Uri.https(
      'places.googleapis.com',
      '/v1/places/$id',
      {
        if (sessionToken != null && sessionToken.isNotEmpty)
          'sessionToken': sessionToken,
      },
    );

    final res = await _http
        .get(
          uri,
          headers: {
            'X-Goog-Api-Key': _apiKey,
            'X-Goog-FieldMask':
                'id,displayName,formattedAddress,location,addressComponents',
            'Accept-Language': 'es',
          },
        )
        .timeout(const Duration(seconds: 12));

    if (res.statusCode != 200) {
      AppLog.debug(
        'placeDetails status=${res.statusCode} body=${res.body}',
        name: 'google_places',
      );
      return null;
    }

    final place = _placeFromDetailsJson(
      Map<String, dynamic>.from(jsonDecode(res.body) as Map),
    );
    if (place != null) await _cache.write('details_$id', place);
    return place;
  }

  /// Text Text (New): 1ª coincidencia con coords. Para links Maps con nombre y sin pin.
  Future<GeoPlace?> findByText(String query) async {
    if (!isConfigured) return null;
    final q = query.trim();
    if (q.length < 2) return null;

    final cacheKey = 'text_${q.toLowerCase()}';
    final cached = await _cache.read(cacheKey);
    if (cached != null) return cached;

    if (!await _quota.tryConsume()) {
      throw const AppUserError(
        'Límite diario de búsquedas de ubicación. Intenta mañana o usa el mapa.',
      );
    }

    final res = await _http
        .post(
          Uri.https('places.googleapis.com', '/v1/places:searchText'),
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': _apiKey,
            'X-Goog-FieldMask':
                'places.id,places.displayName,places.formattedAddress,'
                    'places.location,places.addressComponents',
            'Accept-Language': 'es',
          },
          body: jsonEncode({
            'textQuery': q,
            'languageCode': 'es',
            'regionCode': 'CO',
            'maxResultCount': 1,
          }),
        )
        .timeout(const Duration(seconds: 12));

    if (res.statusCode != 200) {
      AppLog.debug(
        'findByText status=${res.statusCode} body=${res.body}',
        name: 'google_places',
      );
      return null;
    }

    final body = Map<String, dynamic>.from(jsonDecode(res.body) as Map);
    final places = body['places'];
    if (places is! List || places.isEmpty) return null;
    final first = places.first;
    if (first is! Map) return null;
    final place = _placeFromDetailsJson(Map<String, dynamic>.from(first));
    if (place != null) await _cache.write(cacheKey, place);
    return place;
  }

  /// Detalle por CID (hex feature id de Maps → decimal string). Legacy, 1 llamada.
  Future<GeoPlace?> placeDetailsByCid(String cidDecimal) async {
    if (!isConfigured || cidDecimal.isEmpty) return null;

    final cacheKey = 'cid_$cidDecimal';
    final cached = await _cache.read(cacheKey);
    if (cached != null) return cached;

    if (!await _quota.tryConsume()) {
      throw const AppUserError(
        'Límite diario de búsquedas de ubicación. Intenta mañana o usa el mapa.',
      );
    }

    final uri = Uri.https('maps.googleapis.com', '/maps/api/place/details/json', {
      'cid': cidDecimal,
      'fields':
          'place_id,name,geometry/location,formatted_address,address_component',
      'language': 'es',
      'key': _apiKey,
    });

    final res =
        await _http.get(uri).timeout(const Duration(seconds: 12));
    if (res.statusCode != 200) return null;

    final body = Map<String, dynamic>.from(jsonDecode(res.body) as Map);
    if (body['status'] != 'OK') {
      AppLog.debug(
        'placeDetailsByCid status=${body['status']}',
        name: 'google_places',
      );
      return null;
    }
    final result = body['result'];
    if (result is! Map) return null;
    final place = _placeFromLegacyDetails(Map<String, dynamic>.from(result));
    if (place != null) await _cache.write(cacheKey, place);
    return place;
  }

  /// Autocomplete (New). Solo invocar al pulsar Buscar (no por tecla).
  Future<List<PlacePrediction>> autocomplete({
    required String input,
    required String sessionToken,
    double? biasLat,
    double? biasLng,
  }) async {
    if (!isConfigured) return const [];
    final q = input.trim();
    if (q.length < 3) return const [];

    if (!await _quota.tryConsume()) {
      throw const AppUserError(
        'Límite diario de búsquedas de ubicación. Intenta mañana o usa el mapa.',
      );
    }

    final payload = <String, dynamic>{
      'input': q,
      'sessionToken': sessionToken,
      'includedRegionCodes': ['co'],
      'languageCode': 'es',
    };
    if (biasLat != null && biasLng != null) {
      payload['locationBias'] = {
        'circle': {
          'center': {'latitude': biasLat, 'longitude': biasLng},
          'radius': 50000.0,
        },
      };
    }

    final res = await _http
        .post(
          Uri.https('places.googleapis.com', '/v1/places:autocomplete'),
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': _apiKey,
            'X-Goog-FieldMask':
                'suggestions.placePrediction.placeId,suggestions.placePrediction.text,suggestions.placePrediction.structuredFormat',
          },
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 12));

    if (res.statusCode != 200) {
      AppLog.debug(
        'autocomplete status=${res.statusCode}',
        name: 'google_places',
      );
      return const [];
    }

    final body = Map<String, dynamic>.from(jsonDecode(res.body) as Map);
    final suggestions = body['suggestions'];
    if (suggestions is! List) return const [];

    final out = <PlacePrediction>[];
    for (final raw in suggestions) {
      if (raw is! Map) continue;
      final pred = raw['placePrediction'];
      if (pred is! Map) continue;
      final placeId = pred['placeId'] as String?;
      if (placeId == null || placeId.isEmpty) continue;
      final structured = pred['structuredFormat'];
      String primary = placeId;
      String? secondary;
      if (structured is Map) {
        final main = structured['mainText'];
        final sec = structured['secondaryText'];
        if (main is Map) primary = (main['text'] as String?) ?? primary;
        if (sec is Map) secondary = sec['text'] as String?;
      } else {
        final text = pred['text'];
        if (text is Map) primary = (text['text'] as String?) ?? primary;
      }
      out.add(
        PlacePrediction(
          placeId: placeId,
          primaryText: primary,
          secondaryText: secondary,
        ),
      );
    }
    return out;
  }

  /// Lugares cercanos al pin (POI: parque, tienda…). Radio corto (~80 m).
  Future<List<GeoPlace>> searchNearby({
    required double lat,
    required double lng,
    double radiusM = 80,
    int maxResults = 8,
  }) async {
    if (!isConfigured) return const [];

    final cacheKey =
        'near_${lat.toStringAsFixed(5)}_${lng.toStringAsFixed(5)}_'
        '${radiusM.round()}';
    final cachedList = await _cache.readList(cacheKey);
    if (cachedList != null) return cachedList;

    if (!await _quota.tryConsume()) {
      throw const AppUserError(
        'Límite diario de búsquedas de ubicación. Intenta mañana o usa el mapa.',
      );
    }

    final res = await _http
        .post(
          Uri.https('places.googleapis.com', '/v1/places:searchNearby'),
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': _apiKey,
            'X-Goog-FieldMask':
                'places.id,places.displayName,places.formattedAddress,'
                    'places.location,places.addressComponents',
            'Accept-Language': 'es',
          },
          body: jsonEncode({
            'languageCode': 'es',
            'regionCode': 'CO',
            'maxResultCount': maxResults.clamp(1, 20),
            'rankPreference': 'DISTANCE',
            'locationRestriction': {
              'circle': {
                'center': {'latitude': lat, 'longitude': lng},
                'radius': radiusM.clamp(10, 500),
              },
            },
          }),
        )
        .timeout(const Duration(seconds: 12));

    if (res.statusCode != 200) {
      AppLog.debug(
        'searchNearby status=${res.statusCode} body=${res.body}',
        name: 'google_places',
      );
      return const [];
    }

    final body = Map<String, dynamic>.from(jsonDecode(res.body) as Map);
    final places = body['places'];
    if (places is! List) return const [];

    final out = <GeoPlace>[];
    for (final raw in places) {
      if (raw is! Map) continue;
      final place = _placeFromDetailsJson(Map<String, dynamic>.from(raw));
      if (place != null) out.add(place);
    }
    if (out.isNotEmpty) await _cache.writeList(cacheKey, out);
    return out;
  }

  /// Reverse geocode (1 llamada por tap en mapa).
  Future<GeoPlace?> reverseGeocode({
    required double lat,
    required double lng,
  }) async {
    if (!isConfigured) return null;

    final cacheKey =
        'rev_${lat.toStringAsFixed(5)}_${lng.toStringAsFixed(5)}';
    final cached = await _cache.read(cacheKey);
    if (cached != null) return cached;

    if (!await _quota.tryConsume()) {
      throw const AppUserError(
        'Límite diario de búsquedas de ubicación. Intenta mañana.',
      );
    }

    final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'latlng': '$lat,$lng',
      'language': 'es',
      'region': 'co',
      'key': _apiKey,
    });

    final res =
        await _http.get(uri).timeout(const Duration(seconds: 12));
    if (res.statusCode != 200) return null;

    final body = Map<String, dynamic>.from(jsonDecode(res.body) as Map);
    if (body['status'] != 'OK') return null;
    final results = body['results'];
    if (results is! List || results.isEmpty) return null;
    final first = results.first;
    if (first is! Map) return null;

    final place = _placeFromGeocode(
      Map<String, dynamic>.from(first),
      lat: lat,
      lng: lng,
    );
    if (place != null) await _cache.write(cacheKey, place);
    return place;
  }

  static String? extractChijPlaceId(String raw) {
    final m = RegExp(r'(ChIJ[\w-]+)').firstMatch(raw);
    return m?.group(1);
  }

  static String? cidFromFeatureId(String? featureId) {
    if (featureId == null || featureId.isEmpty) return null;
    final parts = featureId.split(':');
    if (parts.length != 2) return null;
    final hex =
        parts.last.replaceFirst(RegExp(r'^0x', caseSensitive: false), '');
    try {
      return BigInt.parse(hex, radix: 16).toString();
    } catch (_) {
      return null;
    }
  }

  static GeoPlace? _placeFromDetailsJson(Map<String, dynamic> json) {
    final loc = json['location'];
    if (loc is! Map) return null;
    final lat = (loc['latitude'] as num?)?.toDouble();
    final lng = (loc['longitude'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;

    final display = json['displayName'];
    final name = display is Map ? display['text'] as String? : null;
    final formatted = json['formattedAddress'] as String?;
    final comps = _parseAddressComponentsNew(json['addressComponents']);

    return GeoPlace(
      lat: lat,
      lng: lng,
      placeId: json['id'] as String?,
      name: name,
      displayName: formatted ?? name,
      addressLine: formatted ?? name,
      city: comps.city,
      department: comps.department,
      isPlaceFicha: true,
    );
  }

  static GeoPlace? _placeFromLegacyDetails(Map<String, dynamic> json) {
    final geom = json['geometry'];
    if (geom is! Map) return null;
    final loc = geom['location'];
    if (loc is! Map) return null;
    final lat = (loc['lat'] as num?)?.toDouble();
    final lng = (loc['lng'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;

    final comps = _parseAddressComponentsLegacy(json['address_components']);
    final name = json['name'] as String?;
    final formatted = json['formatted_address'] as String?;

    return GeoPlace(
      lat: lat,
      lng: lng,
      placeId: json['place_id'] as String?,
      name: name,
      displayName: formatted ?? name,
      addressLine: formatted ?? name,
      city: comps.city,
      department: comps.department,
      isPlaceFicha: true,
    );
  }

  static GeoPlace? _placeFromGeocode(
    Map<String, dynamic> json, {
    required double lat,
    required double lng,
  }) {
    final comps = _parseAddressComponentsLegacy(json['address_components']);
    final formatted = json['formatted_address'] as String?;
    return GeoPlace(
      lat: lat,
      lng: lng,
      placeId: json['place_id'] as String?,
      displayName: formatted,
      addressLine: formatted,
      name: comps.city ?? formatted,
      city: comps.city,
      department: comps.department,
      isPlaceFicha: false,
    );
  }

  static ({String? city, String? department}) _parseAddressComponentsNew(
    Object? raw,
  ) {
    if (raw is! List) return (city: null, department: null);
    String? city;
    String? department;
    for (final item in raw) {
      if (item is! Map) continue;
      final types = item['types'];
      if (types is! List) continue;
      final text = item['longText'] as String? ?? item['shortText'] as String?;
      if (text == null || text.isEmpty) continue;
      if (types.contains('locality') ||
          types.contains('administrative_area_level_2')) {
        city ??= text;
      }
      if (types.contains('administrative_area_level_1')) {
        department ??= text;
      }
    }
    return (city: city, department: department);
  }

  static ({String? city, String? department}) _parseAddressComponentsLegacy(
    Object? raw,
  ) {
    if (raw is! List) return (city: null, department: null);
    String? city;
    String? department;
    for (final item in raw) {
      if (item is! Map) continue;
      final types = item['types'];
      if (types is! List) continue;
      final text = item['long_name'] as String?;
      if (text == null || text.isEmpty) continue;
      if (types.contains('locality') ||
          types.contains('administrative_area_level_2')) {
        city ??= text;
      }
      if (types.contains('administrative_area_level_1')) {
        department ??= text;
      }
    }
    return (city: city, department: department);
  }
}
