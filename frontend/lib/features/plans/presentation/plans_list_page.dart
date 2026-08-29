import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/cache_ttl.dart';
import '../../../core/di/providers.dart';
import '../../../core/testing/widget_keys.dart';
import '../../../core/formatters/money_format.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_rebuild.dart';
import '../../../core/widgets/app_async_body.dart';
import '../../../core/widgets/app_floating_action_layout.dart';
import '../../../core/widgets/app_status_pill.dart';
import '../../../core/widgets/site_cover.dart';
import '../../../core/widgets/tab_screen_header.dart';
import '../../saves/presentation/site_look_cover.dart';
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
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlanDetailPage(
          planId: plan.id,
          repository: widget.repository,
        ),
      ),
    );
    await ref.read(plansProvider.notifier).refresh(force: false);
  }

  @override
  Widget build(BuildContext context) {
    ref.watchAppThemeMode();
    final l10n = context.l10n;
    final async = ref.watch(plansProvider);
    final page = async.valueOrNull;
    final plans = page?.items ?? const <Plan>[];
    final loading = async.isLoading && page == null;
    final loadFailed = async.hasError && page == null;
    final listBottomPadding = AppFloatingActionLayout.listScrollPadding(
      context,
      aboveShellBottomNav: true,
      extendedFab: true,
    );

    return Stack(
      children: [
        Scaffold(
          key: WidgetKeys.plansList,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TabScreenHeader(title: l10n.plansTitle),
                Expanded(
                  child: AppAsyncBody(
                    loading: loading,
                    hasError: loadFailed,
                    isEmpty: false,
                    emptyMessage: l10n.plansEmpty,
                    onRefresh: _refresh,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.sm,
                        AppSpacing.lg,
                        listBottomPadding,
                      ),
                      itemCount: plans.isEmpty
                          ? 1
                          : plans.length +
                              ((page?.hasMore ?? false) ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (plans.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 24),
                            child: Text(
                              l10n.plansEmpty,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.muted,
                              ),
                            ),
                          );
                        }
                        if (index >= plans.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: (page?.loadingMore ?? false)
                                  ? SizedBox(
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
                            key: WidgetKeys.planCard(plans[index].id),
                            plan: plans[index],
                            onTap: () => _openPlan(plans[index]),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        AppAnchoredFloatingAction(
          aboveShellBottomNav: true,
          child: FloatingActionButton.extended(
            key: WidgetKeys.plansCreateFab,
            heroTag: 'plans_create_fab',
            onPressed: _openCreate,
            icon: const Icon(Icons.add),
            label: Text(l10n.plansCreateFab),
          ),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({super.key, required this.plan, required this.onTap});

  final Plan plan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDraft = plan.status == 'draft';
    final statusLabel =
        isDraft ? l10n.planStatusDraft : l10n.plansStatusUpcoming;
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 96,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SiteLookCover(
                    siteId: plan.stops.isNotEmpty
                        ? plan.stops.first.siteId
                        : null,
                    categoryNames: plan.stops.isNotEmpty
                        ? plan.stops.first.categoryNames
                        : const [],
                    coverStoragePath: plan.stops.isNotEmpty
                        ? plan.stops.first.coverStoragePath
                        : null,
                  ),
                  const SiteCoverScrim(bottomOpacity: 0.8),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: AppStatusPill(
                      label: statusLabel,
                      emphasized: !isDraft,
                    ),
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 8,
                    child: Text(
                      plan.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Row(
                children: [
                  if (plan.locationQuery.isNotEmpty) ...[
                    Icon(
                      Icons.place_outlined,
                      size: 12,
                      color: AppColors.accent,
                    ),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        plan.locationQuery,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                  ],
                  Icon(
                    Icons.trending_up_rounded,
                    size: 12,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 4),
                  Text(
                    l10n.planStopsCount(plan.stopCount),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                  ),
                  if (plan.maxBudgetAmount != null) ...[
                    SizedBox(width: 10),
                    Icon(
                      Icons.attach_money_rounded,
                      size: 12,
                      color: AppColors.success,
                    ),
                    SizedBox(width: 2),
                    Text(
                      formatMoney(
                        plan.maxBudgetAmount!,
                        currencyCode: plan.currencyCode,
                      ),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
