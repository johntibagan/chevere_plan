import 'package:flutter/material.dart';

import '../../../core/errors/user_facing_error.dart';
import '../../auth/data/profile.dart';
import '../../auth/data/profile_repository.dart';
import '../data/geofence_sync_service.dart';

/// Preferencias de recuerdos por proximidad (§6).
Future<Profile?> showProximityPrefsSheet({
  required BuildContext context,
  required Profile profile,
  required ProfileRepository profileRepository,
  required GeofenceSyncService geofenceSync,
}) {
  return showModalBottomSheet<Profile>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _ProximityPrefsSheet(
      profile: profile,
      profileRepository: profileRepository,
      geofenceSync: geofenceSync,
    ),
  );
}

class _ProximityPrefsSheet extends StatefulWidget {
  const _ProximityPrefsSheet({
    required this.profile,
    required this.profileRepository,
    required this.geofenceSync,
  });

  final Profile profile;
  final ProfileRepository profileRepository;
  final GeofenceSyncService geofenceSync;

  @override
  State<_ProximityPrefsSheet> createState() => _ProximityPrefsSheetState();
}

class _ProximityPrefsSheetState extends State<_ProximityPrefsSheet> {
  late double _radius;
  late bool _remindPublic;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _radius = widget.profile.proximityRadiusM.toDouble();
    _remindPublic = widget.profile.remindPublicSites;
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final updated = await widget.profileRepository.updateProximityPrefs(
        proximityRadiusM: _radius.round(),
        remindPublicSites: _remindPublic,
      );
      final sync = await widget.geofenceSync.syncFromProfile(profile: updated);
      if (!mounted) return;
      if (sync == GeofenceSyncResult.needsLocationPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Activa la ubicación (siempre) para recibir recuerdos cercanos.',
            ),
          ),
        );
      } else if (sync == GeofenceSyncResult.failed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(kGenericAppError)),
        );
      }
      Navigator.of(context).pop(updated);
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
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Recuerdos cercanos',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Te avisamos al acercarte a un lugar guardado.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Incluir sitios públicos'),
            subtitle: const Text(
              'También recordarme lugares públicos de otros usuarios',
            ),
            value: _remindPublic,
            onChanged: _saving
                ? null
                : (v) => setState(() => _remindPublic = v),
          ),
          const SizedBox(height: 12),
          Text(
            'Radio: ${_radius.round()} m',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Slider(
            min: 100,
            max: 2000,
            divisions: 38,
            label: '${_radius.round()} m',
            value: _radius,
            onChanged: _saving
                ? null
                : (v) => setState(() => _radius = v),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
