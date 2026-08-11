import 'package:http/http.dart' as http;

/// Preview tipo “tarjeta” (Open Graph / Twitter cards).
class LinkPreview {
  const LinkPreview({
    required this.url,
    this.title,
    this.description,
    this.imageUrl,
    this.siteName,
  });

  final String url;
  final String? title;
  final String? description;
  final String? imageUrl;
  final String? siteName;
}

class LinkPreviewFetcher {
  LinkPreviewFetcher({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final Map<String, LinkPreview> _memory = {};

  Future<LinkPreview> fetch(String url) async {
    final normalized = url.trim();
    final cached = _memory[normalized];
    if (cached != null) return cached;

    try {
      final uri = Uri.parse(normalized);
      final res = await _client.get(
        uri,
        headers: {
          'User-Agent':
              'Mozilla/5.0 (compatible; CheverePlan/1.0; +https://chevere.plan)',
          'Accept': 'text/html,application/xhtml+xml',
        },
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode < 200 || res.statusCode >= 400) {
        return _fallback(normalized);
      }

      final html = res.body;
      final title = _meta(html, 'og:title') ??
          _meta(html, 'twitter:title') ??
          _titleTag(html);
      final description = _meta(html, 'og:description') ??
          _meta(html, 'twitter:description') ??
          _meta(html, 'description');
      var image = _meta(html, 'og:image') ?? _meta(html, 'twitter:image');
      if (image != null && image.startsWith('/')) {
        image = uri.resolve(image).toString();
      }
      final siteName = _meta(html, 'og:site_name') ?? uri.host;

      final preview = LinkPreview(
        url: normalized,
        title: title?.trim(),
        description: description?.trim(),
        imageUrl: image?.trim(),
        siteName: siteName.trim(),
      );
      _memory[normalized] = preview;
      return preview;
    } catch (_) {
      return _fallback(normalized);
    }
  }

  LinkPreview _fallback(String url) {
    final host = Uri.tryParse(url)?.host;
    final preview = LinkPreview(url: url, title: host ?? url, siteName: host);
    _memory[url] = preview;
    return preview;
  }

  static String? _meta(String html, String property) {
    final patterns = [
      RegExp(
        'property=["\']$property["\']\\s+content=["\']([^"\']+)["\']',
        caseSensitive: false,
      ),
      RegExp(
        'content=["\']([^"\']+)["\']\\s+property=["\']$property["\']',
        caseSensitive: false,
      ),
      RegExp(
        'name=["\']$property["\']\\s+content=["\']([^"\']+)["\']',
        caseSensitive: false,
      ),
      RegExp(
        'content=["\']([^"\']+)["\']\\s+name=["\']$property["\']',
        caseSensitive: false,
      ),
    ];
    for (final p in patterns) {
      final m = p.firstMatch(html);
      if (m != null) return _decodeHtml(m.group(1)!);
    }
    return null;
  }

  static String? _titleTag(String html) {
    final m = RegExp(
      r'<title[^>]*>([^<]*)</title>',
      caseSensitive: false,
    ).firstMatch(html);
    return m == null ? null : _decodeHtml(m.group(1)!);
  }

  static String _decodeHtml(String s) {
    return s
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .trim();
  }
}
