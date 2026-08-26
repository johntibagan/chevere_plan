import 'package:flutter/material.dart';

import '../../../core/distance/distance_unit.dart';
import '../../../core/formatters/distance_format.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/data/profile.dart';
import '../../auth/data/profile_repository.dart';
import '../data/geofence_sync_service.dart';
import '../domain/proximity_policies.dart';

/// Preferencias de recuerdos por proximidad (§6).
/// El radio se muestra en la [distanceUnit] del usuario; se guarda en metros.
Future<Profile?> showProximityPrefsSheet({
  required BuildContext context,
  required Profile profile,
  required ProfileRepository profileRepository,
  required GeofenceSyncService geofenceSync,
  required DistanceUnit distanceUnit,
}) {
  return showModalBottomSheet<Profile>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (context) => _ProximityPrefsSheet(
      profile: profile,
      profileRepository: profileRepository,
      geofenceSync: geofenceSync,
      distanceUnit: distanceUnit,
    ),
  );
}

class _ProximityPrefsSheet extends StatefulWidget {
  const _ProximityPrefsSheet({
    required this.profile,
    required this.profileRepository,
    required this.geofenceSync,
    required this.distanceUnit,
  });

  final Profile profile;
  final ProfileRepository profileRepository;
  final GeofenceSyncService geofenceSync;
  final DistanceUnit distanceUnit;

  @override
  State<_ProximityPrefsSheet> createState() => _ProximityPrefsSheetState();
}

class _ProximityPrefsSheetState extends State<_ProximityPrefsSheet> {
  late double _radiusDisplay;
  late bool _remindPublic;
  bool _saving = false;

  DistanceUnit get _unit => widget.distanceUnit;

  double get _minDisplay => _unit.metersToUnit(ProximityPolicies.minRadiusM);
  double get _maxDisplay => _unit.metersToUnit(ProximityPolicies.maxRadiusM);

  @override
  void initState() {
    super.initState();
    final meters = ProximityPolicies.clampRadiusM(
      widget.profile.proximityRadiusM,
    );
    _radiusDisplay = _unit.metersToUnit(meters);
    _remindPublic = widget.profile.remindPublicSites;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final meters = ProximityPolicies.clampRadiusM(
        _unit.unitToMeters(_radiusDisplay).round(),
      );
      final updated = await widget.profileRepository.updateProximityPrefs(
        proximityRadiusM: meters,
        remindPublicSites: _remindPublic,
      );
      final sync = await widget.geofenceSync.syncFromProfile(profile: updated);
      if (!mounted) return;
      if (sync == GeofenceSyncResult.needsLocationPermission) {
        AppToast.show(context, context.l10n.proximityNeedsLocation, error: true);
      } else if (sync == GeofenceSyncResult.failed) {
        AppToast.show(context, context.l10n.errorGeneric, error: true);
      }
      Navigator.of(context).pop(updated);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppToast.error(context, e, logContext: 'proximity_prefs');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final valueLabel = formatDistanceRaw(_unit, _radiusDisplay);
    final divisions = ((_maxDisplay - _minDisplay) /
            (_unit.metersPerUnit <= 1 ? 50 : 0.05))
        .round()
        .clamp(10, 80);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.proximityTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.proximitySubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.proximityIncludePublic),
              subtitle: Text(l10n.proximityIncludePublicSubtitle),
              value: _remindPublic,
              onChanged: _saving
                  ? null
                  : (v) => setState(() => _remindPublic = v),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.proximityRadiusLabel(
                _radiusDisplay.toStringAsFixed(_unit.displayFractionDigits),
                _unit.symbol,
              ),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Slider(
              min: _minDisplay,
              max: _maxDisplay,
              divisions: divisions,
              label: valueLabel,
              value: _radiusDisplay.clamp(_minDisplay, _maxDisplay),
              onChanged: _saving
                  ? null
                  : (v) => setState(() => _radiusDisplay = v),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.actionSave),
            ),
          ],
        ),
      ),
    );
  }
}
