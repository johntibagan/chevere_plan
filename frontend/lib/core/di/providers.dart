// Composition root (excepción a “core no importa features”):
// Riverpod registra repos aquí. Features no importan otras features vía core
// salvo este archivo. No usar GoRouter: ver docs/ui-navegacion.md.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/admin/data/admin_models.dart';
import '../../features/admin/data/admin_repository.dart';
import '../../features/geo/domain/geo_models.dart';
import '../../features/geo/data/geo_repository.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/data/profile_repository.dart';
import '../../features/moderation/data/moderation_repository.dart';
import '../../features/plans/data/plan_models.dart';
import '../../features/plans/data/plans_repository.dart';
import '../../features/proximity/data/geofence_sync_service.dart';
import '../../features/proximity/data/proximity_repository.dart';
import '../../features/routes/data/route_models.dart';
import '../../features/routes/data/routes_repository.dart';
import '../../features/saves/data/draft_reminder_service.dart';
import '../../features/saves/data/google_places_client.dart';
import '../../features/saves/data/place_geocoder.dart';
import '../../features/saves/data/save_models.dart';
import '../../features/saves/data/favorites_repository.dart';
import '../../features/saves/data/saves_repository.dart';
import '../../features/saves/data/site_ficha.dart';
import '../../features/saves/data/site_reviews_repository.dart';
import '../../features/home/data/device_location.dart';
import '../../features/home/data/home_nearby_snapshot.dart';
import '../../features/home/domain/home_nearby_policies.dart';
import '../../features/home/domain/home_sections_open.dart';
import '../../features/search/data/search_models.dart';
import '../../features/search/data/search_repository.dart';
import '../cache/cache_ttl.dart';
import '../cache/entity_cache_store.dart';
import '../cache/paged_items.dart';
import '../cache/swr_loader.dart';
import '../prefs/feed_layout.dart';

/// Cliente Supabase compartido (inyectable en tests).
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final entityCacheStoreProvider = Provider<EntityCacheStore>((ref) {
  return EntityCacheStore.instance;
});

final swrLoaderProvider = Provider<SwrLoader>((ref) {
  return SwrLoader(ref.watch(entityCacheStoreProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(client: ref.watch(supabaseClientProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(client: ref.watch(supabaseClientProvider));
});

final savesRepositoryProvider = Provider<SavesRepository>((ref) {
  return SavesRepository(client: ref.watch(supabaseClientProvider));
});

final coverSignedUrlProvider =
    FutureProvider.family<String?, String>((ref, path) async {
  final p = path.trim();
  if (p.isEmpty) return null;
  try {
    return await ref.watch(moderationRepositoryProvider).signedPhotoUrl(p);
  } catch (_) {
    return ref.watch(savesRepositoryProvider).signedPhotoUrl(p);
  }
});

final siteLookProvider =
    FutureProvider.family<SiteLook, String>((ref, siteId) async {
  final id = siteId.trim();
  if (id.isEmpty) return const SiteLook();
  final client = ref.watch(supabaseClientProvider);
  Map<String, dynamic> site = {};
  try {
    final raw = await client
        .from('sites')
        .select(
          'cover_photo_id, site_categories(categories(name_i18n))',
        )
        .eq('id', id)
        .maybeSingle();
    if (raw != null) site = Map<String, dynamic>.from(raw);
  } catch (_) {
    final raw = await client
        .from('sites')
        .select('site_categories(categories(name_i18n))')
        .eq('id', id)
        .maybeSingle();
    if (raw != null) site = Map<String, dynamic>.from(raw);
  }
  try {
    final photos = await client
        .from('site_photos')
        .select('id, storage_path, sort_order, created_at')
        .eq('site_id', id);
    site['site_photos'] = photos;
  } catch (_) {}
  return SiteLook.fromSiteMap(site);
});

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository(client: ref.watch(supabaseClientProvider));
});

final siteReviewsRepositoryProvider = Provider<SiteReviewsRepository>((ref) {
  return SiteReviewsRepository(client: ref.watch(supabaseClientProvider));
});

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(client: ref.watch(supabaseClientProvider));
});

final geoRepositoryProvider = Provider<GeoRepository>((ref) {
  return GeoRepository(client: ref.watch(supabaseClientProvider));
});

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepository(client: ref.watch(supabaseClientProvider));
});

final deviceLocationProvider = Provider<DeviceLocation>((ref) {
  return DeviceLocation();
});

