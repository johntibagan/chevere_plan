import 'package:chevere_plan/features/saves/data/save_models.dart';
import 'package:chevere_plan/features/saves/domain/save_policies.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('share sin ubicación ni categoría explícita → draft', () {
    final s = SavePolicies.computeStatus(
      categoryIds: ['otros-id'],
      city: null,
      addressLine: null,
      latitude: null,
      longitude: null,
      categoryIsExplicit: false,
    );
    expect(s, SiteStatus.draft);
  });

  test('categoría elegida sin coordenadas → pending_location', () {
    final s = SavePolicies.computeStatus(
      categoryIds: ['rest-id'],
      city: 'Bogotá',
      addressLine: null,
      latitude: null,
      longitude: null,
      categoryIsExplicit: true,
    );
    expect(s, SiteStatus.pendingLocation);
  });

  test('categoría + ciudad sin coords → no complete', () {
    final s = SavePolicies.computeStatus(
      categoryIds: ['otros-id'],
      city: 'Bogotá',
      addressLine: null,
      latitude: null,
      longitude: null,
      categoryIsExplicit: false,
    );
    expect(s, SiteStatus.draft);
  });

  test('categoría + lat/lng → complete', () {
    final s = SavePolicies.computeStatus(
      categoryIds: ['otros-id'],
      city: 'Bogotá',
      addressLine: null,
      latitude: 4.6,
      longitude: -74.0,
      categoryIsExplicit: false,
    );
    expect(s, SiteStatus.complete);
  });

  test('no físico + categoría sin coords → complete', () {
    final s = SavePolicies.computeStatus(
      categoryIds: ['otros-id'],
      city: null,
      addressLine: null,
      latitude: null,
      longitude: null,
      categoryIsExplicit: true,
      isPhysicalPlace: false,
    );
    expect(s, SiteStatus.complete);
  });

  test('nombre + default Otros sin coords → draft no pending_location', () {
    final s = SavePolicies.computeStatus(
      categoryIds: ['otros-id'],
      city: null,
      addressLine: null,
      latitude: null,
      longitude: null,
      categoryIsExplicit: false,
    );
    expect(s, SiteStatus.draft);
  });
}
