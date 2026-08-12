import 'package:http/http.dart' as http;

import '../../../core/config/env.dart';
import '../../../core/errors/user_facing_error.dart';
import '../../../core/logging/app_log.dart';
import 'geo_place.dart';
import 'google_places_cache.dart';
import 'google_places_client.dart';
import 'place_geocoder.dart';

/// Resultado de importar un enlace de Google Maps.
class GoogleMapsImportResult {
  const GoogleMapsImportResult({
    this.name,
    this.lat,
    this.lng,
    this.city,
    this.department,
    this.addressLine,
    this.staticMapUrl,
    this.resolvedUrl,
    this.hasExactPin = false,
  });

  final String? name;
  final double? lat;
  final double? lng;
  final String? city;
  final String? department;
  final String? addressLine;
  final String? staticMapUrl;
  final String? resolvedUrl;
  final bool hasExactPin;

  bool get hasCoords => lat != null && lng != null;
  bool get hasAnything =>
      hasCoords ||
      (name != null && name!.trim().isNotEmpty) ||
      (addressLine != null && addressLine!.trim().isNotEmpty);

  GeoPlace? toGeoPlace() {
    if (lat == null || lng == null) return null;
    return GeoPlace(
      lat: lat!,
      lng: lng!,
      name: name,
      displayName: addressLine ?? name,
      city: city,
      department: department,
      addressLine: addressLine,
    );
  }

  factory GoogleMapsImportResult.fromGeoPlace(
    GeoPlace p, {
    String? resolvedUrl,
    bool hasExactPin = true,
  }) {
    return GoogleMapsImportResult(
      name: p.name,
      lat: p.lat,
      lng: p.lng,
      city: p.city,
      department: p.department,
      addressLine: p.addressLine ?? p.displayName,
      resolvedUrl: resolvedUrl,
      hasExactPin: hasExactPin,
      staticMapUrl: null,
    );
  }
}

/// Importa enlaces Maps con el mínimo de red.
///
/// Con Google Places configurado:
/// 1. Caché por URL
/// 2. Redirect (solo headers Location)
/// 3. Parse `!3d!4d` / nombre / feature-id en la URL
/// 4. Si falta pin → **1×** Place Details (ChIJ o CID)
/// 5. Reverse geocode **solo** si hay coords y falta ciudad
///
/// Sin Google: redirect + parse; como último recurso un único fetch HTML ligero.
class GoogleMapsLinkImporter {
  GoogleMapsLinkImporter({
    PlaceGeocoder? geocoder,
    GooglePlacesClient? places,
    GooglePlacesCache? cache,
    http.Client? httpClient,
    this.geocode = true,
  })  : _geocoder = geocoder ?? PlaceGeocoder(),
        _places = places ?? GooglePlacesClient(),
        _cache = cache ?? GooglePlacesCache(),
        _http = httpClient ?? http.Client();

  final PlaceGeocoder _geocoder;
  final GooglePlacesClient _places;
  final GooglePlacesCache _cache;
  final http.Client _http;
  final bool geocode;

  static const _kMapsUa =
      'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36';

  static const _kHeaders = {
    'User-Agent': _kMapsUa,
    'Accept': 'text/html,application/xhtml+xml;q=0.9,*/*;q=0.8',
    'Accept-Language': 'es-CO,es;q=0.9,en;q=0.8',
  };

  static final _urlRegex = RegExp(
    r'https?:\/\/[^\s<>"{}|\\^`\[\]]+',
    caseSensitive: false,
  );

  static bool looksLikeMapsUrl(String? text) {
    if (text == null || text.trim().isEmpty) return false;
    final v = text.toLowerCase();
    return v.contains('google.com/maps') ||
        v.contains('maps.google.') ||
        v.contains('maps.app.goo.gl') ||
        v.contains('goo.gl/maps');
  }

  static String? extractUrl(String text) {
    final m = _urlRegex.firstMatch(text.trim());
    return m?.group(0) ?? (text.trim().startsWith('http') ? text.trim() : null);
  }

