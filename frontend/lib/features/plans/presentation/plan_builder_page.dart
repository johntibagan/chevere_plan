import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/cache_ttl.dart';
import '../../../core/cache/paged_items.dart';
import '../../../core/di/providers.dart';
import '../../../core/testing/widget_keys.dart';
import '../../../core/formatters/money_format.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_form_card.dart';
import '../../../core/widgets/app_search_field.dart';
import '../../../core/widgets/app_select_chip.dart';
import '../../../core/widgets/app_toast.dart';
import '../../admin/data/admin_models.dart';
import '../../saves/presentation/open_site_detail.dart';
import '../../saves/presentation/site_look_cover.dart';
import '../../search/data/search_models.dart';
import '../data/plan_models.dart';
import '../data/plans_repository.dart';
import 'plan_timeline.dart';

enum _PlanBuilderTab { search, results, added }

/// Paso 2: buscar sitios, ver resultados y armar la línea de tiempo.
class PlanBuilderPage extends ConsumerStatefulWidget {
  const PlanBuilderPage({
    super.key,
    required this.planId,
    required this.repository,
  });

  final String planId;
  final PlansRepository repository;

  @override
  ConsumerState<PlanBuilderPage> createState() => _PlanBuilderPageState();
}

class _PlanBuilderPageState extends ConsumerState<PlanBuilderPage> {
  Plan? _plan;
  bool _loadingPlan = true;
  _PlanBuilderTab _tab = _PlanBuilderTab.search;

  final _queryCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _radiusCtrl = TextEditingController(text: '10');
  final _budgetMinCtrl = TextEditingController();
  final _budgetMaxCtrl = TextEditingController();

