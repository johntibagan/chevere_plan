import 'package:geolocator/geolocator.dart';

class GeoFix {
  const GeoFix(this.lat, this.lng);

  final double lat;
  final double lng;
}

enum LocationAccess { granted, denied }

/// GPS del dispositivo (inyectable). Last-known es barato; current no.
class DeviceLocation {
  Future<LocationAccess> access({bool request = false}) async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied && request) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return LocationAccess.denied;
    }
    return LocationAccess.granted;
  }

  Future<GeoFix?> lastKnown() async {
    final pos = await Geolocator.getLastKnownPosition();
    if (pos == null) return null;
    return GeoFix(pos.latitude, pos.longitude);
  }

  Future<GeoFix> current() async {
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 8),
      ),
    );
    return GeoFix(pos.latitude, pos.longitude);
  }

  /// Permiso + fix, o null (denegado o error). No cambia [current] (Inicio).
  Future<GeoFix?> tryCurrent({
    LocationAccuracy accuracy = LocationAccuracy.medium,
    Duration? timeLimit,
    bool request = true,
  }) async {
    if (await access(request: request) == LocationAccess.denied) {
      return null;
    }
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          timeLimit: timeLimit,
        ),
      );
      return GeoFix(pos.latitude, pos.longitude);
    } catch (_) {
      return null;
    }
  }
}