  Future<GoogleMapsImportResult> importFromText(String text) async {
    final raw = extractUrl(text);
    if (raw == null) {
      throw const AppUserError('No se encontró un enlace.');
    }
    if (!looksLikeMapsUrl(raw)) {
      throw const AppUserError('El enlace no parece de Google Maps.');
    }

    final cacheKey = 'maps_url_${raw.trim()}';
    final cached = await _cache.read(cacheKey);
    if (cached != null) {
      AppLog.debug('maps import cache hit', name: 'maps_import');
      return GoogleMapsImportResult.fromGeoPlace(
        cached,
        resolvedUrl: raw,
        hasExactPin: true,
      )._withStaticMap();
    }

    Uri resolved;
    try {
      resolved = await _resolveFinalUrl(raw);
    } catch (e) {
      if (e is AppUserError) rethrow;
      throw const AppUserError(
        'No se pudo abrir el enlace de Google Maps. Intenta de nuevo.',
      );
    }

    var parsed = parseMapsUrl(resolved);
    var lat = parsed.lat;
    var lng = parsed.lng;
    var hasExactPin = parsed.hasExactPin;
    var name = parsed.name;
    String? city = parsed.city;
    String? department = parsed.department;
    String? address = parsed.addressLine;
    var blob = resolved.toString();

    // HTML una vez si falta pin (acortador 200 / consent / data solo en body).
    if (!hasExactPin) {
      try {
        final body = await _fetchBody(resolved);
        blob = '$blob\n$body';
        final fromHtml = _extractMapsUriFromHtml(body);
        if (fromHtml != null) {
          resolved = fromHtml;
          blob = '$blob\n${fromHtml.toString()}';
          final again = parseMapsUrl(fromHtml);
          if (again.hasExactPin) {
            lat = again.lat;
            lng = again.lng;
            hasExactPin = true;
          }
          name ??= again.name;
          address ??= again.addressLine;
        }
        final pin = extractExactPinCoords(body);
        if (pin != null) {
          lat = pin.$1;
          lng = pin.$2;
          hasExactPin = true;
        }
        name ??= _extractTitleFromHtml(body);
      } catch (e, st) {
        AppLog.debug(
          'maps import html fallback failed',
          name: 'maps_import',
          error: e,
          stackTrace: st,
        );
      }
    }

    // Google Places: Details (ChIJ/CID) o Search Text por nombre (API New).
    if (!hasExactPin && _places.isConfigured) {
      try {
        GeoPlace? fromPlaces;
        final chij = GooglePlacesClient.extractChijPlaceId(blob);
        if (chij != null) {
          fromPlaces = await _places.placeDetails(placeId: chij);
        }
        if (fromPlaces == null) {
          final fid = extractFeatureId(blob);
          final cid = GooglePlacesClient.cidFromFeatureId(fid);
          if (cid != null) {
            fromPlaces = await _places.placeDetailsByCid(cid);
          }
        }
        // Links que solo traen /place/Nombre → 1× Search Text (Places New).
        if (fromPlaces == null) {
          final q = (name ?? '').trim();
          if (q.length >= 2) {
            fromPlaces = await _places.findByText(q);
          }
        }
        if (fromPlaces != null) {
          lat = fromPlaces.lat;
          lng = fromPlaces.lng;
          hasExactPin = true;
          name ??= fromPlaces.name;
          city ??= fromPlaces.city;
          department ??= fromPlaces.department;
          address ??= fromPlaces.addressLine ?? fromPlaces.displayName;
        }
      } catch (e, st) {
        AppLog.debug(
          'maps import places failed',
          name: 'maps_import',
          error: e,
          stackTrace: st,
        );
        if (e is AppUserError) rethrow;
      }
    }

    // Ciudad/depto: solo si faltan y ya hay coords (1 reverse, no Autocomplete).
    final needCity =
        city == null || city.trim().isEmpty || department == null;
    if (geocode && hasExactPin && lat != null && lng != null && needCity) {
      try {
        final place = await _geocoder.reverse(lat: lat, lng: lng);
        if (place != null) {
          city ??= place.city;
          department ??= place.department;
          address ??= place.addressLine ?? place.displayName;
          name ??= place.name;
        }
      } catch (_) {}
    }

    if (address == null || address.trim().isEmpty) {
      final parts = [
        if (city != null && city.trim().isNotEmpty) city.trim(),
        if (department != null && department.trim().isNotEmpty)
          department.trim(),
      ];
      if (parts.isNotEmpty) address = parts.join(', ');
    }

    var result = GoogleMapsImportResult(
      name: name,
      lat: lat,
      lng: lng,
      city: city,
      department: department,
      addressLine: address,
      resolvedUrl: resolved.toString(),
      hasExactPin: hasExactPin && lat != null && lng != null,
    )._withStaticMap();

    AppLog.debug(
      'maps import name=${result.name} hasCoords=${result.hasCoords} '
      'exact=${result.hasExactPin} google=${_places.isConfigured}',
      name: 'maps_import',
    );

    if (!result.hasAnything) {
      throw const AppUserError(
        'No se pudo leer ese enlace de Maps. Elige el punto en el mapa.',
      );
    }

    final asPlace = result.toGeoPlace();
    if (asPlace != null && result.hasExactPin) {
      await _cache.write(cacheKey, asPlace);
    }
    return result;
  }

