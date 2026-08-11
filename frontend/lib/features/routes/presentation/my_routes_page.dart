import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/user_facing_error.dart';
import '../../../core/formatters/date_format.dart';
import '../../../core/l10n/context_l10n.dart';
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
  bool _loading = true;
  String? _error;
  List<RouteHistoryEntry> _entries = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final entries = await widget.repository.listMine();
      if (!mounted) return;
      setState(() {
        _entries = entries;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = userFacingError(e);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.routesTitle)),
      body: AppAsyncBody(
        loading: _loading,
        error: _error,
        isEmpty: _entries.isEmpty,
        emptyMessage: l10n.routesEmpty,
        onRefresh: _load,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: _entries.length,
          itemBuilder: (context, index) {
            final e = _entries[index];
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
