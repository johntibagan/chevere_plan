import 'package:flutter/material.dart';

import '../../../core/l10n/context_l10n.dart';
import '../../../core/logging/app_log.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_form_card.dart';
import '../../../core/widgets/app_search_field.dart';
import '../../admin/data/admin_models.dart';

/// Pantalla/popup para elegir categorías (árbol + filtro por keywords).
Future<Set<String>?> showCategoryPickerSheet({
  required BuildContext context,
  required List<Category> categories,
  required Set<String> selectedIds,
}) {
  return Navigator.of(context).push<Set<String>>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => CategoryPickerPage(
        categories: categories,
        initialSelected: selectedIds,
      ),
    ),
  );
}

class CategoryPickerPage extends StatefulWidget {
  const CategoryPickerPage({
    super.key,
    required this.categories,
    required this.initialSelected,
  });

  final List<Category> categories;
  final Set<String> initialSelected;

  @override
  State<CategoryPickerPage> createState() => _CategoryPickerPageState();
}

class _CategoryPickerPageState extends State<CategoryPickerPage> {
  late final Set<String> _selected;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = {...widget.initialSelected};
    assert(() {
      final roots = widget.categories.where((c) => c.parentId == null).length;
      AppLog.debug(
        'CategoryPicker: total=${widget.categories.length} roots=$roots',
        name: 'categories',
      );
      return true;
    }());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Category> get _roots {
    final list = widget.categories
        .where((c) => c.parentId == null && c.isActive)
        .toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  List<Category> _childrenOf(String parentId) {
    final list = widget.categories
        .where((c) => c.parentId == parentId && c.isActive)
        .toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  String _parentName(Category c) {
    if (c.parentId == null) return '';
    for (final p in widget.categories) {
      if (p.id == c.parentId) return p.nameEs;
    }
    return '';
  }

  bool _matches(Category c, String q) {
    if (q.isEmpty) return true;
    if (c.matchesQuery(q)) return true;
    for (final p in widget.categories) {
      if (p.id == c.parentId && p.matchesQuery(q)) return true;
    }
    return _parentName(c).toLowerCase().contains(q);
  }

  List<Category> get _filteredFlat {
    final q = _searchCtrl.text.trim().toLowerCase();
    final hits = widget.categories
        .where((c) => c.isActive && _matches(c, q))
        .toList();
    hits.sort((a, b) {
      final aRoot = a.parentId == null;
      final bRoot = b.parentId == null;
      if (aRoot != bRoot) return aRoot ? 1 : -1;
      return a.nameEs.compareTo(b.nameEs);
    });
    return hits;
  }

  void _toggle(String id, bool? value) {
    setState(() {
      if (value == true) {
        _selected.add(id);
      } else {
        _selected.remove(id);
      }
    });
  }

  Color _colorOf(Category c) {
    final raw = c.colorHex?.replaceAll('#', '');
    if (raw == null || raw.length < 6) return AppColors.primary;
    final hex = raw.length == 6 ? 'FF$raw' : raw;
    final v = int.tryParse(hex, radix: 16);
    return v == null ? AppColors.primary : Color(v);
  }

  Widget _catRow({
    required Category c,
    required String label,
    required bool selected,
  }) {
    final color = _colorOf(c);
    final kws = c.keywords.take(3).join(', ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppFormCard(
        onTap: () => _toggle(c.id, !selected),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.16),
              ),
              child: Icon(Icons.category_outlined, size: 18, color: color),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: selected ? color : AppColors.foreground,
                    ),
                  ),
                  if (kws.isNotEmpty)
                    Text(
                      kws,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.mutedDark,
                      ),
                    ),
                ],
              ),
            ),
            if (selected) Icon(Icons.check, color: color, size: 18),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filtering = _searchCtrl.text.trim().isNotEmpty;
    final roots = _roots;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminTabCategories),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, Set<String>.from(_selected)),
            child: Text(
              '${l10n.actionDone} (${_selected.length})',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: AppSearchField(
              controller: _searchCtrl,
              hint: l10n.saveCategoryHint,
              searchTooltip: l10n.actionSearch,
              onSearch: () => setState(() {}),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              filtering
                  ? l10n.categoryPickerResults(_filteredFlat.length)
                  : l10n.categoryPickerSummary(
                      widget.categories.length,
                      roots.length,
                    ),
              style: TextStyle(fontSize: 11, color: AppColors.muted),
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child: filtering ? _buildFilteredList() : _buildTree(roots),
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredList() {
    final l10n = context.l10n;
    final hits = _filteredFlat;
    if (hits.isEmpty) {
      return Center(child: Text(l10n.saveCategoryNone));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: hits.length,
      itemBuilder: (context, index) {
        final c = hits[index];
        final parent = _parentName(c);
        final label = parent.isEmpty ? c.nameEs : '$parent › ${c.nameEs}';
        return _catRow(
          c: c,
          label: label,
          selected: _selected.contains(c.id),
        );
      },
    );
  }

  Widget _buildTree(List<Category> roots) {
    final l10n = context.l10n;
    if (widget.categories.isEmpty) {
      return Center(child: Text(l10n.saveCategoryNone));
    }

    if (roots.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          final c = widget.categories[index];
          final parent = _parentName(c);
          final label = parent.isEmpty ? c.nameEs : '$parent › ${c.nameEs}';
          return _catRow(
            c: c,
            label: label,
            selected: _selected.contains(c.id),
          );
        },
      );
    }

    final tiles = <Widget>[];
    for (final root in roots) {
      final children = _childrenOf(root.id);
      final color = _colorOf(root);
      tiles.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.16),
                ),
                child: Icon(Icons.folder_outlined, size: 14, color: color),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  root.nameEs,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.foreground,
                  ),
                ),
              ),
              if (children.isNotEmpty)
                IconButton(
                  tooltip: l10n.categoryPickerSelectGroup,
                  icon: Icon(Icons.done_all, size: 18),
                  onPressed: () {
                    setState(() {
                      for (final c in children) {
                        _selected.add(c.id);
                      }
                    });
                  },
                ),
            ],
          ),
        ),
      );
      for (final c in children) {
        tiles.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _catRow(
              c: c,
              label: c.nameEs,
              selected: _selected.contains(c.id),
            ),
          ),
        );
      }
    }

    return ListView(children: tiles);
  }
}
