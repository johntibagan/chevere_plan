import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Caché de imágenes acotada para equipos de gama media/baja (Colombia).
///
/// Disco: ~400 objetos, stale 14 días.
/// Memoria Flutter ImageCache: ~120 imágenes / 64 MB (ver [configurePaintingCache]).
///
/// Descarga con User-Agent identificable: hosts como Wikimedia rechazan el UA
/// por defecto de Dart (`Dart/… (dart:io)`) con 429/403.
class AppImageCacheManager extends CacheManager with ImageCacheManager {
  AppImageCacheManager._()
    : super(
        Config(
          key,
          stalePeriod: const Duration(days: 14),
          maxNrOfCacheObjects: 400,
          fileService: ChevereHttpFileService(),
        ),
      );

  /// v2: fuerza re-fetch tras UA (caché v1 pudo fallar ante 429 de Wikimedia).
  static const key = 'chevere_plan_images_v2';
  static final AppImageCacheManager instance = AppImageCacheManager._();

  /// User-Agent de todas las descargas de imagen (cards, ficha, prefetch).
  static const userAgent =
      'CheverePlan/1.0 (com.chevere.plan; +https://github.com/johntibagan/chevere_plan)';

  /// Limita el decode en memoria del motor Flutter (además de memCacheWidth).
  static void configurePaintingCache() {
    final cache = PaintingBinding.instance.imageCache;
    cache.maximumSize = 120;
    cache.maximumSizeBytes = 64 << 20; // 64 MiB
  }
}

/// [HttpFileService] que siempre envía [AppImageCacheManager.userAgent].
class ChevereHttpFileService extends HttpFileService {
  ChevereHttpFileService({super.httpClient});

  @override
  Future<FileServiceResponse> get(
    String url, {
    Map<String, String>? headers,
  }) {
    final merged = <String, String>{
      'Accept': 'image/*,*/*;q=0.8',
      ...?headers,
      // Después de [headers] para no dejar que un caller pise el UA.
      'User-Agent': AppImageCacheManager.userAgent,
    };
    return super.get(url, headers: merged);
  }
}
