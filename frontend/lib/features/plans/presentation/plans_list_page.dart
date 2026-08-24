import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/cache_ttl.dart';
import '../../../core/di/providers.dart';
import '../../../core/formatters/money_format.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_async_body.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/tab_screen_header.dart';
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

  Future<void> _openPlan(Plan plan) async {
    final isDraft = plan.status == 'draft';
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

    const fabBottomClearance = 72.0;

    return Scaffold(
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TabScreenHeader(
              title: l10n.plansTitle,
              subtitle: l10n.plansSubtitle,
            ),
            Expanded(
              child: AppAsyncBody(
                loading: loading,
                error: error,
                isEmpty: false,
                emptyMessage: l10n.plansEmpty,
                onRefresh: _refresh,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  itemCount: 2 +
                      (plans.isEmpty
                          ? 1
                          : plans.length + ((page?.hasMore ?? false) ? 1 : 0)),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _CreatePlanCard(onTap: _openCreate);
                    }
                    if (index == 1) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                        child: Text(
                          l10n.plansSavedHeading,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.foreground,
                          ),
                        ),
                      );
                    }
                    if (plans.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 24),
                        child: Text(
                          l10n.plansEmpty,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.muted,
                          ),
                        ),
                      );
                    }
                    final planIndex = index - 2;
                    if (planIndex >= plans.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: (page?.loadingMore ?? false)
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : TextButton(
                                  onPressed: () => ref
                                      .read(plansProvider.notifier)
                                      .loadMore(),
                                  child: Text(context.l10n.actionLoadMore),
                                ),
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PlanCard(
                        plan: plans[planIndex],
                        onTap: () => _openPlan(plans[planIndex]),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreatePlanCard extends StatelessWidget {
  const _CreatePlanCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.45)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.plansCreateCardTitle,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.plansCreateCardHint,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.onTap});

  final Plan plan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDraft = plan.status == 'draft';
    final statusLabel =
        isDraft ? l10n.planStatusDraft : l10n.plansStatusUpcoming;
    final statusColor = isDraft ? AppColors.muted : AppColors.primary;
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 88,
              height: 96,
              color: AppColors.surfaceElevated,
              alignment: Alignment.center,
              child: const Icon(
                Icons.map_outlined,
                color: AppColors.mutedDark,
                size: 28,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            plan.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.foreground,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (plan.locationQuery.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        plan.locationQuery,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      [
                        l10n.planStopsCount(plan.stopCount),
                        if (plan.maxBudgetAmount != null)
                          formatMoney(
                            plan.maxBudgetAmount!,
                            currencyCode: plan.currencyCode,
                          ),
                      ].join(' · '),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.mutedDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
