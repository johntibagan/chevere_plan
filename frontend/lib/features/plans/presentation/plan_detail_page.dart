import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/cache_ttl.dart';
import '../../../core/di/providers.dart';
import '../../../core/testing/widget_keys.dart';
import '../../../core/errors/user_facing_error.dart';
import '../../../core/formatters/money_format.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_busy_overlay.dart';
import '../../../core/widgets/app_section_label.dart';
import '../../../core/widgets/app_stat_card.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/coming_soon_page.dart';
import '../../../core/widgets/tab_screen_header.dart';
import '../../saves/presentation/open_site_detail.dart';
import '../../saves/presentation/site_look_cover.dart';
import '../data/maps_export.dart';
import '../data/plan_models.dart';
import '../data/plans_repository.dart';
import 'create_plan_page.dart';
import 'plan_builder_page.dart';
import 'plan_timeline.dart';

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
  Plan? _plan;
  bool _loading = true;
  bool _busy = false;
  (double, double)? _cachedOrigin;

  @override
  void initState() {
    super.initState();
    _load();
    _prefetchOrigin();
  }

  Future<void> _prefetchOrigin() async {
    final origin = await _currentLocation();
    if (!mounted || origin == null) return;
    _cachedOrigin = origin;
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final plan = await widget.repository.fetchById(widget.planId);
      if (!mounted) return;
      setState(() {
        _plan = plan;
        _loading = false;
      });
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

  Future<void> _openEdit() async {
    final plan = _plan;
    if (plan == null) return;
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

  Future<void> _openBuilder() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlanBuilderPage(
          planId: widget.planId,
          repository: widget.repository,
        ),
      ),
    );
    await _load();
    await _invalidatePlansCache();
  }

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

  Future<(double, double)?> _currentLocation() async {
    final fix = await ref.read(deviceLocationProvider).tryCurrent();
    if (fix == null) return null;
    return (fix.lat, fix.lng);
  }

  Future<void> _openMaps() async {
    final plan = _plan;
    if (plan == null || _busy) return;
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      await AppBusyOverlay.run(
        context,
        message: l10n.planOpeningMaps,
        action: () async {
          final results = await Future.wait<Object?>([
            widget.repository.hydrateMissingStopCoords(widget.planId),
            _cachedOrigin != null
                ? Future<(double, double)?>.value(_cachedOrigin)
                : _currentLocation(),
          ]);
          final hydrated = results[0] as Plan;
          final origin = results[1] as (double, double)?;
          if (origin != null) _cachedOrigin = origin;

          if (!mounted) return;
          setState(() => _plan = hydrated);

          final pending = hydrated.stops.where((s) => !s.isVisited).toList();
          if (pending.isEmpty) {
            throw AppUserError(l10n.planNoPendingStops);
          }
          final missing = pending.where((s) => s.lat == null || s.lng == null);
          if (missing.isNotEmpty) {
            throw AppUserError(l10n.planStopsMissingCoords);
          }
          if (origin == null) {
            throw AppUserError(l10n.planNeedLocation);
          }
          final ok = await openGoogleMapsDirections(
            originLat: origin.$1,
            originLng: origin.$2,
            stopsInOrder: pending,
          );
          if (!ok) {
            throw const AppUserError(kGenericAppError);
          }
        },
      );
    } catch (e) {
      if (!mounted) return;
      if (e is AppUserError) {
        AppToast.show(context, e.message, error: true);
      } else {
        AppToast.error(context, e, logContext: 'plan_open_maps');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.planDeleteTitle),
        content: Text(l10n.planDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            key: WidgetKeys.planDeleteConfirm,
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
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

  Future<void> _toggleVisited(PlanStop stop) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await widget.repository.setVisited(
        stopId: stop.id,
        visited: !stop.isVisited,
      );
      await _load();
      await _invalidatePlansCache();
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, e, logContext: 'plan_toggle_visited');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _removeStop(PlanStop stop) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await widget.repository.removeStop(
        planId: widget.planId,
        stopId: stop.id,
      );
      await _load();
      await _invalidatePlansCache();
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, e, logContext: 'plan_remove_stop');
    } finally {
      if (mounted) setState(() => _busy = false);
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
      AppToast.error(context, e, logContext: 'plan_reorder_stops');
      await _load();
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
              ListTile(
                key: WidgetKeys.planMenuEdit,
                leading: const Icon(Icons.edit_outlined),
                title: Text(l10n.planMenuEdit),
                onTap: () {
                  Navigator.pop(ctx);
                  _openEdit();
                },
              ),
              ListTile(
                leading: const Icon(Icons.map_outlined),
                title: Text(l10n.planMenuOpenMaps),
                onTap: () {
                  Navigator.pop(ctx);
                  _openMaps();
                },
              ),
              ListTile(
                leading: const Icon(Icons.ios_share_outlined),
                title: Text(l10n.planMenuShare),
                onTap: () {
                  Navigator.pop(ctx);
                  _share();
                },
              ),
              ListTile(
                key: WidgetKeys.planMenuDelete,
                leading: const Icon(Icons.delete_outline),
                title: Text(l10n.actionDelete),
                onTap: () {
                  Navigator.pop(ctx);
                  _delete();
                },
              ),
              const SizedBox(height: AppSpacing.sm),
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

    return Scaffold(
      key: WidgetKeys.planDetail,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : plan == null
              ? Center(child: Text(l10n.actionRetry))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PlanHero(
                      plan: plan,
                      onBack: () => Navigator.of(context).pop(),
                      onMore: _busy ? null : _showMoreMenu,
                    ),
                    _PlanStatsRow(plan: plan),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: AppSectionLabel(
                        text: l10n.planItinerary,
                        bottom: 0,
                      ),
                    ),
                    Expanded(
                      child: PlanTimeline(
                        key: WidgetKeys.planTimeline,
                        stops: plan.stops,
                        emptyLabel: l10n.planTimelineEmpty,
                        bottomPadding: 24,
                        onStopTap: (stop) => openSiteDetail(
                          context,
                          siteId: stop.siteId,
                        ),
                        onToggleVisited: _busy ? null : _toggleVisited,
                        onRemove: _busy ? null : _removeStop,
                        onReorder: _busy ? null : _reorderStops,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: ComingSoonCard(
                        title: l10n.comingSoonTransportTitle,
                        subtitle: l10n.comingSoonBadge,
                        pageTitle: l10n.comingSoonTransportTitle,
                        pageBody: l10n.comingSoonTransportBody,
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
                                onPressed: _busy ? null : _openMaps,
                                icon: const Icon(
                                  Icons.near_me_outlined,
                                  size: 18,
                                ),
                                label: Text(l10n.planMenuOpenMaps),
                              ),
                            ),
                            const SizedBox(width: 8),
                            AppSquareIconButton(
                              icon: Icons.ios_share_outlined,
                              tooltip: l10n.planMenuShare,
                              onTap: _busy ? () {} : _share,
                            ),
                            const SizedBox(width: 8),
                            AppSquareIconButton(
                              key: WidgetKeys.planDetailAdd,
                              icon: Icons.add,
                              tooltip: l10n.planMenuAddSites,
                              selected: true,
                              onTap: _busy ? () {} : _openBuilder,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
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
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x66000000),
                  Colors.transparent,
                  Color(0xFF0B0D15),
                ],
                stops: [0, 0.4, 1],
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
                        icon: const Icon(Icons.arrow_back),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0x80000000),
                          foregroundColor: AppColors.onImage,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        key: WidgetKeys.planDetailMore,
                        onPressed: onMore,
                        icon: const Icon(Icons.more_vert),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0x80000000),
                          foregroundColor: AppColors.onImage,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      plan.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onImage,
                      ),
                    ),
                  ),
                  if (plan.locationQuery.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                      child: Text(
                        plan.locationQuery,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanStatsRow extends StatelessWidget {
  const _PlanStatsRow({required this.plan});

  final Plan plan;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final budget = plan.maxBudgetAmount == null
        ? '—'
        : formatMoney(
            plan.maxBudgetAmount!,
            currencyCode: plan.currencyCode,
          );
    final zone =
        plan.locationQuery.isEmpty ? '—' : plan.locationQuery;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: AppStatCard(
              key: WidgetKeys.planStatStops,
              value: '${plan.stops.length}',
              label: l10n.planStatStops,
              valueColor: AppColors.accent,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AppStatCard(
              key: WidgetKeys.planStatBudget,
              value: budget,
              label: l10n.planStatBudget,
              valueColor: AppColors.success,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AppStatCard(
              value: zone,
              label: l10n.planStatZone,
              valueColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
