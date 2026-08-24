import 'package:chevere_plan/core/widgets/site_cover.dart';
import 'package:chevere_plan/features/admin/data/admin_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('categoría padre gastro vs cultura (sin seed)', () {
    expect(
      SiteCoverFamily.resolve(hint: 'Gastronomía'),
      SiteCoverFamily.gastronomy,
    );
    expect(
      SiteCoverFamily.resolve(hint: 'Cultura e historia'),
      SiteCoverFamily.culture,
    );
  });

  test('misma pista padre: misma ilustración aunque cambie el id', () {
    expect(
      SiteCoverFamily.resolve(hint: 'Naturaleza y aire libre', seed: 'a'),
      SiteCoverFamily.resolve(hint: 'Naturaleza y aire libre', seed: 'b'),
    );
    expect(
      SiteCoverFamily.resolve(hint: 'Naturaleza y aire libre'),
      SiteCoverFamily.nature,
    );
  });

  test('primera categoría hija usa el nombre de la padre', () {
    const parent = Category(
      id: 'p1',
      slug: 'naturaleza',
      nameEs: 'Naturaleza y aire libre',
      isActive: true,
      ageRestricted: false,
      sortOrder: 1,
    );
    const child = Category(
      id: 'c1',
      parentId: 'p1',
      slug: 'plaza-parque',
      nameEs: 'Plaza / parque principal',
      isActive: true,
      ageRestricted: false,
      sortOrder: 2,
    );
    expect(
      Category.parentNameEs([parent, child], ['Plaza / parque principal']),
      'Naturaleza y aire libre',
    );
  });

  testWidgets('mini 40 y hero 176 pintan sin overflow', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: DefaultSiteCover(
                  categoryHint: 'Naturaleza y aire libre',
                ),
              ),
              SizedBox(
                width: 176,
                height: 176,
                child: DefaultSiteCover(categoryHint: 'Gastronomía'),
              ),
              SizedBox(
                width: 144,
                height: 110,
                child: DefaultSiteCover(categoryHint: 'Cultura e historia'),
              ),
            ],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
