import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/errors/user_facing_error.dart';
import '../../admin/data/admin_models.dart';
import '../../admin/data/admin_repository.dart';
import '../data/search_models.dart';
import '../data/search_repository.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.repository});

  final SearchRepository repository;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _adminRepo = AdminRepository();
  final _queryCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _radiusCtrl = TextEditingController(text: '10');
  final _budgetMinCtrl = TextEditingController();
  final _budgetMaxCtrl = TextEditingController();

  bool _advanced = false;
  List<Category> _categories = const [];
  String? _categoryId;
  String? _transportGroup;
  bool _includePublic = true;
  bool _useMyLocation = false;
  bool _loading = false;
  String? _error;
  List<SearchHit> _hits = const [];
  bool _searched = false;

  @override
  void initState() {
    super.initState();
    _loadMeta();
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    _locationCtrl.dispose();
    _radiusCtrl.dispose();
    _budgetMinCtrl.dispose();
    _budgetMaxCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMeta() async {
    try {
      final cats = await _adminRepo.fetchCategories();
      if (!mounted) return;
      setState(() => _categories = cats);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('search categories: $e');
      }
    }
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

  Future<void> _runSearch() async {
    final text = _queryCtrl.text.trim();
    if (!_advanced && text.isEmpty) {
      setState(() {
        _error = 'Escribe algo para buscar.';
        _hits = const [];
        _searched = true;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _searched = true;
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
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('search error: $e\n$st');
      }
      if (!mounted) return;
      setState(() {
        _error = userFacingError(e, stackTrace: st, context: 'search');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final roots = _categories.where((c) => c.isRoot).toList();
    final children = _categories.where((c) => !c.isRoot).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _advanced = !_advanced;
                _error = null;
              });
            },
            child: Text(_advanced ? 'Simple' : 'Avanzada'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text(
            _advanced ? 'Búsqueda avanzada' : 'Búsqueda general',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _queryCtrl,
            decoration: InputDecoration(
              labelText: _advanced ? 'Texto (nombre o ciudad)' : 'Buscar',
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
                  onChanged: (v) => setState(() => _categoryId = v),
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
                  onChanged: (v) => setState(() => _transportGroup = v),
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
              onChanged: (v) => setState(() => _useMyLocation = v),
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
            onChanged: (v) => setState(() => _includePublic = v),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _loading ? null : _runSearch,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: Text(_loading ? 'Buscando…' : 'Buscar'),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            )
          else if (!_searched)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Escribe y pulsa Buscar.'),
            )
          else if (_hits.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Sin resultados.'),
            )
          else
            ..._hits.map(
              (h) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(h.name),
                  subtitle: Text(
                    [
                      if (h.city != null && h.city!.isNotEmpty) h.city!,
                      if (h.department != null && h.department!.isNotEmpty)
                        h.department!,
                      if (h.estimatedPriceAmount != null)
                        '${h.estimatedPriceAmount!.toStringAsFixed(0)} ${h.currencyCode}',
                      if (h.distanceKm != null)
                        '${h.distanceKm!.toStringAsFixed(1)} km',
                      h.isOwn ? 'Tuyo' : 'Público',
                    ].join(' · '),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
