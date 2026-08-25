import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/widgets/site_cover.dart';
import '../../admin/data/admin_models.dart';

/// Portada de **un sitio**: igual en lista, grilla, ficha, planes y rutas.
///
/// La foto es la de encabezado (`cover_photo_id`, o la primera si no hay).
/// Las miniaturas de tarjetas y listas usan esa misma portada.
class SiteLookCover extends ConsumerWidget {
  const SiteLookCover({
    super.key,
    this.siteId,
    this.categoryNames = const [],
    this.coverStoragePath,
    this.imageUrl,
    this.categoryHint,
  });

  final String? siteId;
  final List<String> categoryNames;
  final String? coverStoragePath;
  final String? imageUrl;
  /// Solo al crear (aún no hay sitio).
  final String? categoryHint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cats = ref.watch(
      categoriesProvider.select((a) => a.valueOrNull ?? const <Category>[]),
    );
    var names = categoryNames;
    var path = coverStoragePath?.trim();
    if (path != null && path.isEmpty) path = null;

    final id = siteId?.trim();
    // Las cards siempre traen categoría; si no pedimos el look, nunca llega
    // la foto de portada y se queda la ilustración.
    if (id != null &&
        id.isNotEmpty &&
        (imageUrl == null || imageUrl!.trim().isEmpty)) {
      final look = ref.watch(siteLookProvider(id)).valueOrNull;
      if (look != null) {
        if (names.isEmpty) names = look.categoryNames;
        final lookPath = look.coverStoragePath?.trim();
        if (lookPath != null && lookPath.isNotEmpty) path = lookPath;
      }
    }

    final hint = names.isNotEmpty
        ? Category.parentNameEs(cats, names)
        : categoryHint;
    final signed = imageUrl?.trim().isNotEmpty == true
        ? imageUrl
        : (path == null
            ? null
            : ref.watch(coverSignedUrlProvider(path)).valueOrNull);

    return SiteCover(
      imageUrl: signed,
      cacheKey: path,
      categoryHint: hint,
    );
  }
}
