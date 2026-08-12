import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/errors/user_facing_error.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/widgets/app_toast.dart';
import '../../saves/data/geo_place.dart';
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
      AppToast.show(context, context.l10n.planNeedCity, error: true);
      return;
    }
    setState(() => _saving = true);
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
      setState(() => _saving = false);
      AppToast.error(context, e, logContext: 'create_plan');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.planCreateTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleCtrl,
            decoration: InputDecoration(
              labelText: l10n.planTitleOptional,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _locationCtrl,
            decoration: InputDecoration(
              labelText: l10n.planLocationLabel,
              hintText: l10n.planLocationHint,
              border: const OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _budgetCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.planBudgetLabel,
              border: const OutlineInputBorder(),
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.planIncludePublic),
            value: _includePublic,
            onChanged: _saving
                ? null
                : (v) => setState(() => _includePublic = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.planUseMyLocation),
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
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _saving ? null : _create,
            child: _saving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.planGenerate),
          ),
        ],
      ),
    );
  }
}
