import 'package:geolocator/geolocator.dart';

class LatLngPoint {
  const LatLngPoint(this.lat, this.lng);

  final double lat;
  final double lng;
}

/// Distancia en km (`Geolocator.distanceBetween`).
double haversineKm(LatLngPoint a, LatLngPoint b) {
  return Geolocator.distanceBetween(a.lat, a.lng, b.lat, b.lng) / 1000.0;
}

class PlanCandidate {
  const PlanCandidate({
    required this.siteId,
    required this.name,
    required this.lat,
    required this.lng,
    this.city,
    this.department,
    this.estimatedPriceAmount,
    this.currencyCode = 'COP',
  });

  final String siteId;
  final String name;
  final double lat;
  final double lng;
  final String? city;
  final String? department;
  final double? estimatedPriceAmount;
  final String currencyCode;

  LatLngPoint get point => LatLngPoint(lat, lng);

  factory PlanCandidate.fromJson(Map<String, dynamic> json) {
    final price = json['estimated_price_amount'];
    return PlanCandidate(
      siteId: json['site_id'] as String,
      name: (json['name'] as String?) ?? 'Sitio',
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      city: json['city'] as String?,
      department: json['department'] as String?,
      estimatedPriceAmount:
          price == null ? null : (price as num).toDouble(),
      currencyCode: (json['currency_code'] as String?) ?? 'COP',
    );
  }
}

/// Ordena candidatos por vecino más cercano desde [start].
List<PlanCandidate> nearestNeighborOrder({
  required LatLngPoint start,
  required List<PlanCandidate> candidates,
  int maxStops = 10,
}) {
  if (candidates.isEmpty) return const [];
  final remaining = List<PlanCandidate>.from(candidates);
  final ordered = <PlanCandidate>[];
  var current = start;

  while (remaining.isNotEmpty && ordered.length < maxStops) {
    remaining.sort(
      (a, b) => haversineKm(current, a.point)
          .compareTo(haversineKm(current, b.point)),
    );
    final next = remaining.removeAt(0);
    ordered.add(next);
    current = next.point;
  }
  return ordered;
}
