import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Caché de imágenes acotada para equipos de gama media/baja (Colombia).
///
/// Disco: ~400 objetos, stale 14 días.
/// Memoria Flutter ImageCache: ~120 imágenes / 64 MB (ver [configurePaintingCache]).
class AppImageCacheManager extends CacheManager with ImageCacheManager {
  AppImageCacheManager._()
      : super(
          Config(
            key,
            stalePeriod: const Duration(days: 14),
            maxNrOfCacheObjects: 400,
          ),
        );

  static const key = 'chevere_plan_images_v1';
  static final AppImageCacheManager instance = AppImageCacheManager._();

  /// Limita el decode en memoria del motor Flutter (además de memCacheWidth).
  static void configurePaintingCache() {
    final cache = PaintingBinding.instance.imageCache;
    cache.maximumSize = 120;
    cache.maximumSizeBytes = 64 << 20; // 64 MiB
  }
}
