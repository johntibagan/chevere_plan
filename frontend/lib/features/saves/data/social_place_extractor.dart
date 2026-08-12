import 'dart:convert';

import 'package:http/http.dart' as http;

import 'link_preview_fetcher.dart';
import 'share_parser.dart';

/// Pistas extraídas de un enlace social (OG / oEmbed). No reemplaza Maps.
class SocialPlaceHint {
  const SocialPlaceHint({
    required this.url,
    this.network,
    this.title,
    this.description,
    this.imageUrl,
    this.authorName,
    this.suggestedPlaceName,
  });

  final String url;
  final String? network;
  final String? title;
  final String? description;
  final String? imageUrl;
  final String? authorName;

  /// Nombre usable para el sitio (caption limpio), o null si es genérico.
  final String? suggestedPlaceName;

  String get haystack => [
        suggestedPlaceName,
        title,
        description,
        authorName,
      ].whereType<String>().join(' ');
}

/// Extrae título/caption/thumb de TikTok, YouTube, IG/FB (OG) en segundo plano.
///
/// Límites reales:
/// - TikTok / YouTube: oEmbed público (título, autor, thumb). Casi nunca coords.
/// - Instagram / Facebook: OG a menudo bloqueado o genérico; Graph/oEmbed de
///   Meta exige app y ToS que prohíben minería de metadatos.
/// - La ubicación hay que inferirla del texto (keywords) o pedirla al usuario.
class SocialPlaceExtractor {
  SocialPlaceExtractor({
    http.Client? httpClient,
    LinkPreviewFetcher? previewFetcher,
  })  : _http = httpClient ?? http.Client(),
        _preview = previewFetcher ?? LinkPreviewFetcher();

  final http.Client _http;
  final LinkPreviewFetcher _preview;

  static const _genericTitles = {
    'tiktok',
    'tiktok - make your day',
    'instagram',
    'facebook',
    'facebook watch',
    'youtube',
    'watch',
    'reels',
  };

  Future<SocialPlaceHint> extract(String rawUrl) async {
    final url = rawUrl.trim();
    final network = ShareParser.parse(url).network;
    LinkPreview? og;
    try {
      og = await _preview.fetch(url);
    } catch (_) {}

    Map<String, dynamic>? oembed;
    if (network == 'tiktok') {
      oembed = await _fetchOembed(
        Uri.https('www.tiktok.com', '/oembed', {'url': url}),
      );
    } else if (network == 'youtube') {
      oembed = await _fetchOembed(
        Uri.https('www.youtube.com', '/oembed', {
          'url': url,
          'format': 'json',
        }),
      );
    }

    final title = _firstNonEmpty([
      oembed?['title'] as String?,
      og?.title,
    ]);
    final description = _firstNonEmpty([
      og?.description,
    ]);
    final image = _firstNonEmpty([
      oembed?['thumbnail_url'] as String?,
      og?.imageUrl,
    ]);
    final author = _firstNonEmpty([
      oembed?['author_name'] as String?,
    ]);

    return SocialPlaceHint(
      url: url,
      network: network ?? og?.siteName,
      title: title,
      description: description,
      imageUrl: image,
      authorName: author,
      suggestedPlaceName: suggestedPlaceName(
        title: title,
        description: description,
        authorName: author,
        network: network,
      ),
    );
  }

  /// Nombre candidato si el caption no parece ruido de red social.
  static String? suggestedPlaceName({
    String? title,
    String? description,
    String? authorName,
    String? network,
  }) {
    final cleaned = _cleanCaption(title ?? '');
    if (_isUsablePlaceText(cleaned, network: network)) return cleaned;

    final desc = _cleanCaption(description ?? '');
    if (_isUsablePlaceText(desc, network: network)) {
      return desc.length > 80 ? '${desc.substring(0, 80).trim()}…' : desc;
    }
    return null;
  }

  Future<Map<String, dynamic>?> _fetchOembed(Uri uri) async {
    try {
      final res = await _http.get(
        uri,
        headers: const {
          'Accept': 'application/json',
          'User-Agent':
              'Mozilla/5.0 (compatible; CheverePlan/1.0; +https://chevere.plan)',
        },
      ).timeout(const Duration(seconds: 8));
      if (res.statusCode < 200 || res.statusCode >= 400) return null;
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return null;
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final v in values) {
      if (v != null && v.trim().isNotEmpty) return v.trim();
    }
    return null;
  }

  static String _cleanCaption(String raw) {
    var s = raw.trim();
    if (s.isEmpty) return '';
    s = s.replaceAll(RegExp(r'#\w+'), ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s;
  }

  static bool _isUsablePlaceText(String text, {String? network}) {
    if (text.length < 3) return false;
    final lower = text.toLowerCase();
    if (_genericTitles.contains(lower)) return false;
    if (network != null && lower == network) return false;
    // Captions típicos de FYP / ruido.
    if (lower.contains('foryou') || lower.contains('fyp')) return false;
    return true;
  }
}
