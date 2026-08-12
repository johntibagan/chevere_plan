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

  test('categoría elegida sin ubicación → pending_location', () {
    final s = SavePolicies.computeStatus(
      categoryIds: ['rest-id'],
      city: null,
      addressLine: null,
      latitude: null,
      longitude: null,
      categoryIsExplicit: true,
    );
    expect(s, SiteStatus.pendingLocation);
  });

  test('categoría + ciudad → complete', () {
    final s = SavePolicies.computeStatus(
      categoryIds: ['otros-id'],
      city: 'Bogotá',
      addressLine: null,
      latitude: null,
      longitude: null,
      categoryIsExplicit: false,
    );
    expect(s, SiteStatus.complete);
  });
}
