import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:native_geofence/native_geofence.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/data/profile.dart';
import '../../auth/data/profile_repository.dart';
import 'proximity_reminder_service.dart';
import 'proximity_repository.dart';

const _kSiteNamesKey = 'proximity_site_names';

/// Resultado de sync para la UI (mensajes de negocio).
enum GeofenceSyncResult {
  ok,
  needsLocationPermission,
  empty,
  failed,
}

/// Sincroniza geofences nativos con los sitios elegibles del usuario.
class GeofenceSyncService {
  GeofenceSyncService({
    ProfileRepository? profileRepository,
    ProximityRepository? proximityRepository,
  })  : _profiles = profileRepository ?? ProfileRepository(),
        _proximity = proximityRepository ?? ProximityRepository();

  final ProfileRepository _profiles;
  final ProximityRepository _proximity;
  bool _pluginReady = false;

  Future<void> _ensurePlugin() async {
    if (_pluginReady) return;
    await NativeGeofenceManager.instance.initialize();
    _pluginReady = true;
  }

  /// Solicita when-in-use y luego background. false = faltan permisos.
  Future<bool> ensureLocationPermissions() async {
    var whenInUse = await Permission.locationWhenInUse.status;
    if (!whenInUse.isGranted) {
      whenInUse = await Permission.locationWhenInUse.request();
    }
    if (!whenInUse.isGranted) return false;

    var always = await Permission.locationAlways.status;
    if (!always.isGranted) {
      always = await Permission.locationAlways.request();
    }
    return always.isGranted;
  }

  Future<GeofenceSyncResult> syncFromProfile({Profile? profile}) async {
    try {
      final p = profile ?? await _profiles.fetchCurrent();
      if (p == null) return GeofenceSyncResult.failed;

      final allowed = await ensureLocationPermissions();
      if (!allowed) return GeofenceSyncResult.needsLocationPermission;

      await _ensurePlugin();
      await ProximityReminderService.instance.init();

      final targets = await _proximity.listTargets(
        includePublic: p.remindPublicSites,
      );

      final names = <String, String>{
        for (final t in targets) t.siteId: t.name,
      };
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kSiteNamesKey, jsonEncode(names));

      await NativeGeofenceManager.instance.removeAllGeofences();

      if (targets.isEmpty) return GeofenceSyncResult.empty;

      final radius = p.proximityRadiusM.toDouble();
      for (final t in targets) {
        final fence = Geofence(
          id: t.siteId,
          location: Location(latitude: t.lat, longitude: t.lng),
          radiusMeters: radius,
          triggers: {GeofenceEvent.enter},
          iosSettings: const IosGeofenceSettings(initialTrigger: false),
          androidSettings: AndroidGeofenceSettings(
            initialTriggers: {GeofenceEvent.enter},
            notificationResponsiveness: const Duration(seconds: 30),
          ),
        );
        await NativeGeofenceManager.instance.createGeofence(
          fence,
          geofenceTriggered,
        );
      }
      return GeofenceSyncResult.ok;
    } catch (e, st) {
      developer.log(
        'Geofence sync failed',
        name: 'proximity',
        error: e,
        stackTrace: st,
      );
      return GeofenceSyncResult.failed;
    }
  }

  Future<void> clearAll() async {
    try {
      await _ensurePlugin();
      await NativeGeofenceManager.instance.removeAllGeofences();
    } catch (e, st) {
      developer.log(
        'Clear geofences failed',
        name: 'proximity',
        error: e,
        stackTrace: st,
      );
    }
  }
}

@pragma('vm:entry-point')
Future<void> geofenceTriggered(GeofenceCallbackParams params) async {
  if (params.event != GeofenceEvent.enter) return;
  try {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kSiteNamesKey);
    Map<String, dynamic> names = {};
    if (raw != null && raw.isNotEmpty) {
      names = jsonDecode(raw) as Map<String, dynamic>;
    }
    for (final fence in params.geofences) {
      final name = names[fence.id]?.toString() ?? 'un lugar';
      await ProximityReminderService.instance.showNearby(siteName: name);
    }
  } catch (e, st) {
    if (kDebugMode) {
      developer.log(
        'Geofence callback failed',
        name: 'proximity',
        error: e,
        stackTrace: st,
      );
    }
  }
}
