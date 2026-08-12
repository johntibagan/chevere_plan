import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/cache/paged_items.dart';
import '../../../core/di/providers.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/formatters/money_format.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/prefetch/site_prefetch.dart';
import '../../../core/widgets/app_list_card.dart';
import '../../../core/widgets/visibility_badge.dart';
import '../../saves/data/site_ficha.dart';
import '../../saves/presentation/open_site_detail.dart';
import '../data/search_models.dart';
import '../data/search_repository.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key, required this.repository});

  final SearchRepository repository;

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _queryCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _radiusCtrl = TextEditingController(text: '10');
  final _budgetMinCtrl = TextEditingController();
  final _budgetMaxCtrl = TextEditingController();

  bool _advanced = false;
  String? _categoryId;
  String? _transportGroup;
  bool _includePublic = true;
  bool _useMyLocation = false;
  bool _loading = false;
  List<SearchHit> _hits = const [];
  bool _searched = false;
  int _visibleCount = PagedItems.defaultPageSize;

  @override
  void dispose() {
    _queryCtrl.dispose();
    _locationCtrl.dispose();
    _radiusCtrl.dispose();
    _budgetMinCtrl.dispose();
    _budgetMaxCtrl.dispose();
    super.dispose();
  }

  Future<(double?, double?)> _maybeLocation() async {
    if (!_useMyLocation) return (null, null);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return (null, null);
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      return (pos.latitude, pos.longitude);
    } catch (_) {
      return (null, null);
    }
  }

  double? _parseNum(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return null;
    return double.tryParse(t.replaceAll(',', '.'));
  }

  void _invalidateResults() {
    _hits = const [];
    _searched = false;
    _visibleCount = PagedItems.defaultPageSize;
  }

  Future<void> _runSearch() async {
    final text = _queryCtrl.text.trim();
    if (!_advanced && text.isEmpty) {
      AppToast.show(context, context.l10n.searchQueryRequired, error: true);
      setState(() {
        _hits = const [];
        _searched = true;
      });
      return;
    }

    setState(() {
      _loading = true;
      _searched = true;
      _hits = const [];
      _visibleCount = PagedItems.defaultPageSize;
    });

    try {
      final loc = await _maybeLocation();
      final locationExtra = _locationCtrl.text.trim();
      final hits = await widget.repository.search(
        SearchFilters(
          query: text.isEmpty ? null : text,
          categoryId: _advanced ? _categoryId : null,
          locationQuery: _advanced
              ? (locationExtra.isNotEmpty
                  ? locationExtra
                  : (text.isNotEmpty ? text : null))
              : null,
          lat: _advanced ? loc.$1 : null,
          lng: _advanced ? loc.$2 : null,
          radiusKm: _advanced && _useMyLocation
              ? _parseNum(_radiusCtrl.text)
              : null,
          transportGroup: _advanced ? _transportGroup : null,
          budgetMin: _advanced ? _parseNum(_budgetMinCtrl.text) : null,
          budgetMax: _advanced ? _parseNum(_budgetMaxCtrl.text) : null,
          includePublic: _includePublic,
        ),
      );
      if (!mounted) return;
      setState(() {
        _hits = hits;
        _loading = false;
      });
      ref.read(sitePrefetchProvider).scheduleVisibleSites(
            hits.map((h) => h.siteId),
          );
    } catch (e, st) {
      if (!mounted) return;
      setState(() => _loading = false);
      AppToast.error(context, e, stackTrace: st, logContext: 'search');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final categories = ref.watch(categoriesProvider).valueOrNull ?? const [];
    final roots = categories.where((c) => c.isRoot).toList();
    final children = categories.where((c) => !c.isRoot).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.searchTitle),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _advanced = !_advanced;
                _hits = const [];
                _searched = false;
              });
            },
            child: Text(_advanced ? 'Simple' : 'Avanzada'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          Text(
            _advanced ? 'Búsqueda avanzada' : 'Búsqueda general',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _queryCtrl,
            decoration: InputDecoration(
              labelText:
                  _advanced ? 'Texto (nombre o ciudad)' : l10n.actionSearch,
              hintText: 'Ej. Tunja',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.search),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _runSearch(),
          ),
          if (_advanced) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _locationCtrl,
              decoration: const InputDecoration(
                labelText: 'Ciudad o departamento (extra)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  isExpanded: true,
                  value: _categoryId,
                  hint: const Text('Cualquiera'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Cualquiera'),
                    ),
                    ...roots.map(
                      (r) => DropdownMenuItem<String?>(
                        value: r.id,
                        child: Text(r.nameEs),
                      ),
                    ),
                    ...children.map(
                      (c) => DropdownMenuItem<String?>(
                        value: c.id,
                        child: Text('  ${c.nameEs}'),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() {
                    _categoryId = v;
                    _invalidateResults();
                  }),
                ),
              ),
            ),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Transporte',
                border: OutlineInputBorder(),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  isExpanded: true,
                  value: _transportGroup,
                  hint: const Text('Cualquiera'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Cualquiera')),
                    DropdownMenuItem(
                      value: 'particular',
                      child: Text('Particular'),
                    ),
                    DropdownMenuItem(
                      value: 'publico',
                      child: Text('Público'),
                    ),
                    DropdownMenuItem(value: 'otro', child: Text('Otro')),
                  ],
                  onChanged: (v) => setState(() {
                    _transportGroup = v;
                    _invalidateResults();
                  }),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _budgetMinCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Presupuesto min',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _budgetMaxCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Presupuesto max',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Usar mi ubicación + radio'),
              value: _useMyLocation,
              onChanged: (v) => setState(() {
                _useMyLocation = v;
                _invalidateResults();
              }),
            ),
            if (_useMyLocation)
              TextField(
                controller: _radiusCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Radio (km)',
                  border: OutlineInputBorder(),
                ),
              ),
            Text(
              'Horario: cuando los sitios tengan horario oficial.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Incluir sitios públicos'),
            value: _includePublic,
            onChanged: (v) => setState(() {
              _includePublic = v;
              _invalidateResults();
            }),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _loading
                      ? null
                      : () {
                          _queryCtrl.clear();
                          _locationCtrl.clear();
                          _budgetMinCtrl.clear();
                          _budgetMaxCtrl.clear();
                          _radiusCtrl.text = '10';
                          setState(() {
                            _categoryId = null;
                            _transportGroup = null;
                            _useMyLocation = false;
                            _includePublic = true;
                            _hits = const [];
                            _searched = false;
                          });
                        },
                  child: const Text('Limpiar'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: _loading ? null : _runSearch,
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search),
                  label: Text(
                    _loading ? l10n.searchSearching : l10n.actionSearch,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          if (!_searched)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(l10n.searchEmptyHint),
            )
          else if (_hits.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(l10n.searchNoResults),
            )
          else
            ...() {
              final visible = _hits.take(_visibleCount).toList();
              final hasMore = _visibleCount < _hits.length;
              return [
                ...visible.map(
                  (h) => AppListCard(
                    child: ListTile(
                      title: Text(h.name),
                      subtitle: Text(
                        [
                          if (h.city != null && h.city!.isNotEmpty) h.city!,
                          if (h.department != null && h.department!.isNotEmpty)
                            h.department!,
                          if (h.estimatedPriceAmount != null)
                            formatMoney(
                              h.estimatedPriceAmount!,
                              currencyCode: h.currencyCode,
                            ),
                          if (h.distanceKm != null)
                            '${h.distanceKm!.toStringAsFixed(1)} km',
                          if (h.isOwn) l10n.labelOwn,
                        ].join(' · '),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!h.isOwn)
                            const VisibilityBadge(isPublic: true, compact: true),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                      onTap: () async {
                        final outcome = await openSiteDetail(
                          context,
                          hit: h,
                          siteId: h.siteId,
                        );
                        if (outcome != SiteDetailOutcome.none && mounted) {
                          await _runSearch();
                        }
                      },
                    ),
                  ),
                ),
                if (hasMore)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _visibleCount += PagedItems.defaultPageSize;
                      });
                    },
                    child: Text(
                      'Cargar más (${_hits.length - _visibleCount} restantes)',
                    ),
                  ),
              ];
            }(),
        ],
      ),
    );
  }
}
