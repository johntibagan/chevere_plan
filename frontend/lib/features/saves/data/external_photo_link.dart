import 'package:http/http.dart' as http;

import '../../../core/errors/user_facing_error.dart';
import '../../../core/photos/external_photo_url.dart';
import 'share_parser.dart';

/// Valida que un texto sea una URL http(s) cuyo `Content-Type` es imagen.
class ExternalPhotoLinkValidator {
  ExternalPhotoLinkValidator({http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  static const _userAgent = 'CheverePlan/1.0 (catalog-photo-link)';
  static const _maxUrlChars = 2048;

  final http.Client _http;

  /// Extrae http(s) y comprueba que el servidor responde como imagen.
  Future<Uri> requireImageUrl(String raw) async {
    final extracted = ShareParser.parse(raw).url?.trim();
    if (extracted == null || extracted.isEmpty) {
      throw const AppUserError(
        'Ese texto no es un enlace http(s) válido.',
      );
    }
    if (extracted.length > _maxUrlChars) {
      throw const AppUserError(
        'Ese texto no es un enlace http(s) válido.',
      );
    }
    final uri = Uri.tryParse(extracted);
    if (uri == null || !uri.hasScheme || !isExternalPhotoUrl(extracted)) {
      throw const AppUserError(
        'Ese texto no es un enlace http(s) válido.',
      );
    }

    final ok = await _respondsAsImage(uri);
    if (!ok) {
      throw const AppUserError(
        'Ese enlace no es una imagen. Usa la URL directa del archivo (jpg, png, webp…).',
      );
    }
    return uri;
  }

  Future<bool> _respondsAsImage(Uri uri) async {
    try {
      if (await _probe('HEAD', uri)) return true;
      return _probe('GET', uri, range: true);
    } catch (_) {
      return false;
    }
  }

  Future<bool> _probe(String method, Uri uri, {bool range = false}) async {
    final req = http.Request(method, uri)
      ..followRedirects = true
      ..headers['User-Agent'] = _userAgent
      ..headers['Accept'] = 'image/*,*/*;q=0.8';
    if (range) {
      req.headers['Range'] = 'bytes=0-0';
    }
    final res = await _http.send(req).timeout(const Duration(seconds: 12));
    try {
      await res.stream.drain<void>();
    } catch (_) {}
    if (res.statusCode < 200 || res.statusCode >= 400) return false;
    return contentTypeLooksLikeImage(res.headers['content-type']);
  }
}
