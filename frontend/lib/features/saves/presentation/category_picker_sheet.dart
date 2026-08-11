import 'package:flutter/material.dart';

import '../../../core/logging/app_log.dart';
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

  @override
  Widget build(BuildContext context) {
    final filtering = _searchCtrl.text.trim().isNotEmpty;
    final roots = _roots;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, Set<String>.from(_selected)),
            child: Text('Listo (${_selected.length})'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Filtrar: nadar, tejo, plaza, bar…',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: _searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              filtering
                  ? '${_filteredFlat.length} resultado(s)'
                  : '${widget.categories.length} categorías · ${roots.length} grupos',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 4),
          const Divider(height: 1),
          Expanded(
            child: filtering ? _buildFilteredList() : _buildTree(roots),
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
        );
      },
    );
  }

  Widget _buildTree(List<Category> roots) {
    if (widget.categories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No hay categorías cargadas.\n'
            'Cierra, vuelve a abrir Guardar, o aplica el seed SQL en Supabase.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (roots.isEmpty) {
      // Fallback: si no hay raíces detectadas, listar todo plano.
      return ListView.builder(
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          final c = widget.categories[index];
          final parent = _parentName(c);
          final label = parent.isEmpty ? c.nameEs : '$parent › ${c.nameEs}';
          return CheckboxListTile(
            value: _selected.contains(c.id),
            onChanged: (v) => _toggle(c.id, v),
            title: Text(c.ageRestricted ? '$label (+18)' : label),
            subtitle: Text('slug: ${c.slug} · parent: ${c.parentId ?? "null"}'),
          );
        },
      );
    }

    final tiles = <Widget>[];
    for (final root in roots) {
      final children = _childrenOf(root.id);
      tiles.add(
        Material(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: ListTile(
            dense: true,
            title: Text(
              root.nameEs,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text('${children.length} opciones'),
            trailing: children.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Seleccionar todo el grupo',
                    icon: const Icon(Icons.done_all),
                    onPressed: () {
                      setState(() {
                        for (final c in children) {
                          _selected.add(c.id);
                        }
                      });
                    },
                  ),
          ),
        ),
      );
      if (children.isEmpty) {
        tiles.add(
          const ListTile(
            dense: true,
            title: Text('Sin subcategorías'),
          ),
        );
      } else {
        for (final c in children) {
          tiles.add(
            CheckboxListTile(
              value: _selected.contains(c.id),
              onChanged: (v) => _toggle(c.id, v),
              title: Text(
                c.ageRestricted ? '${c.nameEs} (+18)' : c.nameEs,
              ),
            ),
          );
        }
      }
    }

    return ListView(children: tiles);
  }
}
