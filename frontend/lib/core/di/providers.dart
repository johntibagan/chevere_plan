import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/admin/data/admin_models.dart';
import '../../features/admin/data/admin_repository.dart';
import '../../features/geo/data/geo_models.dart';
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
import '../../features/saves/data/saves_repository.dart';
import '../../features/saves/data/site_ficha.dart';
import '../../features/search/data/search_repository.dart';
import '../cache/cache_ttl.dart';
import '../cache/entity_cache_store.dart';
import '../cache/paged_items.dart';
import '../cache/swr_loader.dart';

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

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(client: ref.watch(supabaseClientProvider));
});

final geoRepositoryProvider = Provider<GeoRepository>((ref) {
  return GeoRepository(client: ref.watch(supabaseClientProvider));
});

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepository(client: ref.watch(supabaseClientProvider));
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
  return list
      .whereType<Map>()
      .map((e) => UserSave.fromCacheJson(Map<String, dynamic>.from(e)))
      .toList();
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
