import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/cache_ttl.dart';
import '../../../core/di/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_form_card.dart';
import '../../../core/widgets/app_stat_card.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/testing/widget_keys.dart';
import '../../moderation/presentation/admin_reports_page.dart';
import '../data/admin_models.dart';
import '../data/admin_repository.dart';

/// Panel admin mínimo Ciclo 1: categorías + vehículos (especificación §12 / Figma admin).
class AdminPage extends ConsumerStatefulWidget {
  const AdminPage({super.key, required this.repository});

  final AdminRepository repository;

  @override
  ConsumerState<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends ConsumerState<AdminPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  List<Category> _categories = [];
  List<TransportType> _transports = [];
  int _openReports = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cats = await widget.repository.fetchCategories();
      final txs = await widget.repository.fetchTransportTypes();
      final reports =
          await ref.read(moderationRepositoryProvider).listOpenReports();
      if (!mounted) return;
      setState(() {
        _categories = cats;
        _transports = txs;
        _openReports = reports.length;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'failed';
        _loading = false;
      });
      AppToast.error(context, e, logContext: 'admin');
    }
  }

  Future<void> _editCategory(Category cat) async {
    final nameCtrl = TextEditingController(text: cat.nameEs);
    final keywordsCtrl = TextEditingController(text: cat.keywords.join(', '));
    var active = cat.isActive;
    var ageRestricted = cat.ageRestricted;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: Text(
                cat.isRoot
                    ? context.l10n.adminEditCategory
                    : context.l10n.adminEditSubcategory,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: context.l10n.adminNameEs,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: keywordsCtrl,
                      decoration: InputDecoration(
                        labelText: context.l10n.adminKeywords,
                        helperText: context.l10n.adminKeywordsHint,
                      ),
                      maxLines: 3,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(context.l10n.adminActive),
                      value: active,
                      onChanged: (v) => setLocal(() => active = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(context.l10n.adminAgeRestricted),
                      value: ageRestricted,
                      onChanged: (v) => setLocal(() => ageRestricted = v),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(context.l10n.actionCancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(context.l10n.actionSave),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved != true) return;
    final keywords = keywordsCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    try {
      await widget.repository.updateCategory(
        cat.id,
        nameEs: nameCtrl.text.trim(),
        isActive: active,
        ageRestricted: ageRestricted,
        keywords: keywords,
      );
      ref.invalidate(categoriesProvider);
      unawaited(
        ref.read(entityCacheStoreProvider).invalidate(CacheKeys.categories()),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, e);
    }
  }

  Future<void> _editTransport(TransportType tx) async {
    final nameCtrl = TextEditingController(text: tx.nameEs);
    final kmCtrl = TextEditingController(
      text: tx.defaultMaxKm?.toString() ?? '',
    );
    var active = tx.isActive;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: Text(context.l10n.adminEditTransport),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: context.l10n.adminNameEs,
                    ),
                  ),
                  TextField(
                    controller: kmCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: context.l10n.adminTransportMaxKm,
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.adminTransportActive),
                    value: active,
                    onChanged: (v) => setLocal(() => active = v),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(context.l10n.actionCancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(context.l10n.actionSave),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved != true) return;
    final kmText = kmCtrl.text.trim();
    final clearKm = kmText.isEmpty;
    final km = clearKm ? null : double.tryParse(kmText.replaceAll(',', '.'));
    if (!clearKm && km == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.adminKmInvalid)),
      );
      return;
    }

    try {
      await widget.repository.updateTransportType(
        tx.id,
        nameEs: nameCtrl.text.trim(),
        isActive: active,
        defaultMaxKm: km,
        clearMaxKm: clearKm,
      );
      ref.invalidate(transportTypesProvider);
      unawaited(
        ref
            .read(entityCacheStoreProvider)
            .invalidate(CacheKeys.transportTypes()),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      key: WidgetKeys.adminPage,
      appBar: AppBar(
        title: Text(l10n.adminTitle),
        actions: [
          IconButton(
            tooltip: l10n.reportsTitle,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AdminReportsPage(
                    repository: ref.read(moderationRepositoryProvider),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.flag_outlined),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            Tab(text: l10n.adminTabCategories),
            Tab(text: l10n.adminTabVehicles),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.errorLoadRetry,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _load,
                          child: Text(l10n.actionRetry),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: AppStatCard(
                              value: '${_categories.length}',
                              label: l10n.adminStatCategories,
                              valueColor: AppColors.primary,
                              icon: Icons.category_outlined,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppStatCard(
                              value: '${_transports.length}',
                              label: l10n.adminStatVehicles,
                              valueColor: AppColors.success,
                              icon: Icons.directions_bus_outlined,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppStatCard(
                              value: '$_openReports',
                              label: l10n.adminStatReports,
                              valueColor: AppColors.accent,
                              icon: Icons.flag_outlined,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                  controller: _tabs,
                  children: [
                    _CategoriesTab(
                      categories: _categories,
                      onEdit: _editCategory,
                    ),
                    _TransportsTab(
                      transports: _transports,
                      onEdit: _editTransport,
                    ),
                  ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab({
    required this.categories,
    required this.onEdit,
  });

  final List<Category> categories;
  final ValueChanged<Category> onEdit;

  @override
  Widget build(BuildContext context) {
    final roots = categories.where((c) => c.isRoot).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: roots.length,
      itemBuilder: (context, index) {
        final l10n = context.l10n;
        final root = roots[index];
        final children = categories
            .where((c) => c.parentId == root.id)
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        final hex = root.colorHex?.replaceAll('#', '');
        final color = () {
          if (hex == null || hex.length < 6) return AppColors.primary;
          final v = int.tryParse(hex.length == 6 ? 'FF$hex' : hex, radix: 16);
          return v == null ? AppColors.primary : Color(v);
        }();

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppFormCard(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.18),
                child: Icon(Icons.category_outlined, color: color, size: 18),
              ),
              title: Text(root.nameEs),
              subtitle: Text(
                [
                  root.isActive ? l10n.adminActive : l10n.adminInactive,
                  if (root.ageRestricted) '+18',
                ].join(' · '),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => onEdit(root),
              ),
              children: children
                  .map(
                    (c) => ListTile(
                      contentPadding: const EdgeInsets.only(left: 32, right: 8),
                      title: Text(c.nameEs),
                      subtitle: Text(
                        [
                          c.isActive ? l10n.adminActive : l10n.adminInactive,
                          if (c.ageRestricted) '+18',
                        ].join(' · '),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => onEdit(c),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}

class _TransportsTab extends StatelessWidget {
  const _TransportsTab({
    required this.transports,
    required this.onEdit,
  });

  final List<TransportType> transports;
  final ValueChanged<TransportType> onEdit;

  String _groupLabel(String g) {
    switch (g) {
      case 'particular':
        return 'Particular';
      case 'publico':
        return 'Público';
      case 'otro':
        return 'Otro (plataformas)';
      default:
        return g;
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = ['particular', 'publico', 'otro'];
    return ListView(
      children: [
        for (final g in groups) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              _groupLabel(g),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ...transports.where((t) => t.transportGroup == g).map(
            (t) => ListTile(
              title: Text(t.nameEs),
              subtitle: Text(
                [
                  t.isActive ? 'Activo' : 'Inactivo',
                  t.defaultMaxKm == null
                      ? 'Sin tope km'
                      : 'Máx ${t.defaultMaxKm} km',
                ].join(' · '),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => onEdit(t),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
