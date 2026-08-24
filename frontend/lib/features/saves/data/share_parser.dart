/// Heurística ligera para share sheet / pegado de URL (sin Places API).
class ShareParseResult {
  const ShareParseResult({
    this.url,
    this.network,
    this.suggestedName,
    this.rawText,
  });

  final String? url;
  final String? network;
  final String? suggestedName;
  final String? rawText;

  bool get hasNavigableContent =>
      (url != null && url!.isNotEmpty) ||
      (suggestedName != null && suggestedName!.trim().isNotEmpty) ||
      (rawText != null && rawText!.trim().isNotEmpty);
}

class ShareParser {
  /// Tope contra payloads enormes / share malicioso.
  static const int maxInputChars = 8192;

  static final _urlRegex = RegExp(
    r'https?:\/\/[^\s<>"{}|\\^`\[\]]+',
    caseSensitive: false,
  );

  static final _disallowedScheme = RegExp(
    r'^\s*(javascript|data|file|content|intent):',
    caseSensitive: false,
  );

  static ShareParseResult parse(String? shared) {
    if (shared == null || shared.trim().isEmpty) {
      return const ShareParseResult();
    }
    var text = shared.trim();
    if (text.length > maxInputChars) {
      text = text.substring(0, maxInputChars);
    }
    if (_disallowedScheme.hasMatch(text) && !_urlRegex.hasMatch(text)) {
      return const ShareParseResult();
    }
    final match = _urlRegex.firstMatch(text);
    var url = match?.group(0);
    if (url != null) {
      final uri = Uri.tryParse(url);
      final scheme = uri?.scheme.toLowerCase() ?? '';
      if (uri == null || (scheme != 'http' && scheme != 'https')) {
        url = null;
      }
    }
    if (url == null && _disallowedScheme.hasMatch(text)) {
      return const ShareParseResult();
    }
    final network = _detectNetwork(url ?? text);
    String? name;
    if (url != null) {
      final withoutUrl = text.replaceAll(url, '').trim();
      if (withoutUrl.isNotEmpty) {
        name = withoutUrl;
      }
    } else if (!text.startsWith('http')) {
      name = text.length > 80 ? '${text.substring(0, 80)}…' : text;
    }
    return ShareParseResult(
      url: url,
      network: network,
      suggestedName: name,
      rawText: text,
    );
  }

  static String? _detectNetwork(String value) {
    final v = value.toLowerCase();
    if (v.contains('instagram.com') || v.contains('instagr.am')) {
      return 'instagram';
    }
    if (v.contains('tiktok.com') || v.contains('vm.tiktok.com')) {
      return 'tiktok';
    }
    if (v.contains('facebook.com') || v.contains('fb.watch')) {
      return 'facebook';
    }
    if (v.contains('youtube.com') || v.contains('youtu.be')) {
      return 'youtube';
    }
    if (v.contains('google.com/maps') ||
        v.contains('maps.google.') ||
        v.contains('maps.app.goo.gl') ||
        v.contains('goo.gl/maps')) {
      return 'google_maps';
    }
    return null;
  }
}