final plansRepositoryProvider = Provider<PlansRepository>((ref) {
  return PlansRepository(client: ref.watch(supabaseClientProvider));
});

final routesRepositoryProvider = Provider<RoutesRepository>((ref) {
  return RoutesRepository(client: ref.watch(supabaseClientProvider));
});

final moderationRepositoryProvider = Provider<ModerationRepository>((ref) {
  return ModerationRepository(client: ref.watch(supabaseClientProvider));
});

final proximityRepositoryProvider = Provider<ProximityRepository>((ref) {
  return ProximityRepository(client: ref.watch(supabaseClientProvider));
});

final geofenceSyncServiceProvider = Provider<GeofenceSyncService>((ref) {
  return GeofenceSyncService(
    profileRepository: ref.watch(profileRepositoryProvider),
    proximityRepository: ref.watch(proximityRepositoryProvider),
  );
});

final googlePlacesClientProvider = Provider<GooglePlacesClient>((ref) {
  return GooglePlacesClient();
});

final placeGeocoderProvider = Provider<PlaceGeocoder>((ref) {
  return PlaceGeocoder(google: ref.watch(googlePlacesClientProvider));
});

/// Servicios singleton existentes (R1: se exponen vía Riverpod sin reescribirlos).
final draftReminderServiceProvider = Provider<DraftReminderService>((ref) {
  return DraftReminderService.instance;
});

// ---------------------------------------------------------------------------
// SWR providers (ciclo 1)
// ---------------------------------------------------------------------------

List<UserSave> _decodeSaves(Object? payload) {
  final list = payload as List? ?? const [];
  final out = <UserSave>[];
  for (final e in list) {
    if (e is! Map) continue;
    try {
      out.add(UserSave.fromCacheJson(Map<String, dynamic>.from(e)));
    } catch (_) {}
  }
  return out;
}

Object? _encodeSaves(List<UserSave> value) =>
    value.map((e) => e.toCacheJson()).toList();

