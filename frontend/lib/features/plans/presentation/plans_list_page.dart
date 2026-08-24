import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/cache_ttl.dart';
import '../../../core/di/providers.dart';
import '../../../core/testing/widget_keys.dart';
import '../../../core/formatters/money_format.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_async_body.dart';
import '../../../core/widgets/app_create_cta_card.dart';
import '../../../core/widgets/app_section_label.dart';
import '../../../core/widgets/app_status_pill.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/site_cover.dart';
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

    return Scaffold(
      key: WidgetKeys.plansList,
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
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                  itemCount: 2 +
                      (plans.isEmpty
                          ? 1
                          : plans.length + ((page?.hasMore ?? false) ? 1 : 0)),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return AppCreateCtaCard(
                        key: WidgetKeys.plansCreateCta,
                        title: l10n.plansCreateCardTitle,
                        hint: l10n.plansCreateCardHint,
                        onTap: _openCreate,
                      );
                    }
                    if (index == 1) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: AppSectionLabel(text: l10n.plansSavedHeading),
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
                        key: WidgetKeys.planCard(plans[planIndex].id),
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
        side: const BorderSide(color: AppColors.border),
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
                  const SiteCover(),
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
                      style: const TextStyle(
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
                    const Icon(
                      Icons.place_outlined,
                      size: 12,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        plan.locationQuery,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  const Icon(
                    Icons.trending_up_rounded,
                    size: 12,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.planStopsCount(plan.stopCount),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                  ),
                  if (plan.maxBudgetAmount != null) ...[
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.attach_money_rounded,
                      size: 12,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      formatMoney(
                        plan.maxBudgetAmount!,
                        currencyCode: plan.currencyCode,
                      ),
                      style: const TextStyle(
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
