import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../cache/app_image_cache.dart';
import '../theme/app_theme.dart';

/// Decode en memoria: un solo eje, tope 2048 px (equipos de gama media).
enum AppImageQuality {
  /// Covers / avatares: tamaño en pantalla × DPR.
  standard,
  /// Tira de fotos: ~2× el alto visible, mínimo 720 px (nítido sin archivo original).
  photo,
  /// Visor a pantalla completa: lado largo de la pantalla, mínimo 1080 px.
  fullScreen,
}

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
    this.quality = AppImageQuality.standard,
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
  final AppImageQuality quality;

  static const _maxDecode = 2048;

  int _decodeSide(BuildContext context, double logical, {required int minPx}) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final scale = switch (quality) {
      AppImageQuality.photo => 2.0,
      AppImageQuality.fullScreen => 1.0,
      AppImageQuality.standard => 1.0,
    };
    return (logical * dpr * scale).round().clamp(minPx, _maxDecode);
  }

  int _screenLongSide(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return (size.longestSide * dpr).round().clamp(1080, _maxDecode);
  }

  @override
  Widget build(BuildContext context) {
    // Solo un eje de decode: ambos a la vez distorsionan la foto.
    final int? memW;
    final int? memH;
    if (quality == AppImageQuality.fullScreen) {
      memW = _screenLongSide(context);
      memH = null;
    } else if (fit == BoxFit.fitHeight && height != null) {
      memW = null;
      memH = _decodeSide(
        context,
        height!,
        minPx: quality == AppImageQuality.photo ? 720 : 32,
      );
    } else if (fit == BoxFit.fitWidth && width != null) {
      memW = _decodeSide(context, width!, minPx: 32);
      memH = null;
    } else if (width != null) {
      memW = _decodeSide(context, width!, minPx: 32);
      memH = null;
    } else if (height != null) {
      memW = null;
      memH = _decodeSide(
        context,
        height!,
        minPx: quality == AppImageQuality.photo ? 720 : 32,
      );
    } else {
      memW = _screenLongSide(context);
      memH = null;
    }

    final placeholderW = width ?? (height != null ? height! * 0.72 : null);
    final placeholder = SizedBox(
      width: placeholderW,
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
      filterQuality: quality == AppImageQuality.standard
          ? FilterQuality.low
          : FilterQuality.medium,
      placeholder: (context, _) => placeholder,
      errorWidget: (context, _, _) => SizedBox(
        width: placeholderW,
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
