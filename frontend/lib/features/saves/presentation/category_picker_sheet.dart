import 'package:flutter/material.dart';

import '../../admin/data/admin_models.dart';

/// Bottom sheet: árbol completo de categorías + buscador (keywords / nombre).
Future<Set<String>?> showCategoryPickerSheet({
  required BuildContext context,
  required List<Category> categories,
  required Set<String> selectedIds,
}) {
  return showModalBottomSheet<Set<String>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _CategoryPickerSheet(
      categories: categories,
      initialSelected: selectedIds,
    ),
  );
}

class _CategoryPickerSheet extends StatefulWidget {
  const _CategoryPickerSheet({
    required this.categories,
    required this.initialSelected,
  });

  final List<Category> categories;
  final Set<String> initialSelected;

  @override
  State<_CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<_CategoryPickerSheet> {
  late final Set<String> _selected;
  final _searchCtrl = TextEditingController();
  final Set<String> _expanded = {};

  @override
  void initState() {
    super.initState();
    _selected = {...widget.initialSelected};
    // Expandir raíces que tienen algo seleccionado.
    for (final c in widget.categories) {
      if (c.parentId != null && _selected.contains(c.id)) {
        _expanded.add(c.parentId!);
      }
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Category> get _roots => widget.categories
      .where((c) => c.isRoot && c.isActive)
      .toList()
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  List<Category> _childrenOf(String parentId) {
    return widget.categories
        .where((c) => c.parentId == parentId && c.isActive)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  String _parentName(Category c) {
    if (c.parentId == null) return '';
    final parent = widget.categories.where((p) => p.id == c.parentId);
    return parent.isEmpty ? '' : parent.first.nameEs;
  }

  bool _matches(Category c, String q) {
    if (q.isEmpty) return true;
    if (c.matchesQuery(q)) return true;
    final parent = widget.categories.where((p) => p.id == c.parentId);
    if (parent.isNotEmpty && parent.first.matchesQuery(q)) return true;
    final parentName = _parentName(c).toLowerCase();
    return parentName.contains(q);
  }

  List<Category> get _filteredFlat {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final hits = widget.categories
        .where((c) => c.isActive && _matches(c, q))
        .toList();
    hits.sort((a, b) {
      // Preferir hojas sobre raíces.
      if (a.isRoot != b.isRoot) return a.isRoot ? 1 : -1;
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

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.88;
    final filtering = _searchCtrl.text.trim().isNotEmpty;

    return SizedBox(
      height: height,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Categorías',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () =>
                      Navigator.pop(context, Set<String>.from(_selected)),
                  child: Text('Listo (${_selected.length})'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'Filtrar: nadar, tejo, plaza, bar…',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: _searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpiar',
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {});
                        },
                      ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          if (_selected.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_selected.length} seleccionada(s)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: filtering
                ? _buildFilteredList()
                : _buildTree(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredList() {
    final hits = _filteredFlat;
    if (hits.isEmpty) {
      return const Center(child: Text('Sin coincidencias'));
    }
    return ListView.builder(
      itemCount: hits.length,
      itemBuilder: (context, index) {
        final c = hits[index];
        final parent = _parentName(c);
        final label = parent.isEmpty ? c.nameEs : '$parent › ${c.nameEs}';
        return CheckboxListTile(
          value: _selected.contains(c.id),
          onChanged: (v) => _toggle(c.id, v),
          title: Text(c.ageRestricted ? '$label (+18)' : label),
          dense: true,
        );
      },
    );
  }

  Widget _buildTree() {
    return ListView.builder(
      itemCount: _roots.length,
      itemBuilder: (context, index) {
        final root = _roots[index];
        final children = _childrenOf(root.id);
        final expanded = _expanded.contains(root.id);
        final selectedCount =
            children.where((c) => _selected.contains(c.id)).length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: Icon(
                expanded ? Icons.expand_more : Icons.chevron_right,
              ),
              title: Text(
                root.nameEs,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: selectedCount > 0
                  ? Text('$selectedCount seleccionada(s)')
                  : Text('${children.length} opciones'),
              trailing: Checkbox(
                tristate: true,
                value: selectedCount == 0
                    ? false
                    : (selectedCount == children.length ? true : null),
                onChanged: children.isEmpty
                    ? null
                    : (v) {
                        setState(() {
                          if (v == true) {
                            for (final c in children) {
                              _selected.add(c.id);
                            }
                            _expanded.add(root.id);
                          } else {
                            for (final c in children) {
                              _selected.remove(c.id);
                            }
                          }
                        });
                      },
              ),
              onTap: () {
                setState(() {
                  if (expanded) {
                    _expanded.remove(root.id);
                  } else {
                    _expanded.add(root.id);
                  }
                });
              },
            ),
            if (expanded)
              ...children.map(
                (c) => CheckboxListTile(
                  contentPadding: const EdgeInsets.only(left: 48, right: 16),
                  dense: true,
                  value: _selected.contains(c.id),
                  onChanged: (v) => _toggle(c.id, v),
                  title: Text(
                    c.ageRestricted ? '${c.nameEs} (+18)' : c.nameEs,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
