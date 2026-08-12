import 'package:http/http.dart' as http;

import '../../../core/config/env.dart';
import '../../../core/errors/user_facing_error.dart';
import '../../../core/logging/app_log.dart';
import 'place_geocoder.dart';
import 'geo_place.dart';
import 'google_places_client.dart';

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

  /// Mapa estático Geoapify (si hay coords + API key) como “imagen” del lugar.
  final String? staticMapUrl;
  final String? resolvedUrl;

  /// True si lat/lng vienen del pin del lugar (!3d!4d), no del viewport.
  final bool hasExactPin;

  bool get hasCoords => lat != null && lng != null;
  bool get hasAnything =>
      hasCoords ||
      (name != null && name!.trim().isNotEmpty) ||
      (addressLine != null && addressLine!.trim().isNotEmpty);
}

/// Detecta e importa datos desde enlaces de Google Maps / maps.app.goo.gl.
///
/// Prioridad de coordenadas (exactas del pin del lugar):
/// 1. `!8m2!3dLAT!4dLNG` / `!3dLAT!4dLNG`
/// 2. `!2dLNG!3dLAT`
/// 3. HTML de la página resuelta (mismos patrones)
/// 4. `q=lat,lng` explícito
///
/// Nunca usa el centro del viewport (`@lat,lng`) ni geocode por nombre
/// para inventar lat/lng (eso coloca el sitio en otro lado).
class GoogleMapsLinkImporter {
  GoogleMapsLinkImporter({
    PlaceGeocoder? geocoder,
    GooglePlacesClient? places,
    http.Client? httpClient,
    this.geocode = true,
  })  : _geocoder = geocoder ?? PlaceGeocoder(),
        _places = places ?? GooglePlacesClient(),
        _http = httpClient ?? http.Client();

  final PlaceGeocoder _geocoder;
  final GooglePlacesClient _places;
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

  /// Extrae la primera URL del texto (o el texto si ya es URL).
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
    String? htmlBody;

    // Siempre scrapear HTML: acortadores / consent / solo feature-id.
    try {
      final body = await _fetchBody(resolved);
      htmlBody = body;
      final fromHtml = _extractMapsUriFromHtml(body);
      if (fromHtml != null) {
        final again = parseMapsUrl(fromHtml);
        if (again.hasExactPin && !hasExactPin) {
          resolved = fromHtml;
          lat = again.lat;
          lng = again.lng;
          hasExactPin = true;
        }
        name ??= again.name;
        address ??= again.addressLine;
        // Si el canonical trae pin, también fetch de esa URL.
        if (!hasExactPin && again.hasExactPin == false) {
          try {
            final richer = await _fetchBody(fromHtml);
            htmlBody = '$body\n$richer';
            resolved = fromHtml;
          } catch (_) {}
        }
      }
      final scrape = htmlBody ?? body;
      final pin = extractExactPinCoords(scrape) ??
          extractExactPinCoords(resolved.toString());
      if (pin != null) {
        lat = pin.$1;
        lng = pin.$2;
        hasExactPin = true;
      }
      name ??= _extractTitleFromHtml(scrape);
    } catch (e, st) {
      AppLog.debug(
        'maps import html scrape failed',
        name: 'maps_import',
        error: e,
        stackTrace: st,
      );
    }

    // Feature-id (0x…:0x…): reintentar URLs de enriquecimiento.
    if (!hasExactPin) {
      final fid = extractFeatureId(resolved.toString()) ??
          (htmlBody == null ? null : extractFeatureId(htmlBody));
      if (fid != null) {
        for (final probe in _featureIdProbeUris(fid)) {
          try {
            final body = await _fetchBody(probe);
            final pin = extractExactPinCoords(body) ??
                extractExactPinCoords(probe.toString());
            if (pin != null) {
              lat = pin.$1;
              lng = pin.$2;
              hasExactPin = true;
              resolved = probe;
              name ??= _extractTitleFromHtml(body);
              break;
            }
            name ??= _extractTitleFromHtml(body);
          } catch (_) {}
        }
      }
    }

