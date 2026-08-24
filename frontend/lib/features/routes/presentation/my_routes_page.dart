import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/paged_items.dart';
import '../../../core/di/providers.dart';
import '../../../core/formatters/date_format.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/prefetch/site_prefetch.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_async_body.dart';
import '../../../core/widgets/app_toast.dart';
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

    final cities = all
        .map((e) => e.city?.trim() ?? '')
        .where((c) => c.isNotEmpty)
        .toSet()
        .length;
    final planCount = all.map((e) => e.planId).toSet().length;

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
                            child: _StatTile(
                              value: '${all.length}',
                              label: l10n.routesStatVisited,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _StatTile(
                              value: '$cities',
                              label: l10n.routesStatCities,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _StatTile(
                              value: '$planCount',
                              label: l10n.routesStatPlans,
                            ),
                          ),
                        ],
                      );
                    }
                    if (index == 1) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 12),
                        child: Text(
                          l10n.routesHistoryHeading,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.foreground,
                          ),
                        ),
                      );
                    }
                    if (all.isEmpty) {
                      return Text(
                        l10n.routesEmpty,
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

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteTimelineTile extends StatelessWidget {
  const _RouteTimelineTile({
    required this.entry,
    required this.isLast,
    required this.onTap,
  });

  final RouteHistoryEntry entry;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColors.primary.withValues(alpha: 0.35),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
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
                    padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.siteName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.foreground,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                [
                                  entry.planTitle,
                                  if (entry.city != null &&
                                      entry.city!.isNotEmpty)
                                    entry.city!,
                                  formatDateDmY(entry.visitedAt),
                                ].join(' · '),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.muted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
