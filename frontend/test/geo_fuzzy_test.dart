import 'package:chevere_plan/features/geo/domain/geo_models.dart';
import 'package:chevere_plan/features/geo/domain/geo_fuzzy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final cundinamarca = GeoDepartment(
    id: 'd-25',
    countryCode: 'CO',
    code: '25',
    name: 'Cundinamarca',
    nameNorm: 'cundinamarca',
  );
  final boyaca = GeoDepartment(
    id: 'd-15',
    countryCode: 'CO',
    code: '15',
    name: 'Boyacá',
    nameNorm: 'boyaca',
  );
  final choconta = GeoCity(
    id: 'c-25001',
    departmentId: 'd-25',
    code: '25183',
    name: 'Chocontá',
    nameNorm: 'choconta',
  );
  final catalog = GeoCatalog(
    departments: [cundinamarca, boyaca],
    cities: [choconta],
  );

  test('sin tilde y minúsculas encuentra ciudad', () {
    final m = GeoFuzzy.match(
      catalog: catalog,
      departmentHint: 'cundinamarca',
      cityHint: 'choconta',
    );
    expect(m.department?.id, 'd-25');
    expect(m.city?.id, 'c-25001');
  });

  test('typo leve en departamento', () {
    final d = GeoFuzzy.bestDepartment(catalog, 'Cundinamrca');
    expect(d?.id, 'd-25');
  });

  test('sin departamento infiere por ciudad', () {
    final m = GeoFuzzy.match(
      catalog: catalog,
      cityHint: 'Choconta',
    );
    expect(m.department?.id, 'd-25');
    expect(m.city?.name, 'Chocontá');
  });

  test('filtro local no exige coincidencia exacta', () {
    final hits = GeoFuzzy.filter(
      catalog.activeDepartments,
      'cundi',
      (d) => d.name,
    );
    expect(hits.map((d) => d.id), contains('d-25'));
  });
}
