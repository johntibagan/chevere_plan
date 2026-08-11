import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/admin/data/admin_models.dart';
import '../../features/admin/data/admin_repository.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/data/profile_repository.dart';
import '../../features/moderation/data/moderation_repository.dart';
import '../../features/plans/data/plans_repository.dart';
import '../../features/proximity/data/geofence_sync_service.dart';
import '../../features/proximity/data/proximity_repository.dart';
import '../../features/routes/data/routes_repository.dart';
import '../../features/saves/data/draft_reminder_service.dart';
import '../../features/saves/data/place_geocoder.dart';
import '../../features/saves/data/save_models.dart';
import '../../features/saves/data/saves_repository.dart';
import '../../features/saves/data/site_ficha.dart';
import '../../features/search/data/search_repository.dart';
import '../cache/cache_ttl.dart';
import '../cache/entity_cache_store.dart';
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

final placeGeocoderProvider = Provider<PlaceGeocoder>((ref) {
  return PlaceGeocoder();
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

class MySavesNotifier extends AsyncNotifier<List<UserSave>> {
  var _refreshing = false;

  @override
  Future<List<UserSave>> build() {
    return _load(forceNetwork: false);
  }

  Future<void> refresh({bool force = true}) async {
    state = await AsyncValue.guard(() => _load(forceNetwork: force));
  }

  Future<List<UserSave>> _load({required bool forceNetwork}) async {
    final uid = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (uid == null) return const [];

    final swr = ref.read(swrLoaderProvider);
    return swr.load<List<UserSave>>(
      key: CacheKeys.mySavesSummary(uid),
      ttl: CacheTtl.mySaves,
      decode: _decodeSaves,
      encode: _encodeSaves,
      forceNetwork: forceNetwork,
      network: () => ref.read(savesRepositoryProvider).listMineSummary(),
      onBackgroundRefresh: (pending) {
        if (_refreshing) return;
        _refreshing = true;
        unawaited(
          pending.then((fresh) {
            state = AsyncData(fresh);
          }).catchError((_) {
            // Silencioso: se mantiene lo stale en UI.
          }).whenComplete(() {
            _refreshing = false;
          }),
        );
      },
    );
  }
}

final mySavesProvider =
    AsyncNotifierProvider<MySavesNotifier, List<UserSave>>(MySavesNotifier.new);

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