List<Category> _decodeCategories(Object? payload) {
  final list = payload as List? ?? const [];
  return list
      .whereType<Map>()
      .map((e) => Category.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}

Object? _encodeCategories(List<Category> value) =>
    value.map((e) => e.toCacheJson()).toList();

List<TransportType> _decodeTransport(Object? payload) {
  final list = payload as List? ?? const [];
  return list
      .whereType<Map>()
      .map((e) => TransportType.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}

Object? _encodeTransport(List<TransportType> value) =>
    value.map((e) => e.toCacheJson()).toList();

SiteFicha _decodeFicha(Object? payload) {
  return SiteFicha.fromCacheJson(
    Map<String, dynamic>.from(payload as Map? ?? const {}),
  );
}

Object? _encodeFicha(SiteFicha value) => value.toCacheJson();

PagedItems<UserSave> _decodePagedSaves(Object? payload) {
  if (payload is List) {
    // Compat caché ciclo 1 (lista plana).
    final items = _decodeSaves(payload);
    return PagedItems(
      items: items,
      hasMore: items.length >= PagedItems.defaultPageSize,
    );
  }
  final map = Map<String, dynamic>.from(payload as Map? ?? const {});
  final items = _decodeSaves(map['items']);
  return PagedItems(
    items: items,
    hasMore: map['hasMore'] as bool? ?? false,
  );
}

Object? _encodePagedSaves(PagedItems<UserSave> value) => {
      'items': _encodeSaves(value.items),
      'hasMore': value.hasMore,
    };

PagedItems<Plan> _decodePagedPlans(Object? payload) {
  final map = Map<String, dynamic>.from(payload as Map? ?? const {});
  final list = map['items'] as List? ?? const [];
  final items = list
      .whereType<Map>()
      .map((e) => Plan.fromCacheJson(Map<String, dynamic>.from(e)))
      .toList();
  return PagedItems(
    items: items,
    hasMore: map['hasMore'] as bool? ?? false,
  );
}

Object? _encodePagedPlans(PagedItems<Plan> value) => {
      'items': value.items.map((e) => e.toCacheJson()).toList(),
      'hasMore': value.hasMore,
    };

List<RouteHistoryEntry> _decodeRoutes(Object? payload) {
  final list = payload as List? ?? const [];
  return list
      .whereType<Map>()
      .map((e) => RouteHistoryEntry.fromCacheJson(Map<String, dynamic>.from(e)))
      .toList();
}

Object? _encodeRoutes(List<RouteHistoryEntry> value) =>
    value.map((e) => e.toCacheJson()).toList();

class MySavesNotifier extends AsyncNotifier<PagedItems<UserSave>> {
  var _refreshing = false;
  static const _pageSize = PagedItems.defaultPageSize;

  @override
  Future<PagedItems<UserSave>> build() {
    return _loadPage0(forceNetwork: false);
  }

  Future<void> refresh({bool force = true}) async {
    state = await AsyncValue.guard(() => _loadPage0(forceNetwork: force));
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.loadingMore) return;
    state = AsyncData(current.copyWith(loadingMore: true));
    try {
      final next = await ref.read(savesRepositoryProvider).listMineSummary(
            limit: _pageSize,
            offset: current.items.length,
          );
      state = AsyncData(
        PagedItems(
          items: [...current.items, ...next],
          hasMore: next.length >= _pageSize,
        ),
      );
    } catch (_) {
      state = AsyncData(current.copyWith(loadingMore: false));
    }
  }

  Future<PagedItems<UserSave>> _loadPage0({required bool forceNetwork}) async {
    final uid = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (uid == null) {
      return const PagedItems(items: [], hasMore: false);
    }

    final swr = ref.read(swrLoaderProvider);
    return swr.load<PagedItems<UserSave>>(
      key: CacheKeys.mySavesSummary(uid),
      ttl: CacheTtl.mySaves,
      decode: _decodePagedSaves,
      encode: _encodePagedSaves,
      forceNetwork: forceNetwork,
      network: () async {
        final page = await ref.read(savesRepositoryProvider).listMineSummary(
              limit: _pageSize,
              offset: 0,
            );
        return PagedItems(
          items: page,
          hasMore: page.length >= _pageSize,
        );
      },
      onBackgroundRefresh: (pending) {
        if (_refreshing) return;
        _refreshing = true;
        unawaited(
          pending.then((fresh) {
            state = AsyncData(fresh);
          }).catchError((_) {}).whenComplete(() {
            _refreshing = false;
          }),
        );
      },
    );
  }
}

final mySavesProvider =
    AsyncNotifierProvider<MySavesNotifier, PagedItems<UserSave>>(
  MySavesNotifier.new,
);

class FavoriteSiteIdsNotifier extends AsyncNotifier<Set<String>> {
  var _refreshing = false;

  @override
  Future<Set<String>> build() => _load(forceNetwork: false);

  Future<void> toggle(String siteId) async {
    if (siteId.isEmpty) return;
    final current = {...(state.valueOrNull ?? {})};
    final adding = !current.contains(siteId);
    final next = {...current};
    if (adding) {
      next.add(siteId);
    } else {
      next.remove(siteId);
    }
    state = AsyncData(next);
    try {
      await ref.read(favoritesRepositoryProvider).setFavorite(
            siteId,
            favorite: adding,
          );
      final uid = ref.read(supabaseClientProvider).auth.currentUser?.id;
      if (uid != null) {
        await ref.read(entityCacheStoreProvider).write(
              CacheKeys.favoriteSiteIds(uid),
              next.toList(),
            );
      }
    } catch (e) {
      state = AsyncData(current);
      rethrow;
    }
  }

  Future<Set<String>> _load({required bool forceNetwork}) async {
    final uid = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (uid == null) return {};

    final swr = ref.read(swrLoaderProvider);
    return swr.load<Set<String>>(
      key: CacheKeys.favoriteSiteIds(uid),
      ttl: CacheTtl.favorites,
      decode: _decodeFavoriteIds,
      encode: (ids) => ids.toList(),
      forceNetwork: forceNetwork,
      network: () => ref.read(favoritesRepositoryProvider).listMine(),
      onBackgroundRefresh: (pending) {
        if (_refreshing) return;
        _refreshing = true;
        unawaited(
          pending.then((fresh) {
            state = AsyncData(fresh);
          }).catchError((_) {}).whenComplete(() {
            _refreshing = false;
          }),
        );
      },
    );
  }
}

Set<String> _decodeFavoriteIds(Object? payload) {
  if (payload is List) {
    return {for (final e in payload) e.toString()};
  }
  return {};
}

final favoriteSiteIdsProvider =
    AsyncNotifierProvider<FavoriteSiteIdsNotifier, Set<String>>(
  FavoriteSiteIdsNotifier.new,
);

class CategoriesNotifier extends AsyncNotifier<List<Category>> {
  var _refreshing = false;

  @override
  Future<List<Category>> build() => _load(forceNetwork: false);

  Future<void> refresh({bool force = true}) async {
    state = await AsyncValue.guard(() => _load(forceNetwork: force));
  }

  Future<List<Category>> _load({required bool forceNetwork}) {
    final swr = ref.read(swrLoaderProvider);
    return swr.load<List<Category>>(
      key: CacheKeys.categories(),
      ttl: CacheTtl.categories,
      decode: _decodeCategories,
      encode: _encodeCategories,
      forceNetwork: forceNetwork,
      network: () => ref.read(adminRepositoryProvider).fetchCategories(),
      onBackgroundRefresh: (pending) {
        if (_refreshing) return;
        _refreshing = true;
        unawaited(
          pending.then((fresh) {
            state = AsyncData(fresh);
          }).catchError((_) {}).whenComplete(() {
            _refreshing = false;
          }),
        );
      },
    );
  }
}

final categoriesProvider =
    AsyncNotifierProvider<CategoriesNotifier, List<Category>>(
  CategoriesNotifier.new,
);

class TransportTypesNotifier extends AsyncNotifier<List<TransportType>> {
  var _refreshing = false;

  @override
  Future<List<TransportType>> build() => _load(forceNetwork: false);

  Future<void> refresh({bool force = true}) async {
    state = await AsyncValue.guard(() => _load(forceNetwork: force));
  }

  Future<List<TransportType>> _load({required bool forceNetwork}) {
    final swr = ref.read(swrLoaderProvider);
    return swr.load<List<TransportType>>(
      key: CacheKeys.transportTypes(),
      ttl: CacheTtl.transportTypes,
      decode: _decodeTransport,
      encode: _encodeTransport,
      forceNetwork: forceNetwork,
      network: () => ref.read(adminRepositoryProvider).fetchTransportTypes(),
      onBackgroundRefresh: (pending) {
        if (_refreshing) return;
        _refreshing = true;
        unawaited(
          pending.then((fresh) {
            state = AsyncData(fresh);
          }).catchError((_) {}).whenComplete(() {
            _refreshing = false;
          }),
        );
      },
    );
  }
}

class GeoCatalogNotifier extends AsyncNotifier<GeoCatalog> {
  var _refreshing = false;

  @override
  Future<GeoCatalog> build() => _load(forceNetwork: false);

  Future<void> refresh({bool force = true}) async {
    state = await AsyncValue.guard(() => _load(forceNetwork: force));
  }

  Future<GeoCatalog> _load({required bool forceNetwork}) {
    final swr = ref.read(swrLoaderProvider);
    return swr.load<GeoCatalog>(
      key: CacheKeys.geoCatalog(),
      ttl: CacheTtl.geoCatalog,
      decode: GeoCatalog.fromJson,
      encode: (c) => c.toJson(),
      forceNetwork: forceNetwork,
      network: () => ref.read(geoRepositoryProvider).fetchCatalog(),
      onBackgroundRefresh: (pending) {
        if (_refreshing) return;
        _refreshing = true;
        unawaited(
          pending.then((fresh) {
            state = AsyncData(fresh);
          }).catchError((_) {}).whenComplete(() {
            _refreshing = false;
          }),
        );
      },
    );
  }
}

final geoCatalogProvider =
    AsyncNotifierProvider<GeoCatalogNotifier, GeoCatalog>(
  GeoCatalogNotifier.new,
);

final transportTypesProvider =
    AsyncNotifierProvider<TransportTypesNotifier, List<TransportType>>(
  TransportTypesNotifier.new,
);

class SiteFichaNotifier extends FamilyAsyncNotifier<SiteFicha, String> {
  var _refreshing = false;

  @override
  Future<SiteFicha> build(String siteId) {
    return _load(siteId, forceNetwork: false);
  }

  Future<void> refresh({bool force = true}) async {
    state = await AsyncValue.guard(
      () => _load(arg, forceNetwork: force),
    );
  }

  Future<SiteFicha> _load(String siteId, {required bool forceNetwork}) {
    final swr = ref.read(swrLoaderProvider);
    return swr.load<SiteFicha>(
      key: CacheKeys.siteFicha(siteId),
      ttl: CacheTtl.siteFicha,
      decode: _decodeFicha,
      encode: _encodeFicha,
      forceNetwork: forceNetwork,
      network: () => ref.read(savesRepositoryProvider).loadSiteFicha(siteId),
      onBackgroundRefresh: (pending) {
        if (_refreshing) return;
        _refreshing = true;
        unawaited(
          pending.then((fresh) {
            state = AsyncData(fresh);
          }).catchError((_) {}).whenComplete(() {
            _refreshing = false;
          }),
        );
      },
    );
  }
}

final siteFichaProvider =
    AsyncNotifierProvider.family<SiteFichaNotifier, SiteFicha, String>(
  SiteFichaNotifier.new,
);

class PlansNotifier extends AsyncNotifier<PagedItems<Plan>> {
  var _refreshing = false;
  static const _pageSize = PagedItems.defaultPageSize;

  @override
  Future<PagedItems<Plan>> build() => _loadPage0(forceNetwork: false);

  Future<void> refresh({bool force = true}) async {
    if (!state.hasValue) {
      state = const AsyncLoading();
    }
    state = await AsyncValue.guard(() => _loadPage0(forceNetwork: force));
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.loadingMore) return;
    state = AsyncData(current.copyWith(loadingMore: true));
    try {
      final next = await ref.read(plansRepositoryProvider).listMine(
            limit: _pageSize,
            offset: current.items.length,
          );
      state = AsyncData(
        PagedItems(
          items: [...current.items, ...next],
          hasMore: next.length >= _pageSize,
        ),
      );
    } catch (_) {
      state = AsyncData(current.copyWith(loadingMore: false));
    }
  }

  Future<PagedItems<Plan>> _loadPage0({required bool forceNetwork}) async {
    final uid = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (uid == null) {
      return const PagedItems(items: [], hasMore: false);
    }
    final swr = ref.read(swrLoaderProvider);
    return swr.load<PagedItems<Plan>>(
      key: CacheKeys.plansPage0(uid),
      ttl: CacheTtl.plans,
      decode: _decodePagedPlans,
      encode: _encodePagedPlans,
      forceNetwork: forceNetwork,
      network: () async {
        final page = await ref.read(plansRepositoryProvider).listMine(
              limit: _pageSize,
              offset: 0,
            );
        return PagedItems(items: page, hasMore: page.length >= _pageSize);
      },
      onBackgroundRefresh: (pending) {
        if (_refreshing) return;
        _refreshing = true;
        unawaited(
          pending.then((fresh) {
            state = AsyncData(fresh);
          }).catchError((_) {}).whenComplete(() {
            _refreshing = false;
          }),
        );
      },
    );
  }
}

