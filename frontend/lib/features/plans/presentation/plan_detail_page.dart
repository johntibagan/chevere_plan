import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/cache_ttl.dart';
import '../../../core/di/providers.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_toast.dart';
import '../../saves/presentation/open_site_detail.dart';
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

  @override
  void initState() {
    super.initState();
    _load();
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final plan = _plan;

    return Scaffold(
      appBar: AppBar(
        title: Text(plan?.title ?? l10n.plansTitle),
        actions: [
          if (plan != null)
            PopupMenuButton<_PlanMenu>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case _PlanMenu.addSites:
                    _openBuilder();
                  case _PlanMenu.share:
                    _share();
                  case _PlanMenu.delete:
                    _delete();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _PlanMenu.addSites,
                  child: Text(l10n.planMenuAddSites),
                ),
                PopupMenuItem(
                  value: _PlanMenu.share,
                  child: Text(l10n.planMenuShare),
                ),
                PopupMenuItem(
                  value: _PlanMenu.delete,
                  child: Text(l10n.actionDelete),
                ),
              ],
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
                        onStopTap: (stop) => openSiteDetail(
                          context,
                          siteId: stop.siteId,
                        ),
                      ),
                    ),
                    if (plan.stops.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: FilledButton.icon(
                          onPressed: _openBuilder,
                          icon: const Icon(Icons.add),
                          label: Text(l10n.planMenuAddSites),
                        ),
                      ),
                  ],
                ),
    );
  }
}

enum _PlanMenu { addSites, share, delete }
