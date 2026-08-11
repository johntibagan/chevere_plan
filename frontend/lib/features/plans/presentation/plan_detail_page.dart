import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/user_facing_error.dart';
import '../../../core/formatters/money_format.dart';
import '../data/maps_export.dart';
import '../data/plan_builder.dart';
import '../data/plan_models.dart';
import '../data/plans_repository.dart';
import '../data/transport_suggester.dart';

class PlanDetailPage extends ConsumerStatefulWidget {
  const PlanDetailPage({
    super.key,
    required this.planId,
    required this.repository,
  });

  final String planId;
  final PlansRepository repository;

  @override
  ConsumerState<PlanDetailPage> createState() => _PlanDetailPageState();
}

class _PlanDetailPageState extends ConsumerState<PlanDetailPage> {
  Plan? _plan;
  TransportSuggester? _suggester;
  bool _loading = true;
  String? _error;

  /// Paradas marcadas para incluir en Maps (orden = sort_order del plan).
  final Set<String> _mapsSelectedIds = {};

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
      final plan = await widget.repository.fetchById(widget.planId);
      final transports = await ref.read(transportTypesProvider.future);
      if (!mounted) return;
      setState(() {
        _plan = plan;
        _suggester = TransportSuggester(types: transports);
        _syncSelectionWithPlan(plan);
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

  /// Por defecto: pendientes (no visitados). Conserva selección previa válida.
  void _syncSelectionWithPlan(Plan plan) {
    final validIds = plan.stops.map((s) => s.id).toSet();
    _mapsSelectedIds.removeWhere((id) => !validIds.contains(id));
    if (_mapsSelectedIds.isEmpty) {
      for (final s in plan.stops) {
        if (!s.isVisited) _mapsSelectedIds.add(s.id);
      }
    }
  }

  List<PlanStop> get _selectedStopsInOrder {
    final plan = _plan;
    if (plan == null) return const [];
    return plan.stops
        .where((s) => _mapsSelectedIds.contains(s.id))
        .toList();
  }

  String get _routePreview {
    final selected = _selectedStopsInOrder;
    if (selected.isEmpty) return 'Ninguna parada seleccionada para Maps';
    final names = selected.map((s) => s.siteName).join(' → ');
    return 'Ruta a Maps (${selected.length}): Mi ubicación → $names';
  }

  void _toggleMapsSelect(PlanStop stop) {
    setState(() {
      if (_mapsSelectedIds.contains(stop.id)) {
        _mapsSelectedIds.remove(stop.id);
      } else {
        _mapsSelectedIds.add(stop.id);
      }
    });
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    final plan = _plan;
    if (plan == null) return;
    final stops = List<PlanStop>.from(plan.stops);
    final item = stops.removeAt(oldIndex);
    final insertAt = newIndex.clamp(0, stops.length);
    stops.insert(insertAt, item);
    setState(() {
      _plan = Plan(
        id: plan.id,
        userId: plan.userId,
        title: plan.title,
        locationQuery: plan.locationQuery,
        startLat: plan.startLat,
        startLng: plan.startLng,
        includePublic: plan.includePublic,
        maxBudgetAmount: plan.maxBudgetAmount,
        currencyCode: plan.currencyCode,
        status: plan.status,
        stops: [
          for (var i = 0; i < stops.length; i++)
            stops[i].copyWith(sortOrder: i),
        ],
      );
    });
    try {
      await widget.repository.reorderStops(
        planId: plan.id,
        ordered: _plan!.stops,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
      await _load();
    }
  }

  Future<void> _toggleVisited(PlanStop stop) async {
    final willVisit = !stop.isVisited;
    try {
      await widget.repository.setVisited(
        stopId: stop.id,
        visited: willVisit,
      );
      // Visitado → sale de la ruta a Maps; pendiente → se puede volver a incluir.
      setState(() {
        if (willVisit) {
          _mapsSelectedIds.remove(stop.id);
        } else {
          _mapsSelectedIds.add(stop.id);
        }
      });
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    }
  }

  Future<void> _editPrice(PlanStop stop) async {
    final ctrl = TextEditingController(
      text: stop.displayPrice?.toStringAsFixed(0) ?? '',
    );
    final amount = await showDialog<double?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Estimado por persona'),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'COP (vacío = sin estimado)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final t = ctrl.text.trim();
              if (t.isEmpty) {
                Navigator.pop(context, -1.0);
                return;
              }
              final v = double.tryParse(t.replaceAll(',', '.'));
              Navigator.pop(context, v);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (amount == null) return;
    try {
      await widget.repository.setStopEstimatedPrice(
        stopId: stop.id,
        amount: amount < 0 ? null : amount,
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    }
  }

  Future<(double, double)?> _originForMaps() async {
    final plan = _plan;
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
          ),
        );
        return (pos.latitude, pos.longitude);
      }
    } catch (_) {}
    if (plan?.startLat != null && plan?.startLng != null) {
      return (plan!.startLat!, plan.startLng!);
    }
    return null;
  }

