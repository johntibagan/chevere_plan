import 'package:flutter_test/flutter_test.dart';

import 'package:chevere_plan/features/admin/data/admin_models.dart';
import 'package:chevere_plan/features/saves/domain/category_suggester.dart';

Category _cat({
  required String id,
  required String slug,
  required String name,
  String? parentId,
  List<String> keywords = const [],
  int sortOrder = 0,
}) {
  return Category(
    id: id,
    parentId: parentId,
    slug: slug,
    nameEs: name,
    isActive: true,
    ageRestricted: false,
    sortOrder: sortOrder,
    keywords: keywords,
  );
}

void main() {
  final otros = _cat(id: 'p-otros', slug: 'otros', name: 'Otros', sortOrder: 8);
  final otro = _cat(
    id: 'c-otro',
    slug: 'otro',
    name: 'Otro',
    parentId: 'p-otros',
    keywords: const ['otro', 'otros', 'varios'],
    sortOrder: 2,
  );
  final gastro = _cat(
    id: 'p-gastro',
    slug: 'gastronomia',
    name: 'Gastronomía',
    sortOrder: 1,
  );
  final restaurante = _cat(
    id: 'c-rest',
    slug: 'restaurante',
    name: 'Restaurante',
    parentId: 'p-gastro',
    keywords: const ['comida', 'almuerzo', 'cena', 'menu', 'comer', 'restaurant'],
    sortOrder: 1,
  );
  final hotel = _cat(
    id: 'c-hotel',
    slug: 'hotel',
    name: 'Hotel',
    parentId: 'p-aloja',
    keywords: const ['hotel', 'hospedaje', 'suite', 'resort'],
    sortOrder: 1,
  );
  final tejo = _cat(
    id: 'c-tejo',
    slug: 'tejo',
    name: 'Tejo',
    parentId: 'p-dep',
    keywords: const ['tejo', 'cancha de tejo', 'turmeque'],
    sortOrder: 2,
  );

  final all = [otros, otro, gastro, restaurante, hotel, tejo];

  test('sugiere restaurante por nombre del sitio', () {
    final r = CategorySuggester.suggest(
      categories: all,
      haystack: 'Restaurante El Fogón Bogotá',
    );
    expect(r.usedDefault, isFalse);
    expect(r.categories.single.slug, 'restaurante');
  });

  test('sugiere hotel por keyword', () {
    final r = CategorySuggester.suggest(
      categories: all,
      haystack: 'Hospedaje La Cascada Manizales',
    );
    expect(r.categories.single.slug, 'hotel');
  });

  test('sugiere tejo', () {
    final r = CategorySuggester.suggest(
      categories: all,
      haystack: 'Cancha de tejo Los Amigos',
    );
    expect(r.categories.single.slug, 'tejo');
  });

  test('sin match usa Otros › Otro', () {
    final r = CategorySuggester.suggest(
      categories: all,
      haystack: 'Lugar XYZ sin pistas',
    );
    expect(r.usedDefault, isTrue);
    expect(r.categories.single.slug, 'otro');
  });

  test('haystack vacío usa default', () {
    final r = CategorySuggester.suggest(categories: all, haystack: '');
    expect(r.usedDefault, isTrue);
    expect(r.categories.single.id, 'c-otro');
  });
}
