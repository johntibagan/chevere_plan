import 'package:chevere_plan/features/home/domain/home_nearby_policies.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const originLat = 4.6097;
  const originLng = -74.0817;

  test('dentro de 2 km reusa; fuera no', () {
    expect(
      HomeNearbyPolicies.stillInRange(
        originLat: originLat,
        originLng: originLng,
        lat: originLat + 0.005,
        lng: originLng,
      ),
      isTrue,
    );
    expect(
      HomeNearbyPolicies.stillInRange(
        originLat: originLat,
        originLng: originLng,
        lat: originLat + 0.03,
        lng: originLng,
      ),
      isFalse,
    );
  });

  test('shouldReuse respeta celda y maxAge', () {
    final fetched = DateTime.utc(2026, 8, 23, 12);
    expect(
      HomeNearbyPolicies.shouldReuse(
        fetchedAtUtc: fetched,
        nowUtc: fetched.add(const Duration(hours: 2)),
        originLat: originLat,
        originLng: originLng,
        lat: originLat,
        lng: originLng,
      ),
      isTrue,
    );
    expect(
      HomeNearbyPolicies.shouldReuse(
        fetchedAtUtc: fetched,
        nowUtc: fetched.add(const Duration(hours: 25)),
        originLat: originLat,
        originLng: originLng,
        lat: originLat,
        lng: originLng,
      ),
      isFalse,
    );
    expect(
      HomeNearbyPolicies.shouldReuse(
        fetchedAtUtc: fetched,
        nowUtc: fetched.add(const Duration(minutes: 10)),
        originLat: originLat,
        originLng: originLng,
        lat: originLat + 0.05,
        lng: originLng,
      ),
      isFalse,
    );
  });
}
