import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/cache/cache_ttl.dart';
import '../../../core/cache/paged_items.dart';
import '../../../core/di/providers.dart';
import '../../../core/testing/widget_keys.dart';
import '../../../core/errors/user_facing_error.dart';
import '../../../core/formatters/money_format.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_busy_overlay.dart';
import '../../../core/widgets/app_confirm_dialog.dart';
import '../../../core/widgets/app_floating_action_layout.dart';
import '../../../core/widgets/app_form_card.dart';
import '../../../core/widgets/app_search_field.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/discard_changes_scope.dart';
import '../../saves/presentation/open_site_detail.dart';
import '../../saves/presentation/site_look_cover.dart';
import '../../search/data/search_models.dart';
import '../data/maps_export.dart';
import '../data/plan_models.dart';
import '../data/plans_repository.dart';
import 'create_plan_page.dart';
import 'plan_reviews_tab.dart';
import 'plan_timeline.dart';

enum _PlanDetailPanel { search, stops, reviews }

class PlanDetailPage extends ConsumerStatefulWidget {
  const PlanDetailPage({
    super.key,
    required this.planId,
    required this.repository,
  });

  final String planId;
  final PlansRepository repository;

  @override
  ConsumerState<PlanDetailPage> createState() => _PlanDetailPageState();
}

class _PlanDetailPageState extends ConsumerState<PlanDetailPage> {
  static const _bottomClearance = AppFloatingActionLayout.fixedBottomBarClearance;

  Plan? _plan;
  List<PlanStop> _initialStops = const [];
  bool _loading = true;
  bool _mapsBusy = false;
  bool _saving = false;
  _PlanDetailPanel _panel = _PlanDetailPanel.stops;
  (double, double)? _cachedOrigin;

