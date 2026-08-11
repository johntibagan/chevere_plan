import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../cache/app_image_cache.dart';
import '../theme/app_theme.dart';

/// Imagen de red con caché en disco/memoria (límites vía [AppImageCacheManager]).
///
/// Usa [cacheKey] estable (p. ej. id de foto / storage_path) para que al
/// renovar la URL firmada no se descargue de nuevo el mismo archivo.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.cacheKey,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.showLoadingIndicator = false,
  });

  final String url;
  /// Clave estable de caché (recomendado: `photo.id` o `storage_path`).
  final String? cacheKey;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  /// Si false (default), placeholder es un bloque de color (más liviano).
  final bool showLoadingIndicator;

  int? _decodePx(BuildContext context, double? logical, {required int fallback}) {
    final dpr = MediaQuery.devicePixelRatioOf(context).clamp(1.0, 2.5);
    if (logical != null && logical.isFinite && logical > 0) {
      return (logical * dpr).round().clamp(32, 1200);
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    // Sin width explícito: decodificar como máx. ~400 lógico (galerías full-bleed).
    final memW = _decodePx(context, width, fallback: 400);
    final memH = height != null
        ? _decodePx(context, height, fallback: 400)
        : null;

    final placeholder = SizedBox(
      width: width,
      height: height,
      child: ColoredBox(
        color: AppColors.surfaceElevated,
        child: showLoadingIndicator
            ? const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : null,
      ),
    );

    final image = CachedNetworkImage(
      imageUrl: url,
      cacheKey: cacheKey,
      cacheManager: AppImageCacheManager.instance,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 120),
      memCacheWidth: memW,
      memCacheHeight: memH,
      placeholder: (context, _) => placeholder,
      errorWidget: (context, _, _) => SizedBox(
        width: width,
        height: height,
        child: const ColoredBox(
          color: AppColors.surfaceElevated,
          child: Icon(Icons.broken_image, color: AppColors.muted),
        ),
      ),
    );

    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}
