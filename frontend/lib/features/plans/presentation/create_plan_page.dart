import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/errors/user_facing_error.dart';
import '../../saves/data/nominatim_geocoder.dart';
import '../../saves/presentation/location_picker_page.dart';
import '../data/plan_builder.dart';
import '../data/plans_repository.dart';
import 'plan_detail_page.dart';

class CreatePlanPage extends StatefulWidget {
  const CreatePlanPage({super.key, required this.repository});

  final PlansRepository repository;

  @override
  State<CreatePlanPage> createState() => _CreatePlanPageState();
}

class _CreatePlanPageState extends State<CreatePlanPage> {
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  double? _manualLat;
  double? _manualLng;
  bool _includePublic = false;
  bool _useCurrentLocation = true;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  Future<(double?, double?)> _resolveStart() async {
    if (!_useCurrentLocation) {
      return (_manualLat, _manualLng);
    }
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

  Future<void> _create() async {
    final location = _locationCtrl.text.trim();
    if (location.isEmpty) {
      setState(() => _error = 'Indica una ciudad o departamento.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final budgetText = _budgetCtrl.text.trim();
      final budget = budgetText.isEmpty
          ? null
          : double.tryParse(budgetText.replaceAll(',', '.'));
      if (budgetText.isNotEmpty && budget == null) {
        throw const AppUserError('Presupuesto inválido.');
      }

      final start = await _resolveStart();
      final candidates = await widget.repository.listCandidates(
        locationQuery: location,
        includePublic: _includePublic,
        maxBudget: budget,
      );

      LatLngPoint startPoint;
      if (start.$1 != null && start.$2 != null) {
        startPoint = LatLngPoint(start.$1!, start.$2!);
      } else if (candidates.isNotEmpty) {
        startPoint = candidates.first.point;
      } else {
        throw const AppUserError(
          'No hay lugares para ese destino. Revisa ciudad/departamento o presupuesto.',
        );
      }

      final ordered = nearestNeighborOrder(
        start: startPoint,
        candidates: candidates,
      );

      final plan = await widget.repository.createPlan(
        title: _titleCtrl.text,
        locationQuery: location,
        includePublic: _includePublic,
        maxBudget: budget,
        startLat: start.$1 ?? startPoint.lat,
        startLng: start.$2 ?? startPoint.lng,
        orderedStops: ordered,
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => PlanDetailPage(
            planId: plan.id,
            repository: widget.repository,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = userFacingError(e);
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Armar plan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
              labelText: 'Título (opcional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _locationCtrl,
            decoration: const InputDecoration(
              labelText: 'Ciudad o departamento',
              hintText: 'Ej. Villa de Leyva / Boyacá',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _budgetCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Presupuesto máx. por sitio (COP, opcional)',
              border: OutlineInputBorder(),
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Incluir guardados públicos'),
            value: _includePublic,
            onChanged: _saving
                ? null
                : (v) => setState(() => _includePublic = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Usar mi ubicación actual como inicio'),
            subtitle: const Text(
              'Si está apagado, elige el punto de inicio en el mapa',
            ),
            value: _useCurrentLocation,
            onChanged: _saving
                ? null
                : (v) => setState(() => _useCurrentLocation = v),
          ),
          if (!_useCurrentLocation)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _manualLat != null && _manualLng != null
                    ? 'Inicio: ${_manualLat!.toStringAsFixed(5)}, ${_manualLng!.toStringAsFixed(5)}'
                    : 'Elegir inicio en el mapa',
              ),
              trailing: const Icon(Icons.map_outlined),
              onTap: _saving
                  ? null
                  : () async {
                      final result = await Navigator.of(context).push<GeoPlace>(
                        MaterialPageRoute(
                          builder: (_) => LocationPickerPage(
                            initialLat: _manualLat,
                            initialLng: _manualLng,
                          ),
                        ),
                      );
                      if (result == null || !mounted) return;
                      setState(() {
                        _manualLat = result.lat;
                        _manualLng = result.lng;
                      });
                    },
            ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _saving ? null : _create,
            child: _saving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Generar plan'),
          ),
        ],
      ),
    );
  }
}