final plansProvider =
    AsyncNotifierProvider<PlansNotifier, PagedItems<Plan>>(PlansNotifier.new);

/// Rutas: SWR de la lista completa (RPC ≤200); la UI pagina en cliente.
class RoutesNotifier extends AsyncNotifier<List<RouteHistoryEntry>> {
  var _refreshing = false;

  @override
  Future<List<RouteHistoryEntry>> build() => _load(forceNetwork: false);

  Future<void> refresh({bool force = true}) async {
    state = await AsyncValue.guard(() => _load(forceNetwork: force));
  }

  Future<List<RouteHistoryEntry>> _load({required bool forceNetwork}) async {
    final uid = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (uid == null) return const [];
    final swr = ref.read(swrLoaderProvider);
    return swr.load<List<RouteHistoryEntry>>(
      key: CacheKeys.routesAll(uid),
      ttl: CacheTtl.routes,
      decode: _decodeRoutes,
      encode: _encodeRoutes,
      forceNetwork: forceNetwork,
      network: () => ref.read(routesRepositoryProvider).listMineAll(),
      onBackgroundRefresh: (pending) {
        if (_refreshing) return;
        _refreshing = true;
        unawaited(
          pending.then((fresh) {
            state = AsyncData(fresh);
          }).catchError((_) {}).whenComplete(() {
            _refreshing = false;
          }),
        );
      },
    );
  }
}

