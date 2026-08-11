import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/cache_ttl.dart';
import '../../../core/di/providers.dart';
import '../../../core/errors/user_facing_error.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/widgets/app_async_body.dart';
import '../../../core/widgets/app_list_card.dart';
import '../data/plan_models.dart';
import '../data/plans_repository.dart';
import 'create_plan_page.dart';
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
    // Touch provider (SWR) sin forzar spinner si hay caché.
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
    final error = async.hasError && page == null
        ? userFacingError(async.error!)
        : null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.plansTitle)),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: FloatingActionButton.extended(
          onPressed: _openCreate,
          icon: const Icon(Icons.auto_awesome),
          label: Text(l10n.plansCreateFab),
        ),
      ),
      body: AppAsyncBody(
        loading: loading,
        error: error,
        isEmpty: plans.isEmpty,
        emptyMessage: l10n.plansEmpty,
        onRefresh: _refresh,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
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
                          child: const Text('Cargar más'),
                        ),
                ),
              );
            }
            final plan = plans[index];
            return AppListCard(
              child: ListTile(
                title: Text(plan.title),
                subtitle: Text(
                  '${plan.locationQuery} · ${plan.stopCount} paradas',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PlanDetailPage(
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