  Future<void> _sendToMaps() async {
    final plan = _plan;
    if (plan == null) return;

    final selected = _selectedStopsInOrder;
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos una parada para enviar a Maps.'),
        ),
      );
      return;
    }

    final missingCoords =
        selected.where((s) => s.lat == null || s.lng == null).toList();
    if (missingCoords.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Falta ubicación en: ${missingCoords.map((s) => s.siteName).join(', ')}',
          ),
        ),
      );
      return;
    }

    final origin = await _originForMaps();
    if (origin == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Activa la ubicación o define un punto de inicio para exportar.',
          ),
        ),
      );
      return;
    }

    try {
      final ok = await openGoogleMapsDirections(
        originLat: origin.$1,
        originLng: origin.$2,
        stopsInOrder: selected,
      );
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(kGenericAppError)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    }
  }

  String _legTransportLabel(double? fromLat, double? fromLng, PlanStop to) {
    final suggester = _suggester;
    if (suggester == null ||
        fromLat == null ||
        fromLng == null ||
        to.lat == null ||
        to.lng == null) {
      return '';
    }
    final km = haversineKm(
      LatLngPoint(fromLat, fromLng),
      LatLngPoint(to.lat!, to.lng!),
    );
    final opts = suggester.suggestForDistanceKm(km);
    if (opts.isEmpty) return '${km.toStringAsFixed(1)} km';
    return '${km.toStringAsFixed(1)} km · ${opts.map((t) => t.nameEs).join(' / ')}';
  }

  @override
  Widget build(BuildContext context) {
    final plan = _plan;
    final selectedCount = _selectedStopsInOrder.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(plan?.title ?? 'Plan'),
        actions: [
          if (plan != null)
            IconButton(
              tooltip: 'Enviar a Maps',
              onPressed: _sendToMaps,
              icon: const Icon(Icons.map_outlined),
            ),
        ],
      ),
      floatingActionButton: plan == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _sendToMaps,
              icon: const Icon(Icons.directions),
              label: Text(
                selectedCount == 0
                    ? 'Enviar a Maps'
                    : 'Enviar a Maps ($selectedCount)',
              ),
            ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_error!, textAlign: TextAlign.center),
                  ),
                )
              : plan == null
                  ? const SizedBox.shrink()
                  : Column(
                      children: [
                        Material(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.route,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _routePreview,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: _load,
                            child: ReorderableListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 12, 16, 96),
                              itemCount: plan.stops.length + 1,
                              onReorderItem: (oldIndex, newIndex) {
                                if (oldIndex == 0 || newIndex == 0) return;
                                _onReorder(oldIndex - 1, newIndex - 1);
                              },
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return Card(
                                    key: const ValueKey('header'),
                                    child: ListTile(
                                      title: Text(plan.locationQuery),
                                      subtitle: Text(
                                        [
                                          if (plan.includePublic)
                                            'Incluye públicos',
                                          if (plan.maxBudgetAmount != null)
                                            'Tope ${formatMoney(plan.maxBudgetAmount!, currencyCode: plan.currencyCode)}',
                                          '${plan.stops.length} paradas',
                                          'Marca el check para incluir en Maps',
                                        ].join(' · '),
                                      ),
                                    ),
                                  );
                                }
                                final stop = plan.stops[index - 1];
                                double? fromLat = plan.startLat;
                                double? fromLng = plan.startLng;
                                if (index > 1) {
                                  final prev = plan.stops[index - 2];
                                  fromLat = prev.lat;
                                  fromLng = prev.lng;
                                }
                                final leg = _legTransportLabel(
                                  fromLat,
                                  fromLng,
                                  stop,
                                );
                                final inMaps =
                                    _mapsSelectedIds.contains(stop.id);
                                return Card(
                                  key: ValueKey(stop.id),
                                  child: ListTile(
                                    leading: Checkbox(
                                      value: inMaps,
                                      onChanged: (_) =>
                                          _toggleMapsSelect(stop),
                                    ),
                                    title: Text(
                                      '${stop.sortOrder + 1}. ${stop.siteName}',
                                      style: TextStyle(
                                        decoration: stop.isVisited
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    subtitle: Text(
                                      [
                                        if (stop.city != null) stop.city!,
                                        if (leg.isNotEmpty) leg,
                                        if (stop.displayPrice != null)
                                          'Estimado: ${formatMoney(stop.displayPrice!, currencyCode: plan.currencyCode)}',
                                        if (stop.isVisited) 'Visitado',
                                        if (stop.lat == null ||
                                            stop.lng == null)
                                          'Sin coordenadas',
                                      ].join(' · '),
                                    ),
                                    isThreeLine: true,
                                    trailing: Wrap(
                                      spacing: 0,
                                      children: [
                                        IconButton(
                                          tooltip: stop.isVisited
                                              ? 'Marcar pendiente'
                                              : 'Marcar visitado',
                                          onPressed: () =>
                                              _toggleVisited(stop),
                                          icon: Icon(
                                            stop.isVisited
                                                ? Icons.check_circle
                                                : Icons.check_circle_outline,
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'Estimado',
                                          onPressed: () => _editPrice(stop),
                                          icon: const Icon(
                                            Icons.payments_outlined,
                                          ),
                                        ),
                                        const Icon(Icons.drag_handle),
                                      ],
                                    ),
                                    onTap: () => _toggleMapsSelect(stop),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }
}
