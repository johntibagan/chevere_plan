/// Reescribe URLs de Wikimedia Commons a un thumb del mismo host.
///
/// No toca Storage ni la fila en DB: solo la URL que pide el cliente al pintar.

/// Anchos típicos permitidos por upload.wikimedia.org para thumbs.
const kWikimediaThumbWidths = <int>[
  20,
  40,
  60,
  80,
  100,
  120,
  150,
  180,
  200,
  220,
  250,
  300,
  320,
  400,
  500,
  640,
  800,
  1024,
  1280,
  1920,
  2560,
];

/// Elige el ancho permitido ≥ [desired], o el máximo de la lista si [desired] es mayor.
int wikimediaClampThumbWidth(int desired) {
  final d = desired < 1 ? 500 : desired;
  for (final w in kWikimediaThumbWidths) {
    if (w >= d) return w;
  }
  return kWikimediaThumbWidths.last;
}

bool isWikimediaUploadUrl(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri == null || !uri.hasScheme) return false;
  return uri.host.toLowerCase() == 'upload.wikimedia.org';
}

/// Partes del path Commons: `(a, ab, file)` o null si no aplica.
({String a, String ab, String file})? _commonsFileParts(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri == null) return null;
  if (uri.host.toLowerCase() != 'upload.wikimedia.org') return null;

  final parts = uri.pathSegments.where((s) => s.isNotEmpty).toList();
  if (parts.length < 5) return null;
  if (parts[0] != 'wikipedia' || parts[1] != 'commons') return null;

  late final String a;
  late final String ab;
  late final String file;

  if (parts[2] == 'thumb') {
    if (parts.length < 6) return null;
    a = parts[3];
    ab = parts[4];
    file = parts[5];
  } else {
    a = parts[2];
    ab = parts[3];
    file = parts.sublist(4).join('/');
    if (a == 'thumb' || a == 'archive' || file.isEmpty) return null;
  }

  final lower = file.toLowerCase();
  if (lower.endsWith('.svg') || lower.endsWith('.svgz')) return null;
  return (a: a, ab: ab, file: file);
}

/// URL del archivo original (sin `/thumb/…/Npx-…`).
String wikimediaOriginalUrl(String url) {
  final parts = _commonsFileParts(url);
  if (parts == null) return url.trim();
  final uri = Uri.parse(url.trim());
  final path = '/wikipedia/commons/${parts.a}/${parts.ab}/${parts.file}';
  return uri.replace(path: path).toString();
}

/// Si [url] es Commons, thumb de [widthPx] px. Si no aplica, [url] sin cambios.
String wikimediaDisplayUrl(String url, {required int widthPx}) {
  final raw = url.trim();
  if (raw.isEmpty) return raw;
  final parts = _commonsFileParts(raw);
  if (parts == null) return raw;

  final width = wikimediaClampThumbWidth(widthPx);
  final thumbName = '${width}px-${parts.file}';
  final path =
      '/wikipedia/commons/thumb/${parts.a}/${parts.ab}/${parts.file}/$thumbName';
  return Uri.parse(raw).replace(path: path).toString();
}

/// Intentos de display: thumbs (ancho) y al final el original (`widthPx == null`).
///
/// - Lista/tira: preferido → siguientes anchos → 800/500 (suele estar en disco) → original.
/// - Pantalla completa: preferido → más grande (2560) → 1920 → 800/500 → original.
List<int?> wikimediaRetryWidths({
  required int preferredWidth,
  required bool fullScreen,
}) {
  final preferred = wikimediaClampThumbWidth(preferredWidth);
  final out = <int?>[];

  void add(int? w) {
    if (!out.contains(w)) out.add(w);
  }

  add(preferred);

  if (fullScreen) {
    add(kWikimediaThumbWidths.last); // 2560
    add(1920);
    add(1280);
  } else {
    final idx = kWikimediaThumbWidths.indexOf(preferred);
    if (idx >= 0) {
      if (idx + 1 < kWikimediaThumbWidths.length) {
        add(kWikimediaThumbWidths[idx + 1]);
      }
      if (idx + 2 < kWikimediaThumbWidths.length) {
        add(kWikimediaThumbWidths[idx + 2]);
      }
    }
  }

  // Tamaños típicos de card/tira: si ya cargaron, el cacheKey acierta en disco.
  for (final w in [800, 500]) {
    add(w);
  }

  add(null); // archivo original
  return out;
}

/// URL + cacheKey para un intento (`widthPx == null` → original).
({String displayUrl, String cacheKey, int? widthPx}) wikimediaAttempt({
  required String sourceUrl,
  required String? cacheKey,
  required int? widthPx,
}) {
  final base = (cacheKey == null || cacheKey.isEmpty) ? sourceUrl : cacheKey;
  if (widthPx == null) {
    final original = wikimediaOriginalUrl(sourceUrl);
    return (
      displayUrl: original,
      cacheKey: '$base@orig',
      widthPx: null,
    );
  }
  final display = wikimediaDisplayUrl(sourceUrl, widthPx: widthPx);
  final w = wikimediaClampThumbWidth(widthPx);
  return (
    displayUrl: display,
    cacheKey: display == sourceUrl ? base : '$base@w$w',
    widthPx: w,
  );
}

/// Sufijo de [cacheKey] cuando la URL de red es un thumb distinto del original.
String imageCacheKeyForDisplay({
  required String? cacheKey,
  required String sourceUrl,
  required String displayUrl,
  required int widthPx,
}) {
  return wikimediaAttempt(
    sourceUrl: sourceUrl,
    cacheKey: cacheKey,
    widthPx: widthPx,
  ).cacheKey;
}
