import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/paged_items.dart';
import '../../../core/di/providers.dart';
import '../../../core/testing/widget_keys.dart';
import '../domain/route_stats.dart';
import '../../../core/formatters/date_format.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/prefetch/site_prefetch.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_async_body.dart';
import '../../../core/widgets/app_section_label.dart';
import '../../../core/widgets/app_stat_card.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/site_cover.dart';
import '../../../core/widgets/tab_screen_header.dart';
import '../../plans/presentation/plan_detail_page.dart';
import '../data/route_models.dart';
import '../data/routes_repository.dart';

class MyRoutesPage extends ConsumerStatefulWidget {
  const MyRoutesPage({super.key, required this.repository});

  final RoutesRepository repository;

  @override
  ConsumerState<MyRoutesPage> createState() => _MyRoutesPageState();
}

class _MyRoutesPageState extends ConsumerState<MyRoutesPage> {
  int _visible = PagedItems.defaultPageSize;

  @override
  void initState() {
    super.initState();
    unawaited(ref.read(routesProvider.future).then((entries) {
      if (!mounted) return;
      ref.read(sitePrefetchProvider).scheduleVisibleSites(
            entries.map((e) => e.siteId),
          );
    }));
  }

  Future<void> _refresh() async {
    setState(() => _visible = PagedItems.defaultPageSize);
    await ref.read(routesProvider.notifier).refresh(force: true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final async = ref.watch(routesProvider);
    final all = async.valueOrNull ?? const <RouteHistoryEntry>[];
    final loading = async.isLoading && async.valueOrNull == null;
    final error = async.hasError && async.valueOrNull == null ? 'failed' : null;
    final visible = all.take(_visible).toList();
    final hasMore = _visible < all.length;

    final stats = RouteStats.fromEntries(all);

    ref.listen(routesProvider, (prev, next) {
      if (next.hasError && !(prev?.hasError ?? false)) {
        AppToast.error(context, next.error!);
      }
      next.whenData((entries) {
        ref.read(sitePrefetchProvider).scheduleVisibleSites(
              entries.map((e) => e.siteId),
            );
      });
    });

    return Scaffold(
      key: WidgetKeys.routesPage,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TabScreenHeader(
              title: l10n.routesTitle,
              subtitle: l10n.routesSubtitle,
            ),
            Expanded(
              child: AppAsyncBody(
                loading: loading,
                error: error,
                isEmpty: false,
                emptyMessage: l10n.routesEmpty,
                onRefresh: _refresh,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: 2 +
                      (all.isEmpty ? 1 : visible.length + (hasMore ? 1 : 0)),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Row(
                        children: [
                          Expanded(
                            child: AppStatCard(
                              key: WidgetKeys.routesStatVisited,
                              value: '${stats.visited}',
                              label: l10n.routesStatVisited,
                              valueColor: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppStatCard(
                              key: WidgetKeys.routesStatCities,
                              value: '${stats.cities}',
                              label: l10n.routesStatCities,
                              valueColor: AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppStatCard(
                              key: WidgetKeys.routesStatPlans,
                              value: '${stats.plans}',
                              label: l10n.routesStatPlans,
                              valueColor: AppColors.purple,
                            ),
                          ),
                        ],
                      );
                    }
                    if (index == 1) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: AppSectionLabel(text: l10n.routesHistoryHeading),
                      );
                    }
                    if (all.isEmpty) {
                      return Text(
                        l10n.routesEmpty,
                        key: WidgetKeys.routesEmpty,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.muted,
                        ),
                      );
                    }
                    final itemIndex = index - 2;
                    if (itemIndex >= visible.length) {
                      return TextButton(
                        onPressed: () {
                          setState(() {
                            _visible += PagedItems.defaultPageSize;
                          });
                        },
                        child: Text(context.l10n.actionLoadMore),
                      );
                    }
                    final e = visible[itemIndex];
                    final isLast = itemIndex == visible.length - 1 && !hasMore;
                    return _RouteTimelineTile(
                      key: WidgetKeys.routesItem(e.stopId),
                      entry: e,
                      isLast: isLast,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => PlanDetailPage(
                              planId: e.planId,
                              repository: ref.read(plansRepositoryProvider),
                            ),
                          ),
                        );
                      },
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

class _RouteTimelineTile extends StatelessWidget {
  const _RouteTimelineTile({
    super.key,
    required this.entry,
    required this.isLast,
    required this.onTap,
  });

  final RouteHistoryEntry entry;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final place = [
      if (entry.city != null && entry.city!.isNotEmpty) entry.city!,
      formatDateDmY(entry.visitedAt),
    ].join(' · ');

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 32,
              child: Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.25),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: AppColors.success,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 1,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: AppColors.border,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Material(
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: SiteCover(seed: entry.siteId),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.siteName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.foreground,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                place.isEmpty ? entry.planTitle : place,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.mutedDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
