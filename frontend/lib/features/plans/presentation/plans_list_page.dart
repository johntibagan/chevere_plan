import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/cache_ttl.dart';
import '../../../core/di/providers.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/widgets/app_async_body.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/app_list_card.dart';
import '../data/plan_models.dart';
import '../data/plans_repository.dart';
import 'create_plan_page.dart';
import 'plan_builder_page.dart';
import 'plan_detail_page.dart';

class PlansListPage extends ConsumerStatefulWidget {
  const PlansListPage({super.key, required this.repository});

  final PlansRepository repository;

  @override
  ConsumerState<PlansListPage> createState() => _PlansListPageState();
}

class _PlansListPageState extends ConsumerState<PlansListPage> {
  @override
  void initState() {
    super.initState();
    unawaited(ref.read(plansProvider.future));
  }

  Future<void> _refresh() async {
    await ref.read(plansProvider.notifier).refresh(force: true);
  }

  Future<void> _openCreate() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CreatePlanPage(repository: widget.repository),
      ),
    );
    final uid = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (uid != null) {
      unawaited(
        ref.read(entityCacheStoreProvider).invalidate(CacheKeys.plansPage0(uid)),
      );
    }
    await ref.read(plansProvider.notifier).refresh(force: true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final async = ref.watch(plansProvider);
    final page = async.valueOrNull;
    final plans = page?.items ?? const <Plan>[];
    final loading = async.isLoading && page == null;
    final error = async.hasError && page == null ? 'failed' : null;

    ref.listen(plansProvider, (prev, next) {
      if (next.hasError && !(prev?.hasError ?? false)) {
        AppToast.error(context, next.error!);
      }
    });

    // FAB por encima de la bottom nav del shell (extendBody).
    const fabBottomClearance = 72.0;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.plansTitle)),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: fabBottomClearance),
        child: FloatingActionButton.extended(
          heroTag: 'plans_create_fab',
          onPressed: _openCreate,
          icon: const Icon(Icons.add),
          label: Text(l10n.plansCreateFab),
        ),
      ),
      body: AppAsyncBody(
        loading: loading,
        error: error,
        isEmpty: plans.isEmpty,
        emptyMessage: l10n.plansEmpty,
        emptyAction: FilledButton.icon(
          onPressed: _openCreate,
          icon: const Icon(Icons.add),
          label: Text(l10n.plansCreateFab),
        ),
        onRefresh: _refresh,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          itemCount: plans.length + ((page?.hasMore ?? false) ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= plans.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: (page?.loadingMore ?? false)
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : TextButton(
                          onPressed: () =>
                              ref.read(plansProvider.notifier).loadMore(),
                          child: Text(context.l10n.actionLoadMore),
                        ),
                ),
              );
            }
            final plan = plans[index];
            final isDraft = plan.status == 'draft';
            return AppListCard(
              child: ListTile(
                title: Text(plan.title),
                subtitle: Text(
                  isDraft
                      ? context.l10n.planStatusDraft
                      : context.l10n.planStopsCount(plan.stopCount),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => isDraft && plan.stopCount == 0
                          ? PlanBuilderPage(
                              planId: plan.id,
                              repository: widget.repository,
                            )
                          : PlanDetailPage(
                              planId: plan.id,
                              repository: widget.repository,
                            ),
                    ),
                  );
                  await ref.read(plansProvider.notifier).refresh(force: false);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