final routesProvider =
    AsyncNotifierProvider<RoutesNotifier, List<RouteHistoryEntry>>(
  RoutesNotifier.new,
);

class HomeNearbyNotifier extends AsyncNotifier<HomeNearbySnapshot> {
  @override
  Future<HomeNearbySnapshot> build() => _load(forceNetwork: false);

  Future<void> refresh({bool force = false}) async {
    state = AsyncData(await _load(forceNetwork: force));
  }

  Future<HomeNearbySnapshot> _load({required bool forceNetwork}) async {
    final uid = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (uid == null) {
      return const HomeNearbySnapshot(hits: []);
    }

    final store = ref.read(entityCacheStoreProvider);
    final key = CacheKeys.homeNearby(uid);
    final cached = await store.read(key);
    HomeNearbySnapshot? disk;
    DateTime? fetchedAt;
    if (cached != null) {
      disk = HomeNearbySnapshot.fromCachePayload(cached.payload);
      fetchedAt = cached.fetchedAt;
      if (disk != null && disk.hits.isNotEmpty) {
        state = AsyncData(disk);
      }
    }

    if (!forceNetwork &&
        disk != null &&
        disk.originLat != null &&
        disk.originLng != null &&
        fetchedAt != null) {
      final age = DateTime.now().toUtc().difference(fetchedAt);
      if (age <= HomeNearbyPolicies.maxAge) {
        final loc = ref.read(deviceLocationProvider);
        final access = await loc.access();
        if (access == LocationAccess.denied) {
          return disk;
        }
        final last = await loc.lastKnown();
        if (last == null) {
          return disk;
        }
        if (HomeNearbyPolicies.stillInRange(
          originLat: disk.originLat!,
          originLng: disk.originLng!,
          lat: last.lat,
          lng: last.lng,
        )) {
          return disk;
        }
      }
    }

    return _fetchAndStore(
      key: key,
      store: store,
      fallback: disk,
    );
  }

