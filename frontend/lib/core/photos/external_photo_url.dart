/// Distingue una URL http(s) de una ruta interna de Storage (`userId/siteId/uuid.jpg`).
bool isExternalPhotoUrl(String? value) {
  final p = (value ?? '').trim();
  if (p.isEmpty) return false;
  final lower = p.toLowerCase();
  return lower.startsWith('https://') || lower.startsWith('http://');
}

/// Ruta o URL que hay que mostrar: enlace externo gana sobre Storage.
String? photoDisplayRef({String? storagePath, String? externalUrl}) {
  final ext = externalUrl?.trim();
  if (ext != null && ext.isNotEmpty) return ext;
  final path = storagePath?.trim();
  if (path != null && path.isNotEmpty) return path;
  return null;
}

/// `Content-Type` de respuesta HTTP: imagen si el tipo MIME empieza por `image/`.
bool contentTypeLooksLikeImage(String? raw) {
  final ct = (raw ?? '').split(';').first.trim().toLowerCase();
  return ct.startsWith('image/');
}
