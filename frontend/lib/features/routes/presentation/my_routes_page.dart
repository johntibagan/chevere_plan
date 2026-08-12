import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/paged_items.dart';
import '../../../core/di/providers.dart';
import '../../../core/formatters/date_format.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/prefetch/site_prefetch.dart';
import '../../../core/widgets/app_async_body.dart';
import '../../../core/widgets/app_list_card.dart';
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
      appBar: AppBar(title: Text(l10n.routesTitle)),
      body: AppAsyncBody(
        loading: loading,
        error: error,
        isEmpty: all.isEmpty,
        emptyMessage: l10n.routesEmpty,
        onRefresh: _refresh,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: visible.length + (hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= visible.length) {
              return TextButton(
                onPressed: () {
                  setState(() {
                    _visible += PagedItems.defaultPageSize;
                  });
                },
                child: Text(context.l10n.actionLoadMore),
              );
            }
            final e = visible[index];
            return AppListCard(
              child: ListTile(
                title: Text(e.siteName),
                subtitle: Text(
                  [
                    e.planTitle,
                    if (e.city != null && e.city!.isNotEmpty) e.city!,
                    formatDateDmY(e.visitedAt),
                  ].join(' · '),
                ),
                trailing: const Icon(Icons.chevron_right),
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
              ),
            );
          },
        ),
      ),
    );
  }
}