  final _queryCtrl = TextEditingController();
  bool _includePublic = true;
  bool _searching = false;
  List<SearchHit> _hits = const [];
  bool _searched = false;
  int _visibleCount = PagedItems.defaultPageSize;
  int _reviewCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
    _prefetchOrigin();
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    super.dispose();
  }

  bool get _canEditPlan {
    final plan = _plan;
    if (plan == null) return false;
    final uid = ref.read(supabaseClientProvider).auth.currentUser?.id;
    return plan.isOwnedBy(uid);
  }

  bool get _stopsDirty {
    final plan = _plan;
    if (plan == null || !_canEditPlan) return false;
    return !Plan.stopsSnapshotEqual(_initialStops, plan.stops);
  }

  Set<String> get _addedSiteIds =>
      _plan?.stops.map((s) => s.siteId).toSet() ?? {};

  PlanStop? _stopForSite(String siteId) {
    final plan = _plan;
    if (plan == null) return null;
    for (final stop in plan.stops) {
      if (stop.siteId == siteId) return stop;
    }
    return null;
  }

  Future<void> _prefetchOrigin() async {
    final loc = ref.read(deviceLocationProvider);
    final last = await loc.lastKnown();
    if (last != null && mounted) {
      _cachedOrigin = (last.lat, last.lng);
    }
    final fresh = await loc.tryCurrent(
      accuracy: LocationAccuracy.low,
      timeLimit: const Duration(seconds: 3),
      request: true,
    );
    if (fresh != null && mounted) {
      _cachedOrigin = (fresh.lat, fresh.lng);
    }
  }

  Future<(double, double)?> _originFast() async {
    if (_cachedOrigin != null) return _cachedOrigin;
    final loc = ref.read(deviceLocationProvider);
    final last = await loc.lastKnown();
    if (last != null) {
      _cachedOrigin = (last.lat, last.lng);
      return _cachedOrigin;
    }
    final fresh = await loc.tryCurrent(
      accuracy: LocationAccuracy.low,
      timeLimit: const Duration(seconds: 4),
      request: true,
    );
    if (fresh == null) return null;
    _cachedOrigin = (fresh.lat, fresh.lng);
    return _cachedOrigin;
  }

  void _selectPanel(_PlanDetailPanel panel) {
    setState(() => _panel = panel);
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final plan = await widget.repository.fetchById(widget.planId);
      if (!mounted) return;
      final canEdit = plan.isOwnedBy(
        ref.read(supabaseClientProvider).auth.currentUser?.id,
      );
      final initialPanel = canEdit && plan.stops.isEmpty
          ? _PlanDetailPanel.search
          : _PlanDetailPanel.stops;
      setState(() {
        _plan = plan;
        _initialStops = List<PlanStop>.from(plan.stops);
        _panel = initialPanel;
        _loading = false;
      });
      unawaited(_loadReviewCount());
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      AppToast.error(context, e, logContext: 'plan_detail');
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

  Future<void> _loadReviewCount() async {
    try {
      final count = await ref
          .read(planReviewsRepositoryProvider)
          .countForPlan(widget.planId);
      if (!mounted) return;
      setState(() => _reviewCount = count);
    } catch (_) {}
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
      final filters = SearchFilters(
        query: text.isEmpty ? null : text,
        includePublic: _includePublic,
      );
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
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _searching = false);
      AppToast.error(context, e, logContext: 'plan_detail_search');
    }
  }

  int _nextSortOrder(List<PlanStop> stops) {
    var next = 0;
    for (final s in stops) {
      if (s.sortOrder + 1 > next) next = s.sortOrder + 1;
    }
    return next;
  }

  void _addHit(SearchHit hit) {
    final plan = _plan;
    if (plan == null || _addedSiteIds.contains(hit.siteId)) return;
    if (hit.lat == null || hit.lng == null) {
      AppToast.show(
        context,
        context.l10n.planStopsMissingCoords,
        error: true,
      );
      return;
    }
    final stop = PlanStop(
      id: PlanStop.pendingId(hit.siteId),
      planId: widget.planId,
      siteId: hit.siteId,
      sortOrder: _nextSortOrder(plan.stops),
      siteName: hit.name,
      lat: hit.lat,
      lng: hit.lng,
      city: hit.city,
      department: hit.department,
      estimatedPriceAmount: hit.estimatedPriceAmount,
      categoryNames: hit.categoryNames,
      coverStoragePath: hit.coverStoragePath,
    );
    setState(() {
      _plan = plan.copyWith(stops: [...plan.stops, stop]);
    });
  }

  void _removeHit(SearchHit hit) {
    final stop = _stopForSite(hit.siteId);
    if (stop == null) return;
    _removeStop(stop);
  }

  void _removeStop(PlanStop stop) {
    final plan = _plan;
    if (plan == null) return;
    setState(() {
      _plan = plan.copyWith(
        stops: plan.stops.where((s) => s.id != stop.id).toList(),
      );
    });
  }

  void _toggleVisited(PlanStop stop) {
    final plan = _plan;
    if (plan == null) return;
    setState(() {
      _plan = plan.copyWith(
        stops: [
          for (final s in plan.stops)
            if (s.id == stop.id)
              s.isVisited
                  ? s.copyWith(clearVisited: true)
                  : s.copyWith(visitedAt: DateTime.now().toUtc())
            else
              s,
        ],
      );
    });
  }

  void _reorderStops(int oldIndex, int newIndex) {
    final plan = _plan;
    if (plan == null) return;
    final next = Plan.reorderedStops(
      stops: plan.stops,
      oldIndex: oldIndex,
      newIndex: newIndex,
    );
    if (identical(next, plan.stops)) return;
    setState(() {
      _plan = plan.copyWith(stops: next);
    });
  }

  Future<void> _save() async {
    if (_saving || !_stopsDirty) return;
    final plan = _plan;
    if (plan == null) return;
    setState(() => _saving = true);
    try {
      await widget.repository.persistPlanStops(
        planId: widget.planId,
        initialStops: _initialStops,
        desiredStops: plan.stops,
      );
      await _invalidatePlansCache();
      final fresh = await widget.repository.fetchById(widget.planId);
      if (!mounted) return;
      setState(() {
        _plan = fresh;
        _initialStops = List<PlanStop>.from(fresh.stops);
        _saving = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppToast.error(context, e, logContext: 'plan_detail_save');
    }
  }

  Future<bool> _confirmDiscardIfDirty() async {
    if (!_stopsDirty || _saving) return true;
    return confirmDiscardChanges(context);
  }

  Future<void> _openEdit() async {
    final plan = _plan;
    if (plan == null || !_canEditPlan) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CreatePlanPage(
          repository: widget.repository,
          existing: plan,
        ),
      ),
    );
    await _load();
    await _invalidatePlansCache();
  }

  // Fase 2: compartir plan por @usuario (rediseño completo). UI oculta; lógica conservada.
  // ignore: unused_element
  Future<void> _share() async {
    final plan = _plan;
    if (plan == null) return;
    final text = [
      plan.title,
      if (plan.stops.isNotEmpty)
        plan.stops.map((s) => '• ${s.siteName}').join('\n'),
    ].join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    AppToast.show(context, context.l10n.planShareCopied);
  }

  Future<void> _openMaps() async {
    final plan = _plan;
    if (plan == null || _mapsBusy) return;
    final l10n = context.l10n;
    final pending = plan.stops.where((s) => !s.isVisited).toList();
    if (pending.isEmpty) {
      AppToast.show(context, l10n.planNoPendingStops, error: true);
      return;
    }

    final needsExactCoords = pending.any(
      (s) => s.useExactPin && (s.lat == null || s.lng == null),
    );

    setState(() => _mapsBusy = true);
    try {
      var toExport = plan;
      var origin = await _originFast();

      if (needsExactCoords || origin == null) {
        if (!mounted) return;
        await AppBusyOverlay.run(
          context,
          message: l10n.planOpeningMaps,
          action: () async {
            if (needsExactCoords) {
              toExport = await widget.repository.hydrateMissingStopCoords(
                widget.planId,
                known: plan,
              );
              if (mounted) setState(() => _plan = toExport);
            }
            origin ??= await _originFast();
          },
        );
      }

      if (!mounted) return;
      final start = origin;
      if (start == null) {
        throw AppUserError(l10n.planNeedLocation);
      }

      final routeStops = toExport.stops.where((s) => !s.isVisited).toList();
      final stillMissingExact = routeStops.where(
        (s) => s.useExactPin && (s.lat == null || s.lng == null),
      );
      if (stillMissingExact.isNotEmpty) {
        throw AppUserError(l10n.planStopsMissingCoords);
      }

      final ok = await openGoogleMapsDirections(
        originLat: start.$1,
        originLng: start.$2,
        stopsInOrder: routeStops,
      );
      if (!ok) {
        throw const AppUserError(kGenericAppError);
      }
    } catch (e) {
      if (!mounted) return;
      if (e is AppUserError) {
        AppToast.show(context, e.message, error: true);
      } else {
        AppToast.error(context, e, logContext: 'plan_open_maps');
      }
    } finally {
      if (mounted) setState(() => _mapsBusy = false);
    }
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final ok = await showAppConfirmDialog<bool>(
      context: context,
      icon: Icons.delete_outline,
      tone: AppConfirmTone.danger,
      title: l10n.planDeleteTitle,
      body: l10n.planDeleteConfirm,
      actions: [
        AppConfirmAction(label: l10n.actionCancel, value: false),
        AppConfirmAction(
          key: WidgetKeys.planDeleteConfirm,
          label: l10n.actionDelete,
          value: true,
          isPrimary: true,
          isDestructive: true,
        ),
      ],
    );
    if (ok != true) return;
    try {
      await widget.repository.deletePlan(widget.planId);
      await _invalidatePlansCache();
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, e, logContext: 'plan_delete');
    }
  }

  Future<void> _showMoreMenu() async {
    final l10n = context.l10n;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_canEditPlan)
                ListTile(
                  key: WidgetKeys.planMenuEdit,
                  leading: Icon(Icons.edit_outlined),
                  title: Text(l10n.planMenuEdit),
                  onTap: () {
                    Navigator.pop(ctx);
                    _openEdit();
                  },
                ),
              // Fase 2: compartir por @usuario — menú ⋮ (no borrar _share).
              // ListTile(
              //   leading: Icon(Icons.ios_share_outlined),
              //   title: Text(l10n.planMenuShare),
              //   onTap: () {
              //     Navigator.pop(ctx);
              //     _share();
              //   },
              // ),
              if (_canEditPlan)
                ListTile(
                  key: WidgetKeys.planMenuDelete,
                  leading: Icon(Icons.delete_outline),
                  title: Text(l10n.actionDelete),
                  onTap: () {
                    Navigator.pop(ctx);
                    _delete();
                  },
                ),
              SizedBox(height: AppSpacing.sm),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final plan = _plan;
    final canEdit = _canEditPlan;
    final busy = _mapsBusy || _saving;

    return PopScope(
      canPop: !_stopsDirty || _saving,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _confirmDiscardIfDirty() && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        key: WidgetKeys.planDetail,
        body: _loading
            ? Center(child: CircularProgressIndicator())
            : plan == null
                ? Center(child: Text(l10n.actionRetry))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _PlanHero(
                        plan: plan,
                        onBack: () async {
                          if (await _confirmDiscardIfDirty() && context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        onMore: busy ? null : _showMoreMenu,
                      ),
                      _PlanStatsRow(
                        plan: plan,
                        canEdit: canEdit,
                        panel: _panel,
                        reviewCount: _reviewCount,
                        onSearchTap: busy
                            ? null
                            : () => _selectPanel(_PlanDetailPanel.search),
                        onStopsTap: busy
                            ? null
                            : () => _selectPanel(_PlanDetailPanel.stops),
                        onReviewsTap: busy
                            ? null
                            : () => _selectPanel(_PlanDetailPanel.reviews),
                      ),
                      Expanded(
                        child: _buildPanelContent(
                          l10n: l10n,
                          plan: plan,
                          canEdit: canEdit,
                          busy: busy,
                        ),
                      ),
                      SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: busy || plan.stops.isEmpty
                                      ? null
                                      : _openMaps,
                                  icon: Icon(
                                    Icons.near_me_outlined,
                                    size: 18,
                                  ),
                                  label: Text(l10n.planMenuOpenMaps),
                                ),
                              ),
                              if (canEdit &&
                                  _panel != _PlanDetailPanel.reviews) ...[
                                SizedBox(width: 8),
                                Expanded(
                                  child: FilledButton.icon(
                                    key: _panel == _PlanDetailPanel.search
                                        ? WidgetKeys.planBuilderDone
                                        : WidgetKeys.planBuilderSave,
                                    onPressed: _saving
                                        ? null
                                        : _panel == _PlanDetailPanel.search
                                            ? () => _selectPanel(
                                                  _PlanDetailPanel.stops,
                                                )
                                            : _stopsDirty
                                                ? _save
                                                : null,
                                    icon: _saving &&
                                            _panel == _PlanDetailPanel.stops
                                        ? SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Icon(
                                            _panel == _PlanDetailPanel.search
                                                ? Icons.check
                                                : Icons.save_outlined,
                                            size: 18,
                                          ),
                                    label: Text(
                                      _panel == _PlanDetailPanel.search
                                          ? l10n.actionDone
                                          : l10n.actionSave,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildPanelContent({
    required AppLocalizations l10n,
    required Plan plan,
    required bool canEdit,
    required bool busy,
  }) {
    if (!canEdit) {
      return PlanTimeline(
        key: WidgetKeys.planTimeline,
        stops: plan.stops,
        emptyLabel: l10n.planTimelineEmpty,
        bottomPadding: _bottomClearance,
        onStopTap: (stop) => openSiteDetail(
          context,
          siteId: stop.siteId,
        ),
      );
    }
    return switch (_panel) {
      _PlanDetailPanel.search => _buildSearchTab(l10n),
      _PlanDetailPanel.stops => PlanTimeline(
          key: WidgetKeys.planTimeline,
          stops: plan.stops,
          emptyLabel: l10n.planTimelineEmpty,
          bottomPadding: _bottomClearance,
          onStopTap: (stop) => openSiteDetail(
            context,
            siteId: stop.siteId,
          ),
          onToggleVisited: !busy ? _toggleVisited : null,
          onRemove: !busy ? _removeStop : null,
          onReorder: !busy ? _reorderStops : null,
        ),
      _PlanDetailPanel.reviews => PlanReviewsTab(
          planId: widget.planId,
          planTitle: plan.title,
          bottomPadding: _bottomClearance,
          onReviewsChanged: _loadReviewCount,
        ),
    };
  }

  Widget _buildSearchTab(AppLocalizations l10n) {
    final children = <Widget>[
      AppSearchField(
        key: WidgetKeys.planBuilderSearch,
        controller: _queryCtrl,
        hint: l10n.planSearchHint,
        searchTooltip: l10n.actionSearch,
        loading: _searching,
        onSearch: _runSearch,
      ),
      SwitchListTile(
        key: WidgetKeys.planBuilderIncludePublic,
        contentPadding: EdgeInsets.zero,
        title: Text(l10n.searchIncludePublic),
        value: _includePublic,
        onChanged: (v) => setState(() => _includePublic = v),
      ),
    ];

    if (_searching) {
      children.addAll([
        SizedBox(height: AppSpacing.lg),
        Center(child: CircularProgressIndicator()),
      ]);
    } else if (_searched) {
      if (_hits.isEmpty) {
        children.addAll([
          SizedBox(height: AppSpacing.lg),
          Center(
            child: Text(
              l10n.searchNoResults,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ]);
      } else {
        children.add(SizedBox(height: AppSpacing.sm));
        children.addAll(_buildResultTiles(l10n));
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        _bottomClearance,
      ),
      children: children,
    );
  }

  List<Widget> _buildResultTiles(AppLocalizations l10n) {
    final visible = _hits.take(_visibleCount).toList();
    final hasMore = _visibleCount < _hits.length;
    final added = _addedSiteIds;
    final tiles = <Widget>[];

    for (final h in visible) {
      final already = added.contains(h.siteId);
      tiles.add(
        Padding(
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
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        h.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.foreground,
                        ),
                      ),
                      Text(
                        [
                          if (h.city != null && h.city!.isNotEmpty) h.city!,
                          if (h.department != null && h.department!.isNotEmpty)
                            h.department!,
                          if (h.estimatedPriceAmount != null)
                            formatMoney(
                              h.estimatedPriceAmount!,
                              currencyCode: h.currencyCode,
                            ),
                        ].join(' · '),
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.mutedDark,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: already ? l10n.planRemoveStop : l10n.planAddSite,
                  onPressed: _saving
                      ? null
                      : () => already ? _removeHit(h) : _addHit(h),
                  icon: Icon(
                    already ? Icons.check_circle : Icons.add_circle_outline,
                    color: already ? AppColors.success : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (hasMore) {
      tiles.add(
        TextButton(
          onPressed: () {
            setState(() {
              _visibleCount += PagedItems.defaultPageSize;
            });
          },
          child: Text(
            l10n.searchLoadMoreRemaining(_hits.length - _visibleCount),
          ),
        ),
      );
    }

    return tiles;
  }
}

class _PlanHero extends StatelessWidget {
  const _PlanHero({
    required this.plan,
    required this.onBack,
    this.onMore,
  });

  final Plan plan;
  final VoidCallback onBack;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 176,
      child: Stack(
        fit: StackFit.expand,
        children: [
          SiteLookCover(
            siteId: plan.stops.isNotEmpty ? plan.stops.first.siteId : null,
            categoryNames: plan.stops.isNotEmpty
                ? plan.stops.first.categoryNames
                : const [],
            coverStoragePath: plan.stops.isNotEmpty
                ? plan.stops.first.coverStoragePath
                : null,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.coverScrim,
                  Colors.transparent,
                  AppColors.background,
                ],
                stops: const [0, 0.4, 1],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: onBack,
                        icon: Icon(Icons.arrow_back),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.scrim,
                          foregroundColor: AppColors.onImage,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        key: WidgetKeys.planDetailMore,
                        onPressed: onMore,
                        icon: Icon(Icons.more_vert),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.scrim,
                          foregroundColor: AppColors.onImage,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      plan.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onImage,
                      ),
                    ),
                  ),
                  if (plan.locationQuery.isNotEmpty ||
                      plan.maxBudgetAmount != null)
                    _PlanHeroMeta(plan: plan),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanHeroMeta extends StatelessWidget {
  const _PlanHeroMeta({required this.plan});

  final Plan plan;

  @override
  Widget build(BuildContext context) {
    final zone = plan.locationQuery.trim();
    final budget = plan.maxBudgetAmount;
    final budgetText = budget == null
        ? null
        : formatMoney(budget, currencyCode: plan.currencyCode);
    if (zone.isEmpty && budgetText == null) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Row(
        children: [
          if (zone.isNotEmpty)
            Flexible(
              child: Text(
                zone,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.onImage,
                ),
              ),
            ),
          if (zone.isNotEmpty && budgetText != null)
            Text(
              ' - ',
              style: TextStyle(fontSize: 12, color: AppColors.onImage),
            ),
          if (budgetText != null) ...[
            Icon(
              Icons.payments_outlined,
              size: 14,
              color: AppColors.warning,
            ),
            SizedBox(width: 4),
            Flexible(
              child: Text(
                budgetText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.onImage,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlanStatsRow extends StatelessWidget {
  const _PlanStatsRow({
    required this.plan,
    required this.canEdit,
    required this.panel,
    required this.reviewCount,
    this.onSearchTap,
    this.onStopsTap,
    this.onReviewsTap,
  });

  final Plan plan;
  final bool canEdit;
  final _PlanDetailPanel panel;
  final int reviewCount;
  final VoidCallback? onSearchTap;
  final VoidCallback? onStopsTap;
  final VoidCallback? onReviewsTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          if (canEdit) ...[
            Expanded(
              child: _PlanStatNavCard(
                key: WidgetKeys.planStatSearch,
                icon: Icons.search,
                label: l10n.planTabSearch,
                accentColor: AppColors.primary,
                selected: panel == _PlanDetailPanel.search,
                onTap: onSearchTap,
              ),
            ),
            SizedBox(width: 8),
          ],
          Expanded(
            child: _PlanStatNavCard(
              key: WidgetKeys.planStatStops,
              value: '${plan.stops.length}',
              label: l10n.planStatStops,
              accentColor: AppColors.accent,
              selected: canEdit && panel == _PlanDetailPanel.stops,
              onTap: onStopsTap,
            ),
          ),
          if (canEdit) ...[
            SizedBox(width: 8),
            Expanded(
              child: _PlanStatNavCard(
                key: WidgetKeys.planStatReviews,
                value: '$reviewCount',
                label: l10n.planStatReviews,
                accentColor: AppColors.primary,
                selected: panel == _PlanDetailPanel.reviews,
                onTap: onReviewsTap,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlanStatNavCard extends StatelessWidget {
  const _PlanStatNavCard({
    super.key,
    this.value,
    required this.label,
    this.icon,
    this.accentColor,
    this.selected = false,
    this.onTap,
  });

  final String? value;
  final String label;
  final IconData? icon;
  final Color? accentColor;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.primary;
    final borderColor = selected ? accent : AppColors.border;
    final borderWidth = selected ? 2.0 : 1.0;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Column(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: accent),
                SizedBox(height: 4),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ] else ...[
                Text(
                  value ?? '—',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedDark,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