  Future<Uri> _resolveFinalUrl(String raw) async {
    var uri = Uri.parse(raw);
    for (var i = 0; i < 8; i++) {
      final req = http.Request('GET', uri)
        ..followRedirects = false
        ..headers.addAll(_kHeaders);
      final streamed = await _http.send(req);
      final loc = streamed.headers['location'];
      try {
        await streamed.stream.drain<void>();
      } catch (_) {}

      if (streamed.statusCode >= 300 &&
          streamed.statusCode < 400 &&
          loc != null &&
          loc.isNotEmpty) {
        final next = parseRedirectLocation(uri, loc);
        if (next == null || next == uri) break;
        uri = next;
        // Si Location ya trae pin o feature-id, listo.
        final s = next.toString();
        if (extractExactPinCoords(s) != null || extractFeatureId(s) != null) {
          return next;
        }
        continue;
      }
      break;
    }
    return uri;
  }

  Future<String> _fetchBody(Uri uri) async {
    final res = await _http.get(uri, headers: _kHeaders);
    return res.body;
  }

  static Uri? parseRedirectLocation(Uri current, String loc) {
    var value = loc.trim();
    if (value.isEmpty) return null;
    if (value.startsWith('intent://')) {
      value = 'https://${value.substring('intent://'.length)}';
      value = value.split('#Intent').first;
    }
    if (value.startsWith('/maps') || value.startsWith('/maps/')) {
      return Uri.parse('https://www.google.com$value');
    }
    final parsed = Uri.tryParse(value);
    if (parsed == null) return null;
    if (parsed.hasScheme) return parsed;
    return current.resolveUri(parsed);
  }

  static Uri? _extractMapsUriFromHtml(String html) {
    if (html.isEmpty) return null;
    final canonical = RegExp(
      r'''rel=["']canonical["'][^>]*href=["']([^"']+)["']''',
      caseSensitive: false,
    ).firstMatch(html);
    final href = canonical?.group(1);
    if (href != null && looksLikeMapsUrl(href)) {
      return Uri.tryParse(href);
    }
    final og = RegExp(
      r'''property=["']og:url["'][^>]*content=["']([^"']+)["']''',
      caseSensitive: false,
    ).firstMatch(html);
    final ogUrl = og?.group(1);
    if (ogUrl != null && looksLikeMapsUrl(ogUrl)) {
      return Uri.tryParse(ogUrl);
    }
    final any = RegExp(
      r'''https://(?:www\.)?google\.[^/"'\s]+/maps/[^"'\s<>]+''',
      caseSensitive: false,
    ).firstMatch(html);
    if (any != null) return Uri.tryParse(any.group(0)!);
    return null;
  }

  static String? _extractTitleFromHtml(String html) {
    final og = RegExp(
      r'''property=["']og:title["'][^>]*content=["']([^"']+)["']''',
      caseSensitive: false,
    ).firstMatch(html);
    final t = og?.group(1)?.trim();
    if (t != null && t.isNotEmpty) return _stripMapsSuffix(t);
    final title = RegExp(
      r'<title[^>]*>([^<]+)</title>',
      caseSensitive: false,
    ).firstMatch(html);
    final raw = title?.group(1)?.trim();
    if (raw == null || raw.isEmpty) return null;
    return _stripMapsSuffix(raw);
  }

  static String _stripMapsSuffix(String raw) {
    return raw
        .replaceAll(
          RegExp(r'\s*[-–|].*Google Maps.*$', caseSensitive: false),
          '',
        )
        .trim();
  }

  static String? extractFeatureId(String raw) {
    final m = RegExp(
      r'1s(0x[0-9a-fA-F]+:0x[0-9a-fA-F]+)',
    ).firstMatch(raw);
    if (m != null) return m.group(1);
    final m2 = RegExp(
      r'(0x[0-9a-fA-F]+:0x[0-9a-fA-F]+)',
    ).firstMatch(raw);
    return m2?.group(1);
  }

  /// Centro del viewport `@lat,lng` (aproximado). Solo utilitario/tests.
  static (double, double)? extractViewportCoords(String raw) {
    if (raw.isEmpty) return null;
    String decoded;
    try {
      decoded = Uri.decodeFull(raw);
    } catch (_) {
      decoded = raw;
    }
    final m = RegExp(r'@(-?\d+\.\d+),(-?\d+\.\d+)').firstMatch(decoded);
    if (m == null) return null;
    final lat = double.tryParse(m.group(1)!);
    final lng = double.tryParse(m.group(2)!);
    if (!_validCoord(lat, lng)) return null;
    return (lat!, lng!);
  }

