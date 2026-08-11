/// Preferencias de proximidad / geofencing (domain).
abstract final class ProximityPolicies {
  static const int minRadiusM = 100;
  static const int maxRadiusM = 2000;
  static const int defaultRadiusM = 200;

  static int clampRadiusM(int value) {
    if (value < minRadiusM) return minRadiusM;
    if (value > maxRadiusM) return maxRadiusM;
    return value;
  }
}