  Future<HomeNearbySnapshot> _fetchAndStore({
    required String key,
    required EntityCacheStore store,
    required HomeNearbySnapshot? fallback,
  }) async {
    final loc = ref.read(deviceLocationProvider);
    final access = await loc.access(request: true);
    if (access == LocationAccess.denied) {
      return fallback ?? const HomeNearbySnapshot(hits: [], needGps: true);
    }

    GeoFix pos;
    try {
      pos = await loc.current();
    } catch (_) {
      final last = await loc.lastKnown();
      if (last == null) {
        return fallback ?? const HomeNearbySnapshot(hits: []);
      }
      pos = last;
    }

    if (fallback != null &&
        fallback.originLat != null &&
        fallback.originLng != null &&
        HomeNearbyPolicies.stillInRange(
          originLat: fallback.originLat!,
          originLng: fallback.originLng!,
          lat: pos.lat,
          lng: pos.lng,
        )) {
      final cached = await store.read(key);
      if (cached != null) {
        final age = DateTime.now().toUtc().difference(cached.fetchedAt);
        if (age <= HomeNearbyPolicies.maxAge) {
          return fallback;
        }
      }
    }

    try {
      final hits = await ref.read(searchRepositoryProvider).search(
            SearchFilters(
              includePublic: true,
              lat: pos.lat,
              lng: pos.lng,
              radiusKm: HomeNearbyPolicies.searchRadiusKm,
            ),
          );
      final snap = HomeNearbySnapshot(
        hits: hits
            .where((h) => h.isPublic)
            .take(HomeNearbyPolicies.take)
            .toList(),
        originLat: pos.lat,
        originLng: pos.lng,
      );
      await store.write(key, snap.toCacheJson());
      return snap;
    } catch (_) {
      return fallback ?? const HomeNearbySnapshot(hits: []);
    }
  }
}

final homeNearbyProvider =
    AsyncNotifierProvider<HomeNearbyNotifier, HomeNearbySnapshot>(
  HomeNearbyNotifier.new,
);

class FeedLayoutNotifier extends Notifier<FeedLayout> {
  static const _prefsKey = 'feed_layout';

  @override
  FeedLayout build() {
    Future.microtask(_hydrate);
    return FeedLayout.grid2;
  }

  Future<void> _hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    final next = FeedLayout.fromStorage(prefs.getString(_prefsKey));
    if (next != state) state = next;
  }

  Future<void> setLayout(FeedLayout layout) async {
    state = layout;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, layout.storageKey);
  }
}

final feedLayoutProvider =
    NotifierProvider<FeedLayoutNotifier, FeedLayout>(FeedLayoutNotifier.new);

class HomeSectionsOpenNotifier extends Notifier<HomeSectionsOpen> {
  static const _prefsKey = 'home_sections_open';

  @override
  HomeSectionsOpen build() {
    Future.microtask(_hydrate);
    return const HomeSectionsOpen();
  }

  Future<void> _hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    final next = HomeSectionsOpen.decode(prefs.getString(_prefsKey));
    if (next.encode() != state.encode()) state = next;
  }

  Future<void> setOpen(HomeSectionsOpen next) async {
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, next.encode());
  }
}

final homeSectionsOpenProvider =
    NotifierProvider<HomeSectionsOpenNotifier, HomeSectionsOpen>(
  HomeSectionsOpenNotifier.new,
);
