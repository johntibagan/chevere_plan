import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/providers.dart';
import '../prefetch/site_prefetch.dart';
import 'app_image_cache.dart';
import 'entity_cache_store.dart';
import 'signed_url_cache.dart';

/// Limpia cachés de sesión para que otra cuenta no vea datos previos.
Future<void> clearSessionCaches({
  required void Function(ProviderOrFamily provider) invalidate,
  required T Function<T>(ProviderListenable<T> provider) read,
}) async {
  try {
    await EntityCacheStore.instance.clearAll();
  } catch (_) {}

  SignedUrlCache.instance.clear();

  try {
    await AppImageCacheManager.instance.emptyCache();
  } catch (_) {}

  try {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  } catch (_) {}

  try {
    read(sitePrefetchProvider).cancelPending();
  } catch (_) {}

  invalidate(mySavesProvider);
  invalidate(categoriesProvider);
  invalidate(geoCatalogProvider);
  invalidate(transportTypesProvider);
  invalidate(plansProvider);
  invalidate(routesProvider);
  invalidate(siteFichaProvider);
}