  bool _advanced = false;
  String? _categoryId;
  String? _transportGroup;
  bool _includePublic = true;
  bool _useMyLocation = false;
  bool _searching = false;
  bool _mutating = false;
  List<SearchHit> _hits = const [];
  bool _searched = false;
  int _visibleCount = PagedItems.defaultPageSize;

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    _locationCtrl.dispose();
    _radiusCtrl.dispose();
    _budgetMinCtrl.dispose();
    _budgetMaxCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPlan() async {
    setState(() => _loadingPlan = true);
    try {
      final plan = await widget.repository.fetchById(widget.planId);
      if (!mounted) return;
      setState(() {
        _plan = plan;
        _loadingPlan = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingPlan = false);
      AppToast.error(context, e, logContext: 'plan_builder_load');
    }
  }

  Future<void> _invalidatePlansCache() async {
    final uid = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (uid != null) {
      await ref
          .read(entityCacheStoreProvider)
          .invalidate(CacheKeys.plansPage0(uid));
    }
    ref.invalidate(plansProvider);
  }

  Set<String> get _addedSiteIds =>
      _plan?.stops.map((s) => s.siteId).toSet() ?? {};

  Future<(double?, double?)> _maybeLocation() async {
    if (!_useMyLocation) return (null, null);
    final fix = await ref.read(deviceLocationProvider).tryCurrent();
    if (fix == null) return (null, null);
    return (fix.lat, fix.lng);
  }

  double? _parseNum(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return null;
    return double.tryParse(t.replaceAll(',', '.'));
  }

  Future<void> _runSearch() async {
    final text = _queryCtrl.text.trim();
    setState(() {
      _searching = true;
      _searched = true;
      _hits = const [];
      _visibleCount = PagedItems.defaultPageSize;
    });
    try {
      final loc = await _maybeLocation();
      final locationExtra = _locationCtrl.text.trim();
      final filters = SearchFilters(
        query: text.isEmpty ? null : text,
        categoryId: _advanced ? _categoryId : null,
        locationQuery: _advanced
            ? (locationExtra.isNotEmpty
                ? locationExtra
                : null)
            : null,
        lat: _advanced ? loc.$1 : null,
        lng: _advanced ? loc.$2 : null,
        radiusKm:
            _advanced && _useMyLocation ? _parseNum(_radiusCtrl.text) : null,
        transportGroup: _advanced ? _transportGroup : null,
        budgetMin: _advanced ? _parseNum(_budgetMinCtrl.text) : null,
        budgetMax: _advanced ? _parseNum(_budgetMaxCtrl.text) : null,
        includePublic: _includePublic,
      );
      // forceNetwork: la caché SWR vacía bloqueaba sitios recién completados.
      final hits = await ref.read(swrLoaderProvider).load<List<SearchHit>>(
            key: CacheKeys.search('plans|${filters.cacheKey}'),
            ttl: CacheTtl.search,
            forceNetwork: true,
            decode: (payload) {
              final list = payload as List? ?? const [];
              return list
                  .whereType<Map>()
                  .map((e) => SearchHit.fromJson(Map<String, dynamic>.from(e)))
                  .toList();
            },
            encode: (value) => value.map((e) => e.toJson()).toList(),
            network: () =>
                ref.read(searchRepositoryProvider).search(filters),
          );
      if (!mounted) return;
      setState(() {
        _hits = hits
            .where((h) => h.lat != null && h.lng != null)
            .toList(growable: false);
        _searching = false;
        _tab = _PlanBuilderTab.results;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _searching = false);
      AppToast.error(context, e, logContext: 'plan_builder_search');
    }
  }

  Future<void> _addHit(SearchHit hit) async {
    if (_mutating || _addedSiteIds.contains(hit.siteId)) return;
    setState(() => _mutating = true);
    try {
      await widget.repository.addStop(
        planId: widget.planId,
        siteId: hit.siteId,
        lat: hit.lat,
        lng: hit.lng,
        estimatedPriceAmount: hit.estimatedPriceAmount,
      );
      await _invalidatePlansCache();
      await _loadPlan();
      if (!mounted) return;
      AppToast.show(context, context.l10n.planSiteAdded);
      setState(() {
        _mutating = false;
        _tab = _PlanBuilderTab.added;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _mutating = false);
      AppToast.error(context, e, logContext: 'plan_add_stop');
    }
  }

  Future<void> _removeStop(PlanStop stop) async {
    if (_mutating) return;
    setState(() => _mutating = true);
    try {
      await widget.repository.removeStop(
        planId: widget.planId,
        stopId: stop.id,
      );
      await _invalidatePlansCache();
      await _loadPlan();
      if (!mounted) return;
      setState(() => _mutating = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _mutating = false);
      AppToast.error(context, e, logContext: 'plan_remove_stop');
    }
  }

  Future<void> _toggleVisited(PlanStop stop) async {
    if (_mutating) return;
    setState(() => _mutating = true);
    try {
      await widget.repository.setVisited(
        stopId: stop.id,
        visited: !stop.isVisited,
      );
      await _invalidatePlansCache();
      await _loadPlan();
      if (!mounted) return;
      setState(() => _mutating = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _mutating = false);
      AppToast.error(context, e, logContext: 'plan_toggle_visited');
    }
  }

  int _reorderSeq = 0;

  Future<void> _reorderStops(int oldIndex, int newIndex) async {
    final plan = _plan;
    if (plan == null) return;
    final next = Plan.reorderedStops(
      stops: plan.stops,
      oldIndex: oldIndex,
      newIndex: newIndex,
    );
    if (identical(next, plan.stops)) return;
    setState(() => _plan = plan.copyWith(stops: next));
    final seq = ++_reorderSeq;
    try {
      await widget.repository.reorderStops(
        planId: widget.planId,
        ordered: next,
      );
      if (seq != _reorderSeq || !mounted) return;
      await _invalidatePlansCache();
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, e, logContext: 'plan_builder_reorder');
      await _loadPlan();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final plan = _plan;
    final categories = ref.watch(
      categoriesProvider.select((a) => a.valueOrNull ?? const <Category>[]),
    );
    final roots = categories.where((c) => c.isRoot).toList();
    final children = categories.where((c) => !c.isRoot).toList();

    return Scaffold(
      key: WidgetKeys.planBuilder,
      appBar: AppBar(
        title: Text(plan?.title ?? l10n.planCreateTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.actionDone),
          ),
        ],
      ),
      body: _loadingPlan || plan == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      AppSelectChip(
                        label: l10n.planTabSearch,
                        selected: _tab == _PlanBuilderTab.search,
                        filledPrimary: true,
                        onTap: () =>
                            setState(() => _tab = _PlanBuilderTab.search),
                      ),
                      AppSelectChip(
                        label: l10n.planTabResults,
                        selected: _tab == _PlanBuilderTab.results,
                        filledPrimary: true,
                        onTap: () =>
                            setState(() => _tab = _PlanBuilderTab.results),
                      ),
                      AppSelectChip(
                        label: l10n.planTabAdded(plan.stops.length),
                        selected: _tab == _PlanBuilderTab.added,
                        filledPrimary: true,
                        onTap: () =>
                            setState(() => _tab = _PlanBuilderTab.added),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: switch (_tab) {
                    _PlanBuilderTab.search => _buildSearch(
                        l10n: l10n,
                        roots: roots,
                        children: children,
                      ),
                    _PlanBuilderTab.results => _buildResults(l10n),
                    _PlanBuilderTab.added => PlanTimeline(
                        key: WidgetKeys.planTimeline,
                        stops: plan.stops,
                        emptyLabel: l10n.planTimelineEmpty,
                        onStopTap: (stop) => openSiteDetail(
                          context,
                          siteId: stop.siteId,
                        ),
                        onToggleVisited: _mutating ? null : _toggleVisited,
                        onRemove: _mutating ? null : _removeStop,
                        onReorder: _mutating ? null : _reorderStops,
                      ),
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildSearch({
    required AppLocalizations l10n,
    required List<Category> roots,
    required List<Category> children,
  }) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: [
        Text(
          l10n.planSearchCompleteOnlyHint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.muted,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.planSearchEmptyQueryHint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.muted,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => setState(() => _advanced = !_advanced),
            child: Text(_advanced ? l10n.searchSimple : l10n.searchAdvanced),
          ),
        ),
        AppSearchField(
          key: WidgetKeys.planBuilderSearch,
          controller: _queryCtrl,
          hint: l10n.planSearchHint,
          searchTooltip: l10n.actionSearch,
          loading: _searching,
          onSearch: () {
            setState(() => _tab = _PlanBuilderTab.results);
            _runSearch();
          },
        ),
        if (_advanced) ...[
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _locationCtrl,
            decoration: InputDecoration(
              labelText: l10n.searchLabelLocationExtra,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          InputDecorator(
            decoration: InputDecoration(
              labelText: l10n.searchLabelCategory,
              border: const OutlineInputBorder(),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                isExpanded: true,
                value: _categoryId,
                hint: Text(l10n.searchAny),
                items: [
                  DropdownMenuItem(value: null, child: Text(l10n.searchAny)),
                  ...roots.map(
                    (r) => DropdownMenuItem(value: r.id, child: Text(r.nameEs)),
                  ),
                  ...children.map(
                    (c) => DropdownMenuItem(
                      value: c.id,
                      child: Text('  ${c.nameEs}'),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _categoryId = v),
              ),
            ),
          ),
          SwitchListTile(
            key: WidgetKeys.planBuilderIncludePublic,
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.searchIncludePublic),
            value: _includePublic,
            onChanged: (v) => setState(() => _includePublic = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.searchUseMyLocation),
            value: _useMyLocation,
            onChanged: (v) => setState(() => _useMyLocation = v),
          ),
          if (_useMyLocation)
            TextField(
              controller: _radiusCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.searchRadiusKm,
                border: const OutlineInputBorder(),
              ),
            ),
        ] else
          SwitchListTile(
            key: WidgetKeys.planBuilderIncludePublic,
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.searchIncludePublic),
            value: _includePublic,
            onChanged: (v) => setState(() => _includePublic = v),
          ),
      ],
    );
  }

  Widget _buildResults(AppLocalizations l10n) {
    if (_searching) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_searched) {
      return Center(child: Text(l10n.planSearchFirst));
    }
    if (_hits.isEmpty) {
      return Center(child: Text(l10n.searchNoResults));
    }
    final visible = _hits.take(_visibleCount).toList();
    final hasMore = _visibleCount < _hits.length;
    final added = _addedSiteIds;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      itemCount: visible.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= visible.length) {
          return TextButton(
            onPressed: () {
              setState(() {
                _visibleCount += PagedItems.defaultPageSize;
              });
            },
            child: Text(
              l10n.searchLoadMoreRemaining(_hits.length - _visibleCount),
            ),
          );
        }
        final h = visible[index];
        final already = added.contains(h.siteId);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AppFormCard(
            onTap: () => openSiteDetail(context, hit: h),
            padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: SiteLookCover(
                      siteId: h.siteId,
                      categoryNames: h.categoryNames,
                      coverStoragePath: h.coverStoragePath,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        h.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.foreground,
                        ),
                      ),
                      Text(
                        [
                          if (h.city != null && h.city!.isNotEmpty) h.city!,
                          if (h.department != null &&
                              h.department!.isNotEmpty)
                            h.department!,
                          if (h.estimatedPriceAmount != null)
                            formatMoney(
                              h.estimatedPriceAmount!,
                              currencyCode: h.currencyCode,
                            ),
                        ].join(' · '),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.mutedDark,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l10n.planAddSite,
                  onPressed: already || _mutating
                      ? null
                      : () => _addHit(h),
                  icon: Icon(
                    already ? Icons.check : Icons.add,
                    color: already ? AppColors.success : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
