import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Caché de imágenes acotada para equipos de gama media/baja (Colombia).
///
/// Disco: ~180 objetos, stale 14 días.
/// Memoria Flutter ImageCache: ~80 imágenes / 48 MB (ver [configurePaintingCache]).
class AppImageCacheManager extends CacheManager with ImageCacheManager {
  AppImageCacheManager._()
      : super(
          Config(
            key,
            stalePeriod: const Duration(days: 14),
            maxNrOfCacheObjects: 180,
          ),
        );

  static const key = 'chevere_plan_images_v1';
  static final AppImageCacheManager instance = AppImageCacheManager._();

  /// Limita el decode en memoria del motor Flutter (además de memCacheWidth).
  static void configurePaintingCache() {
    final cache = PaintingBinding.instance.imageCache;
    cache.maximumSize = 80;
    cache.maximumSizeBytes = 48 << 20; // 48 MiB
  }
}
