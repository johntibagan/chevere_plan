import 'package:chevere_plan/features/plans/data/maps_export.dart';
import 'package:chevere_plan/features/plans/data/plan_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Llevar a Maps no usa el path lat,lng que Maps convierte en otro POI', () {
    final uri = buildGoogleMapsDirectionsUri(
      originLat: 5.54,
      originLng: -73.36,
      stopsInOrder: const [
        PlanStop(
          id: '1',
          planId: 'p',
          siteId: 's',
          sortOrder: 0,
          siteName: 'Plaza / parque principal de Tunja',
          city: 'Tunja',
          department: 'Boyacá',
          lat: 5.53988,
          lng: -73.355539,
        ),
      ],
    );
    expect(uri.toString(), isNot(contains('/maps/dir/5.54')));
    expect(uri.queryParameters['destination'], contains('Plaza'));
  });
}
