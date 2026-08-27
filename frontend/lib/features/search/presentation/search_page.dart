import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/cache/cache_ttl.dart';
import '../../../core/di/providers.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/prefetch/site_prefetch.dart';
import '../../../core/prefs/feed_layout.dart';
import '../../../core/testing/widget_keys.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_rebuild.dart';
import '../../../core/widgets/app_feed_layout_toggle.dart';
import '../../../core/widgets/app_retry_callout.dart';
import '../../../core/widgets/app_search_field.dart';
import '../../../core/widgets/app_select_chip.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/field_action_icon.dart';
import '../../../core/widgets/tab_screen_header.dart';
import '../../admin/data/admin_models.dart';
import '../../home/presentation/home_cards.dart';
import '../../proximity/domain/proximity_policies.dart';
import '../../saves/presentation/open_site_detail.dart';
import '../data/explore_radius_store.dart';
import '../data/search_models.dart';
import '../data/search_repository.dart';
import '../domain/search_policies.dart';
import 'explore_intent.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key, required this.repository});

  final SearchRepository repository;

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _queryCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _radiusCtrl = TextEditingController();

  bool _advanced = false;
  bool _categoryMulti = false;
  final Set<String> _categoryIds = {};
  bool _mySavesOnly = false;
  bool _favoritesOnly = false;
  bool _useMyLocation = false;
  double _radiusKm = SearchPolicies.minRadiusKm;
  bool _radiusReady = false;
  bool _loading = false;
  bool _loadingMore = false;
  bool _searchFailed = false;
  List<SearchHit> _hits = const [];
  bool _searched = false;
  bool _hasMore = false;
  int _offset = 0;
  /// Invalida respuestas de búsquedas anteriores (reset / nueva búsqueda).
  int _searchEpoch = 0;
  /// Invalida un `_applyIntent` viejo si llega otro atajo / reset.
  int _applyGen = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_bootstrapRadius());
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    _locationCtrl.dispose();
    _radiusCtrl.dispose();
    super.dispose();
  }

  void _syncRadiusField(double km) {
    final clamped = SearchPolicies.clampRadiusKm(km);
    _radiusKm = clamped;
    final unit = ref.read(preferredDistanceUnitProvider);
    final display = unit.kmToUnit(clamped);
    final digits = unit.displayFractionDigits;
    final text = digits == 0
        ? display.round().toString()
        : (display == display.roundToDouble()
            ? display.toStringAsFixed(0)
            : display.toStringAsFixed(digits));
    if (_radiusCtrl.text != text) {
      _radiusCtrl.text = text;
    }
  }

  Future<int> _proximityMeters() async {
    try {
      final profile = await ref.read(profileRepositoryProvider).fetchCurrent();
      final meters = profile?.proximityRadiusM;
      if (meters == null) return ProximityPolicies.defaultRadiusM;
      return ProximityPolicies.clampRadiusM(meters);
    } catch (_) {
      return ProximityPolicies.defaultRadiusM;
    }
  }

  Future<void> _bootstrapRadius() async {
    final m = await _proximityMeters();
    final km = await ExploreRadiusStore.resolveInitialKm(proximityRadiusM: m);
    if (!mounted) return;
    setState(() {
      _syncRadiusField(km);
      _radiusReady = true;
    });
    final pending = ref.read(exploreIntentProvider);
    if (pending != null) unawaited(_applyIntent(pending));
  }

  Future<(double?, double?)> _maybeLocation() async {
    if (!_useMyLocation) return (null, null);
    final loc = ref.read(deviceLocationProvider);
    // Last-known primero (rápido); si no hay, GPS low con timeout corto.
    final known = await loc.lastKnown();
    if (known != null) return (known.lat, known.lng);
    final fix = await loc.tryCurrent(
      accuracy: LocationAccuracy.low,
      timeLimit: const Duration(seconds: 3),
    );
    if (fix == null) return (null, null);
    return (fix.lat, fix.lng);
  }

  void _resetPaging() {
    _offset = 0;
    _hasMore = false;
  }

  /// null = inválido (toast); true = ok y actualizó [_radiusKm].
  bool _applyRadiusFromField({required bool showError}) {
    if (!_useMyLocation) return true;
    final unit = ref.read(preferredDistanceUnitProvider);
    final raw = _radiusCtrl.text.trim().replaceAll(',', '.');
    final parsed = double.tryParse(raw);
    final minDisplay = unit.kmToUnit(SearchPolicies.minRadiusKm);
    final maxDisplay = unit.kmToUnit(SearchPolicies.maxRadiusKm);
    if (parsed == null || parsed < minDisplay || parsed > maxDisplay) {
      if (showError && mounted) {
        final l10n = context.l10n;
        AppToast.show(
          context,
          l10n.searchRadiusInvalid(
            minDisplay.toStringAsFixed(unit.displayFractionDigits),
            maxDisplay.toStringAsFixed(unit.displayFractionDigits),
            unit.symbol,
          ),
          error: true,
        );
      }
      return false;
    }
    final clamped = SearchPolicies.clampRadiusKm(unit.unitToKm(parsed));
    _syncRadiusField(clamped);
    unawaited(ExploreRadiusStore.saveKm(clamped));
    return true;
  }

  SearchFilters _buildFilters({
    required double? lat,
    required double? lng,
    required int offset,
  }) {
    final text = _queryCtrl.text.trim();
    final locationExtra = _locationCtrl.text.trim();
    return SearchFilters(
      query: text.isEmpty ? null : text,
      categoryIds: _categoryIds.isEmpty ? null : _categoryIds.toList(),
      locationQuery:
          _advanced && locationExtra.isNotEmpty ? locationExtra : null,
      lat: _useMyLocation ? lat : null,
      lng: _useMyLocation ? lng : null,
      radiusKm: _useMyLocation ? _radiusKm : null,
      // Transporte / presupuesto: ocultos en UI Explorar (no funcionales aún).
      includePublic: !_mySavesOnly,
      favoritesOnly: _favoritesOnly,
      limit: SearchPolicies.pageSize,
      offset: offset,
    );
  }

  void _searchNow() {
    if (!_applyRadiusFromField(showError: true)) return;
    unawaited(_runSearch());
  }

  Future<void> _runSearch({bool forceNetwork = false}) async {
    final epoch = ++_searchEpoch;
    setState(() {
      _loading = true;
      _searched = true;
      _searchFailed = false;
      _hits = const [];
      _resetPaging();
    });

    try {
      final loc = await _maybeLocation();
      if (!mounted || epoch != _searchEpoch) return;
      final filters = _buildFilters(lat: loc.$1, lng: loc.$2, offset: 0);
      // Mis guardados / favoritos cambian seguido: no servir SWR stale.
      final mustFresh = forceNetwork || _mySavesOnly || _favoritesOnly;
      final page = await ref.read(swrLoaderProvider).load<SearchPageResult>(
            key: CacheKeys.search(filters.cacheKey),
            ttl: CacheTtl.search,
            forceNetwork: mustFresh,
            decode: (payload) {
              final map = payload is Map
                  ? Map<String, dynamic>.from(payload)
                  : <String, dynamic>{};
              final list = map['hits'] as List? ?? const [];
              final hits = list
                  .whereType<Map>()
                  .map(
                    (e) => SearchHit.fromJson(Map<String, dynamic>.from(e)),
                  )
                  .toList();
              return SearchPageResult(
                hits: hits,
                hasMore: map['hasMore'] as bool? ?? false,
              );
            },
            encode: (value) => {
              'hits': value.hits.map((e) => e.toJson()).toList(),
              'hasMore': value.hasMore,
            },
            network: () => widget.repository.searchPage(filters),
          );
      if (!mounted || epoch != _searchEpoch) return;
      setState(() {
        _hits = page.hits;
        _hasMore = page.hasMore;
        _offset = SearchPolicies.pageSize;
        _loading = false;
      });
      ref.read(sitePrefetchProvider).scheduleVisibleSites(
            page.hits.map((h) => h.siteId),
          );
    } catch (e, st) {
      if (!mounted || epoch != _searchEpoch) return;
      setState(() {
        _loading = false;
        _searchFailed = true;
      });
      AppToast.error(context, e, stackTrace: st, logContext: 'search');
    }
  }

  void _onOwnedListsChanged() {
    if (!_searched) return;
    if (!_mySavesOnly && !_favoritesOnly) return;
    if (_loading) return;
    unawaited(_runSearch(forceNetwork: true));
  }

  Future<void> _loadMore() async {
    if (_loading || _loadingMore || !_hasMore) return;
    final epoch = _searchEpoch;
    setState(() => _loadingMore = true);
    try {
      final loc = await _maybeLocation();
      if (!mounted || epoch != _searchEpoch) return;
      final filters = _buildFilters(
        lat: loc.$1,
        lng: loc.$2,
        offset: _offset,
      );
      final page = await widget.repository.searchPage(filters);
      if (!mounted || epoch != _searchEpoch) return;
      final known = _hits.map((h) => h.siteId).toSet();
      final appended = <SearchHit>[
        ..._hits,
        ...page.hits.where((h) => !known.contains(h.siteId)),
      ];
      setState(() {
        _hits = appended;
        _hasMore = page.hasMore;
        _offset += SearchPolicies.pageSize;
        _loadingMore = false;
      });
      ref.read(sitePrefetchProvider).scheduleVisibleSites(
            page.hits.map((h) => h.siteId),
          );
    } catch (e, st) {
      if (!mounted || epoch != _searchEpoch) return;
      setState(() => _loadingMore = false);
      AppToast.error(context, e, stackTrace: st, logContext: 'search_load_more');
    }
  }

  Future<void> _wipeActiveFilters({required bool clearPersistedRadius}) async {
    // Cancela resultados de cualquier búsqueda en curso.
    _searchEpoch++;
    _queryCtrl.clear();
    _locationCtrl.clear();
    if (clearPersistedRadius) {
      await ExploreRadiusStore.clearStored();
    }
    final m = await _proximityMeters();
    final km = clearPersistedRadius
        ? SearchPolicies.kmFromProximityMeters(m)
        : await ExploreRadiusStore.resolveInitialKm(proximityRadiusM: m);
    if (!mounted) return;
    setState(() {
      _categoryIds.clear();
      _categoryMulti = false;
      _mySavesOnly = false;
      _favoritesOnly = false;
      _useMyLocation = false;
      _syncRadiusField(km);
      _hits = const [];
      _searched = false;
      _searchFailed = false;
      _loading = false;
      _loadingMore = false;
      _resetPaging();
    });
  }

  Future<void> _resetAll() async {
    // Cancela atajo en curso y búsquedas.
    _applyGen++;
    await _wipeActiveFilters(clearPersistedRadius: true);
  }

  Future<void> _applyIntent(ExploreIntent intent) async {
    final myGen = ++_applyGen;
    // Cancela búsqueda actual al instante.
    _searchEpoch++;
    setState(() {
      _loading = false;
      _hits = const [];
      _searched = false;
      _searchFailed = false;
    });

    try {
      await _wipeActiveFilters(clearPersistedRadius: false);
      if (!mounted || myGen != _applyGen) return;

      final m = await _proximityMeters();
      if (!mounted || myGen != _applyGen) return;

      switch (intent.shortcut) {
        case ExploreShortcut.nearMe:
          final km = SearchPolicies.kmFromProximityMeters(m);
          setState(() {
            _useMyLocation = true;
            _syncRadiusField(km);
            _advanced = true;
          });
          break;
        case ExploreShortcut.mySaves:
          setState(() {
            _mySavesOnly = true;
            _advanced = true;
          });
          break;
        case ExploreShortcut.myFavorites:
          setState(() {
            _favoritesOnly = true;
            _advanced = true;
          });
          break;
        case ExploreShortcut.byCategory:
          setState(() {
            _advanced = false;
          });
          break;
      }
      final stillMine = ref.read(exploreIntentProvider);
      if (stillMine?.nonce == intent.nonce) {
        ref.read(exploreIntentProvider.notifier).clear();
      }
      if (!mounted || myGen != _applyGen) return;
      await _runSearch();
    } finally {
      // No tocar _applyGen: un atajo más nuevo ya tiene gen mayor.
    }
  }

  Future<void> _openHit(SearchHit h) async {
    final outcome = await openSiteDetail(
      context,
      hit: h,
      siteId: h.siteId,
    );
    if (outcome != SiteDetailOutcome.none && mounted) {
      await _runSearch();
    }
  }

  void _toggleCategory(String id) {
    setState(() {
      if (_categoryMulti) {
        if (_categoryIds.contains(id)) {
          _categoryIds.remove(id);
        } else {
          _categoryIds.add(id);
        }
      } else {
        // Selección única: re-tocar limpia; otra categoría reemplaza.
        if (_categoryIds.length == 1 && _categoryIds.contains(id)) {
          _categoryIds.clear();
        } else {
          _categoryIds
            ..clear()
            ..add(id);
        }
      }
    });
    _searchNow();
  }

  void _setCategoryMulti(bool enabled) {
    setState(() {
      _categoryMulti = enabled;
      if (!enabled && _categoryIds.length > 1) {
        final first = _categoryIds.first;
        _categoryIds
          ..clear()
          ..add(first);
      }
    });
    if (!enabled) _searchNow();
  }

  @override
  Widget build(BuildContext context) {
    ref.watchAppThemeMode();
    final l10n = context.l10n;
    ref.listen<ExploreIntent?>(exploreIntentProvider, (prev, next) {
      if (next == null) return;
      if (!_radiusReady) return;
      unawaited(_applyIntent(next));
    });
    ref.listen(favoriteSiteIdsProvider, (prev, next) {
      if (prev?.valueOrNull == next.valueOrNull) return;
      _onOwnedListsChanged();
    });
    ref.listen(mySavesProvider, (prev, next) {
      if (prev?.valueOrNull == next.valueOrNull) return;
      _onOwnedListsChanged();
    });

    final categories = ref.watch(
      categoriesProvider.select((a) => a.valueOrNull ?? const <Category>[]),
    );
    final roots = categories.where((c) => c.isRoot).toList();

    final layout = ref.watch(feedLayoutProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TabScreenHeader(title: l10n.searchTitle),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: AppSearchField(
                      key: WidgetKeys.searchQuery,
                      controller: _queryCtrl,
                      hint: l10n.searchHintPlace,
                      searchTooltip: l10n.actionSearch,
                      clearTooltip: l10n.actionClear,
                      onSearch: _searchNow,
                      loading: _loading,
                    ),
                  ),
                  SizedBox(width: 8),
                  AppSquareIconButton(
                    icon: Icons.filter_alt_off_rounded,
                    tooltip: l10n.searchResetFilters,
                    onTap: () => unawaited(_resetAll()),
                  ),
                  SizedBox(width: 8),
                  AppSquareIconButton(
                    icon: Icons.tune_rounded,
                    selected: _advanced,
                    tooltip: _advanced
                        ? l10n.searchSimple
                        : l10n.searchAdvanced,
                    onTap: () {
                      setState(() => _advanced = !_advanced);
                    },
                  ),
                ],
              ),
            ),
            if (_advanced)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Material(
                  color: AppColors.surface,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.searchAdvanced,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.mutedDark,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: 8),
                        AppSearchField(
                          controller: _locationCtrl,
                          hint: l10n.searchLabelLocationExtra,
                          searchTooltip: l10n.actionSearch,
                          clearTooltip: l10n.actionClear,
                          onSearch: _searchNow,
                          loading: _loading,
                        ),
                        SizedBox(height: 8),
                        // Transporte y presupuesto: no funcionales aún —
                        // ocultos; SearchFilters los conserva.
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 3,
                              child: _CompactFilterToggle(
                                label: l10n.searchUseMyLocation,
                                value: _useMyLocation,
                                onChanged: (v) {
                                  setState(() {
                                    _useMyLocation = v;
                                    if (v) _syncRadiusField(_radiusKm);
                                  });
                                  _searchNow();
                                },
                              ),
                            ),
                            if (_useMyLocation) ...[
                              SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: ValueListenableBuilder<TextEditingValue>(
                                  valueListenable: _radiusCtrl,
                                  builder: (context, value, _) {
                                    final hasText = value.text.isNotEmpty;
                                    return TextField(
                                      controller: _radiusCtrl,
                                      keyboardType: const TextInputType
                                          .numberWithOptions(decimal: true),
                                      textInputAction: TextInputAction.search,
                                      onSubmitted: (_) => _searchNow(),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.foreground,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: l10n.searchRadiusLabel(
                                          ref
                                              .watch(
                                                preferredDistanceUnitProvider,
                                              )
                                              .symbol,
                                        ),
                                        isDense: true,
                                        filled: true,
                                        fillColor: AppColors.background,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 10,
                                        ),
                                        prefixIconConstraints:
                                            const BoxConstraints(
                                          minWidth: 40,
                                          minHeight: 40,
                                        ),
                                        suffixIconConstraints:
                                            const BoxConstraints(
                                          minWidth: 40,
                                          minHeight: 40,
                                        ),
                                        prefixIcon: FieldActionIcon(
                                          icon: Icons.search_rounded,
                                          tooltip: l10n.actionSearch,
                                          loading: _loading,
                                          onPressed:
                                              _loading ? null : _searchNow,
                                        ),
                                        suffixIcon: hasText
                                            ? IconButton(
                                                tooltip: l10n.actionClear,
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(
                                                  minWidth: 40,
                                                  minHeight: 40,
                                                ),
                                                icon: Icon(
                                                  Icons.cancel_rounded,
                                                  size: 18,
                                                  color: AppColors.muted,
                                                ),
                                                onPressed: () {
                                                  _radiusCtrl.clear();
                                                },
                                              )
                                            : null,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: AppColors.border,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: AppColors.border,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _CompactFilterToggle(
                                label: l10n.searchMySavesOnly,
                                value: _mySavesOnly,
                                onChanged: (v) {
                                  setState(() => _mySavesOnly = v);
                                  _searchNow();
                                },
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: _CompactFilterToggle(
                                label: l10n.searchMyFavoritesOnly,
                                value: _favoritesOnly,
                                onChanged: (v) {
                                  setState(() => _favoritesOnly = v);
                                  _searchNow();
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 8, 4),
              child: Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _categoryMulti,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      onChanged: (v) => _setCategoryMulti(v ?? false),
                    ),
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _setCategoryMulti(!_categoryMulti),
                      child: Text(
                        l10n.searchCategoryMulti,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mutedDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                children: [
                  AppSelectChip(
                    label: l10n.searchChipAll,
                    selected: _categoryIds.isEmpty,
                    filledPrimary: true,
                    showCheckWhenSelected: true,
                    onTap: () {
                      if (_categoryIds.isEmpty) return;
                      setState(() => _categoryIds.clear());
                      _searchNow();
                    },
                  ),
                  ...roots.map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: AppSelectChip(
                        label: r.nameEs,
                        selected: _categoryIds.contains(r.id),
                        showCheckWhenSelected: true,
                        accent: homeCategoryTint(r.nameEs),
                        onTap: () => _toggleCategory(r.id),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_searched)
              Material(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.searchResultsCount(_hits.length),
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.mutedDark,
                          ),
                        ),
                      ),
                      AppFeedLayoutToggle(
                        value: layout,
                        onChanged: (v) =>
                            ref.read(feedLayoutProvider.notifier).setLayout(v),
                        listTooltip: l10n.feedLayoutList,
                        grid2Tooltip: l10n.feedLayoutGrid2,
                        grid3Tooltip: l10n.feedLayoutGrid3,
                        grid4Tooltip: l10n.feedLayoutGrid4,
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: CustomScrollView(
                scrollCacheExtent: const ScrollCacheExtent.pixels(480),
                physics: const ClampingScrollPhysics(),
                slivers: [
                  if (!_searched)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                        child: Text(l10n.searchEmptyHint),
                      ),
                    )
                  else if (_searchFailed)
                    SliverToBoxAdapter(
                      child: AppRetryCallout(onRetry: _runSearch),
                    )
                  else if (_loading && _hits.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    )
                  else if (_hits.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                        child: Text(l10n.searchNoResults),
                      ),
                    )
                  else if (!layout.isList)
                    Builder(
                      builder: (context) {
                        final screenW = MediaQuery.sizeOf(context).width;
                        final ratio = layout.childAspectRatioForWidth(
                          screenW,
                          horizontalPadding: 32,
                          crossAxisSpacing: 12,
                        );
                        return SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          sliver: SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: layout.crossAxisCount,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: ratio,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final h = _hits[index];
                                return RepaintBoundary(
                                  child: HomePopularCard(
                                    key: ValueKey<String>(h.siteId),
                                    hit: h,
                                    onTap: () => _openHit(h),
                                    showPlaceOnCover:
                                        layout != FeedLayout.grid4,
                                  ),
                                );
                              },
                              childCount: _hits.length,
                              addAutomaticKeepAlives: false,
                            ),
                          ),
                        );
                      },
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final h = _hits[index];
                            return RepaintBoundary(
                              child: HomeSearchListCard(
                                key: ValueKey<String>(h.siteId),
                                hit: h,
                                onTap: () => _openHit(h),
                              ),
                            );
                          },
                          childCount: _hits.length,
                          addAutomaticKeepAlives: false,
                        ),
                      ),
                    ),
                  if (_searched && _hasMore)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        child: TextButton(
                          onPressed: (_loading || _loadingMore)
                              ? null
                              : () => unawaited(_loadMore()),
                          child: _loadingMore
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(l10n.actionLoadMore),
                        ),
                      ),
                    )
                  else
                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Switch denso en fila (panel avanzado compacto).
class _CompactFilterToggle extends StatelessWidget {
  const _CompactFilterToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.foreground,
                    height: 1.2,
                  ),
                ),
              ),
              Transform.scale(
                scale: 0.85,
                child: Switch.adaptive(
                  value: value,
                  onChanged: onChanged,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