  static (double, double)? extractExactPinCoords(String raw) {
    if (raw.isEmpty) return null;
    String decoded;
    try {
      decoded = Uri.decodeFull(raw);
    } catch (_) {
      decoded = raw;
    }

    final m8 =
        RegExp(r'!8m2!3d(-?\d+\.\d+)!4d(-?\d+\.\d+)').firstMatch(decoded);
    if (m8 != null) {
      final lat = double.tryParse(m8.group(1)!);
      final lng = double.tryParse(m8.group(2)!);
      if (_validCoord(lat, lng)) return (lat!, lng!);
    }

    final m34 =
        RegExp(r'!3d(-?\d+\.\d+)!4d(-?\d+\.\d+)').firstMatch(decoded);
    if (m34 != null) {
      final lat = double.tryParse(m34.group(1)!);
      final lng = double.tryParse(m34.group(2)!);
      if (_validCoord(lat, lng)) return (lat!, lng!);
    }

    final m23 =
        RegExp(r'!2d(-?\d+\.\d+)!3d(-?\d+\.\d+)').firstMatch(decoded);
    if (m23 != null) {
      final lng = double.tryParse(m23.group(1)!);
      final lat = double.tryParse(m23.group(2)!);
      if (_validCoord(lat, lng)) return (lat!, lng!);
    }

    (double, double)? fallback;
    for (final m in RegExp(
      r'\[null,null,(-?\d+\.\d+),(-?\d+\.\d+)\]',
    ).allMatches(decoded)) {
      final lat = double.tryParse(m.group(1)!);
      final lng = double.tryParse(m.group(2)!);
      if (!_validCoord(lat, lng)) continue;
      if (_looksLikeColombia(lat!, lng!)) return (lat, lng);
      fallback ??= (lat, lng);
    }
    return fallback;
  }

  static bool _looksLikeColombia(double lat, double lng) {
    return lat >= -5 && lat <= 14 && lng >= -82 && lng <= -66;
  }

  static bool _validCoord(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    if (lat < -90 || lat > 90) return false;
    if (lng < -180 || lng > 180) return false;
    if (lat.abs() < 1e-6 && lng.abs() < 1e-6) return false;
    return true;
  }

  static GoogleMapsImportResult parseMapsUrl(Uri uri) {
    String? name;
    String? address;
    final pin = extractExactPinCoords(uri.toString());

    final placePath = RegExp(r'/place/([^/@]+)').firstMatch(uri.path);
    if (placePath != null) {
      name = _decodeName(placePath.group(1)!);
    }

    double? qLat;
    double? qLng;
    final q = uri.queryParameters['q'] ??
        uri.queryParameters['query'] ??
        uri.queryParameters['destination'];
    if (q != null && q.isNotEmpty) {
      final coords =
          RegExp(r'^(-?\d+\.?\d*)\s*,\s*(-?\d+\.?\d*)$').firstMatch(q);
      if (coords != null) {
        qLat = double.tryParse(coords.group(1)!);
        qLng = double.tryParse(coords.group(2)!);
      } else {
        name ??= q;
        address ??= q;
      }
    }

    if (name == null && uri.pathSegments.contains('place')) {
      final idx = uri.pathSegments.indexOf('place');
      if (idx >= 0 && idx + 1 < uri.pathSegments.length) {
        final seg = uri.pathSegments[idx + 1];
        if (!seg.startsWith('@') && !seg.startsWith('data=')) {
          name = _decodeName(seg);
        }
      }
    }

    if (pin != null) {
      return GoogleMapsImportResult(
        name: name,
        lat: pin.$1,
        lng: pin.$2,
        addressLine: address,
        hasExactPin: true,
      );
    }
    if (_validCoord(qLat, qLng)) {
      return GoogleMapsImportResult(
        name: name,
        lat: qLat,
        lng: qLng,
        addressLine: address,
        hasExactPin: true,
      );
    }
    return GoogleMapsImportResult(
      name: name,
      addressLine: address,
      hasExactPin: false,
    );
  }

  static String _decodeName(String raw) {
    try {
      return Uri.decodeComponent(raw.replaceAll('+', ' '))
          .split('/')
          .first
          .trim();
    } catch (_) {
      return raw.replaceAll('+', ' ').trim();
    }
  }
}

extension on GoogleMapsImportResult {
  GoogleMapsImportResult _withStaticMap() {
    if (staticMapUrl != null || lat == null || lng == null) return this;
    if (!Env.hasGeoapifyKey) return this;
    final key = Uri.encodeQueryComponent(Env.geoapifyApiKey);
    final url = 'https://maps.geoapify.com/v1/staticmap'
        '?style=osm-bright'
        '&width=800&height=500'
        '&center=lonlat:$lng,$lat'
        '&zoom=15'
        '&marker=lonlat:$lng,$lat;color:%23ffbb33;size:small'
        '&apiKey=$key';
    return GoogleMapsImportResult(
      name: name,
      lat: lat,
      lng: lng,
      city: city,
      department: department,
      addressLine: addressLine,
      staticMapUrl: url,
      resolvedUrl: resolvedUrl,
      hasExactPin: hasExactPin,
    );
  }
}