    // Google Places: place_id / CID → 1× Place Details (coords exactas).
    if (!hasExactPin && _places.isConfigured) {
      try {
          final blob = '$resolved${htmlBody ?? ''}';
        final chij = GooglePlacesClient.extractChijPlaceId(blob);
        GeoPlace? fromPlaces;
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
          'maps import places enrich failed',
          name: 'maps_import',
          error: e,
          stackTrace: st,
        );
        if (e is AppUserError) {
          // Cupo agotado: seguimos con fallbacks gratis.
        }
      }
    }

    // Geocode acotado por nombre (Colombia + similitud). Evita el “primer hit”.
    if (!hasExactPin &&
        geocode &&
        name != null &&
        name.trim().length >= 3) {
      final matched = await _resolveCoordsFromPlaceName(name.trim());
      if (matched != null) {
        lat = matched.$1;
        lng = matched.$2;
        // No marcamos exacto: el usuario puede afinar en el mapa.
        hasExactPin = false;
      }
    }

    // Viewport @lat,lng solo como último recurso (pin caído / centro cercano).
    if (lat == null || lng == null) {
      final view = extractViewportCoords(resolved.toString()) ??
          (htmlBody == null ? null : extractViewportCoords(htmlBody));
      if (view != null) {
        lat = view.$1;
        lng = view.$2;
        hasExactPin = false;
      }
    }

    // Reverse solo para ciudad/depto.
    if (geocode && lat != null && lng != null) {
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

    final result = GoogleMapsImportResult(
      name: name,
      lat: lat,
      lng: lng,
      city: city,
      department: department,
      addressLine: address,
      staticMapUrl: _staticMapUrl(lat: lat, lng: lng),
      resolvedUrl: resolved.toString(),
      hasExactPin: hasExactPin && lat != null && lng != null,
    );

    AppLog.debug(
      'maps import name=${result.name} hasCoords=${result.hasCoords} '
      'exact=${result.hasExactPin} lat=${result.lat} lng=${result.lng}',
      name: 'maps_import',
    );

    if (!result.hasAnything) {
      throw const AppUserError(
        'No se pudo leer ese enlace de Maps. Elige el punto en el mapa.',
      );
    }
    return result;
  }

  Future<(double, double)?> _resolveCoordsFromPlaceName(String name) async {
    try {
      final hits = await _geocoder.search('$name Colombia', limit: 5);
      final needle = _normalizeName(name);
      if (needle.isEmpty) return null;
      for (final h in hits) {
        final cand = _normalizeName(h.name ?? h.displayName ?? '');
        if (cand.isEmpty) continue;
        if (_namesLikelySame(needle, cand)) {
          return (h.lat, h.lng);
        }
      }
    } catch (_) {}
    return null;
  }

  static String _normalizeName(String raw) {
    var s = raw.toLowerCase().trim();
    const pairs = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ü': 'u',
      'ñ': 'n',
    };
    for (final e in pairs.entries) {
      s = s.replaceAll(e.key, e.value);
    }
    s = s.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s;
  }

  static bool _namesLikelySame(String a, String b) {
    if (a == b) return true;
    if (a.contains(b) || b.contains(a)) return true;
    final ta = a.split(' ').where((t) => t.length > 2).toSet();
    final tb = b.split(' ').where((t) => t.length > 2).toSet();
    if (ta.isEmpty || tb.isEmpty) return false;
    final inter = ta.intersection(tb).length;
    final ratio = inter / (ta.length < tb.length ? ta.length : tb.length);
    return ratio >= 0.6;
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

  static List<Uri> _featureIdProbeUris(String fid) {
    final cidHex = fid.split(':').last.replaceFirst('0x', '');
    final cid = int.tryParse(cidHex, radix: 16);
    return [
      Uri.parse('https://www.google.com/maps/place/data=!4m2!3m1!1s$fid'),
      Uri.parse('https://www.google.com/maps?ftid=$fid'),
      if (cid != null) Uri.parse('https://www.google.com/maps?cid=$cid'),
      if (cid != null)
        Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=cid:$cid',
        ),
    ];
  }

  /// Centro del viewport `@lat,lng` (aproximado).
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
        continue;
      }
      break;
    }

    if (_isShortener(uri)) {
      try {
        final res = await _http.get(uri, headers: _kHeaders);
        final finalUrl = res.request?.url;
        if (finalUrl != null) uri = finalUrl;
        final fromHtml = _extractMapsUriFromHtml(res.body);
        if (fromHtml != null) uri = fromHtml;
      } catch (_) {}
    }
    return uri;
  }

  Future<String> _fetchBody(Uri uri) async {
    final res = await _http.get(uri, headers: _kHeaders);
    return res.body;
  }

  static bool _isShortener(Uri uri) {
    final h = uri.host.toLowerCase();
    return h.contains('goo.gl') || h.contains('maps.app.goo');
  }

  /// Convierte Location (relativa, absoluta o intent://) a URI de Maps.
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
    if (t != null && t.isNotEmpty) {
      return _stripMapsSuffix(t);
    }
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

  /// Pin exacto del lugar. No usa `@lat,lng` (centro del mapa).
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

    // !2dLNG!3dLAT
    final m23 =
        RegExp(r'!2d(-?\d+\.\d+)!3d(-?\d+\.\d+)').firstMatch(decoded);
    if (m23 != null) {
      final lng = double.tryParse(m23.group(1)!);
      final lat = double.tryParse(m23.group(2)!);
      if (_validCoord(lat, lng)) return (lat!, lng!);
    }

    // Varias tuplas en el HTML: preferir bbox Colombia.
    (double, double)? fallback;
    for (final m in RegExp(
      r'\[null,null,(-?\d+\.\d+),(-?\d+\.\d+)\]',
    ).allMatches(decoded)) {
      final lat = double.tryParse(m.group(1)!);
      final lng = double.tryParse(m.group(2)!);
      if (!_validCoord(lat, lng)) continue;
      if (_looksLikeColombia(lat!, lng!)) {
        return (lat, lng);
      }
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

  /// Parseo puro de una URL ya resuelta (para tests).
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
      return Uri.decodeComponent(raw.replaceAll('+', ' ')).split('/').first.trim();
    } catch (_) {
      return raw.replaceAll('+', ' ').trim();
    }
  }

  String? _staticMapUrl({required double? lat, required double? lng}) {
    if (lat == null || lng == null) return null;
    if (!Env.hasGeoapifyKey) return null;
    final key = Uri.encodeQueryComponent(Env.geoapifyApiKey);
    return 'https://maps.geoapify.com/v1/staticmap'
        '?style=osm-bright'
        '&width=800&height=500'
        '&center=lonlat:$lng,$lat'
        '&zoom=15'
        '&marker=lonlat:$lng,$lat;color:%23ffbb33;size:small'
        '&apiKey=$key';
  }
}
