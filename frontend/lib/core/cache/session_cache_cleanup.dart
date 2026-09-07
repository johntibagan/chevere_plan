import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/providers.dart';
import '../logging/crashlytics_service.dart';
import '../photos/wikimedia_session_widths.dart';
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
    await CrashlyticsService.instance.clearUserId();
  } catch (_) {}

  try {
    await EntityCacheStore.instance.clearAll();
  } catch (_) {}

  try {
    await SignedUrlCache.instance.clear();
  } catch (_) {}

  try {
    await AppImageCacheManager.instance.emptyCache();
  } catch (_) {}

  try {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  } catch (_) {}

  try {
    WikimediaSessionWidths.instance.clear();
  } catch (_) {}

  try {
    read(sitePrefetchProvider).cancelPending();
  } catch (_) {}

  try {
    await read(geofenceSyncServiceProvider).clearAll();
  } catch (_) {}

  invalidate(mySavesProvider);
  invalidate(homeNearbyProvider);
  invalidate(favoriteSiteIdsProvider);
  invalidate(categoriesProvider);
  invalidate(geoCatalogProvider);
  invalidate(transportTypesProvider);
  invalidate(distanceUnitsProvider);
  invalidate(plansProvider);
  invalidate(routesProvider);
  invalidate(siteFichaProvider);
}
