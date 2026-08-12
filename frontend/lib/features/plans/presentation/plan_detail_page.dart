import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/cache/cache_ttl.dart';
import '../../../core/di/providers.dart';
import '../../../core/errors/user_facing_error.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_busy_overlay.dart';
import '../../../core/widgets/app_toast.dart';
import '../../saves/presentation/open_site_detail.dart';
import '../data/maps_export.dart';
import '../data/plan_models.dart';
import '../data/plans_repository.dart';
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
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      return (pos.latitude, pos.longitude);
    } catch (_) {
      return null;
    }
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
      appBar: AppBar(
        title: Text(plan?.title ?? l10n.plansTitle),
      ),
      floatingActionButton: plan == null
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton.small(
                  heroTag: 'plan_more_fab',
                  tooltip: l10n.planMenuMore,
                  onPressed: _busy ? null : _showMoreMenu,
                  child: const Icon(Icons.more_vert),
                ),
                const SizedBox(height: AppSpacing.sm),
                FloatingActionButton(
                  heroTag: 'plan_add_fab',
                  tooltip: l10n.planMenuAddSites,
                  onPressed: _busy ? null : _openBuilder,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : plan == null
              ? Center(child: Text(l10n.actionRetry))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.sm,
                      ),
                      child: Text(
                        plan.status == 'draft'
                            ? l10n.planStatusDraft
                            : l10n.planStopsCount(plan.stops.length),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.muted,
                            ),
                      ),
                    ),
                    Expanded(
                      child: PlanTimeline(
                        stops: plan.stops,
                        emptyLabel: l10n.planTimelineEmpty,
                        bottomPadding: 120,
                        onStopTap: (stop) => openSiteDetail(
                          context,
                          siteId: stop.siteId,
                        ),
                        onToggleVisited: _busy ? null : _toggleVisited,
                        onRemove: _busy ? null : _removeStop,
                      ),
                    ),
                  ],
                ),
    );
  }
}
