import 'package:flutter/material.dart';

import '../../../core/errors/user_facing_error.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/widgets/app_async_body.dart';
import '../../../core/widgets/app_list_card.dart';
import '../data/plan_models.dart';
import '../data/plans_repository.dart';
import 'create_plan_page.dart';
import 'plan_detail_page.dart';

class PlansListPage extends StatefulWidget {
  const PlansListPage({super.key, required this.repository});

  final PlansRepository repository;

  @override
  State<PlansListPage> createState() => _PlansListPageState();
}

class _PlansListPageState extends State<PlansListPage> {
  bool _loading = true;
  String? _error;
  List<Plan> _plans = const [];

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
      final plans = await widget.repository.listMine();
      if (!mounted) return;
      setState(() {
        _plans = plans;
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

  Future<void> _openCreate() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CreatePlanPage(repository: widget.repository),
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
        loading: _loading,
        error: _error,
        isEmpty: _plans.isEmpty,
        emptyMessage: l10n.plansEmpty,
        onRefresh: _load,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
          itemCount: _plans.length,
          itemBuilder: (context, index) {
            final plan = _plans[index];
            return AppListCard(
              child: ListTile(
                title: Text(plan.title),
                subtitle: Text(
                  '${plan.locationQuery} · ${plan.stops.length} paradas',
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
                  await _load();
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
