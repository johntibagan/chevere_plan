import 'dart:convert';

import 'package:native_geofence/native_geofence.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/logging/app_log.dart';
import '../../../core/notifications/app_local_notifications.dart';
import '../../../core/notifications/notification_cover_cache.dart';
import '../../auth/data/profile.dart';
import '../../auth/data/profile_repository.dart';
import 'proximity_notify_throttle.dart';
import 'proximity_reminder_service.dart';
import 'proximity_repository.dart';

const _kSiteCardsKey = 'proximity_site_cards_v2';
/// Clave legacy (solo nombres).
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
      await AppLocalNotifications.instance.init();

      final targets = await _proximity.listTargets(
        includePublic: p.remindPublicSites,
      );

      final cards = <String, Map<String, String?>>{};
      for (final t in targets) {
        String? localCover;
        final storage = t.coverStoragePath?.trim();
        if (storage != null && storage.isNotEmpty) {
          localCover = await NotificationCoverCache.cacheFromStoragePath(
            cacheKey: 'prox_${t.siteId}',
            storagePath: storage,
          );
        }
        cards[t.siteId] = {
          'name': t.name,
          'city': t.city,
          'department': t.department,
          'coverPath': localCover,
        };
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kSiteCardsKey, jsonEncode(cards));
      // Compat: mapa plano de nombres por si un callback viejo sigue vivo.
      await prefs.setString(
        _kSiteNamesKey,
        jsonEncode({for (final t in targets) t.siteId: t.name}),
      );

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
      AppLog.error(
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
      await ProximityNotifyThrottle.clearAll();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kSiteCardsKey);
      await prefs.remove(_kSiteNamesKey);
    } catch (e, st) {
      AppLog.error(
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
    final rawCards = prefs.getString(_kSiteCardsKey);
    Map<String, dynamic> cards = {};
    if (rawCards != null && rawCards.isNotEmpty) {
      cards = jsonDecode(rawCards) as Map<String, dynamic>;
    }
    Map<String, dynamic> legacyNames = {};
    final rawNames = prefs.getString(_kSiteNamesKey);
    if (rawNames != null && rawNames.isNotEmpty) {
      legacyNames = jsonDecode(rawNames) as Map<String, dynamic>;
    }

    for (final fence in params.geofences) {
      final siteId = fence.id;
      if (!await ProximityNotifyThrottle.shouldNotify(siteId)) continue;

      String name = 'un lugar';
      String? city;
      String? department;
      String? coverPath;
      final entry = cards[siteId];
      if (entry is Map) {
        name = entry['name']?.toString() ?? name;
        city = entry['city']?.toString();
        department = entry['department']?.toString();
        final cp = entry['coverPath']?.toString();
        if (cp != null && cp.isNotEmpty) coverPath = cp;
      } else {
        name = legacyNames[siteId]?.toString() ?? name;
      }

      await ProximityReminderService.instance.showNearby(
        siteId: siteId,
        siteName: name,
        city: city,
        department: department,
        imageFilePath: coverPath,
      );
      await ProximityNotifyThrottle.markShown(siteId);
    }
  } catch (e, st) {
    AppLog.debug(
      'Geofence callback failed',
      name: 'proximity',
      error: e,
      stackTrace: st,
    );
  }
}
