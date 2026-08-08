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
}

class ShareParser {
  static final _urlRegex = RegExp(
    r'https?:\/\/[^\s<>"{}|\\^`\[\]]+',
    caseSensitive: false,
  );

  static ShareParseResult parse(String? shared) {
    if (shared == null || shared.trim().isEmpty) {
      return const ShareParseResult();
    }
    final text = shared.trim();
    final match = _urlRegex.firstMatch(text);
    final url = match?.group(0);
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
    return null;
  }
}
