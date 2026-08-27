import 'package:chevere_plan/features/home/domain/home_sections_open.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('HomeSectionsOpen encode/decode', () {
    const closed = HomeSectionsOpen(
      recent: false,
      popular: true,
      quick: false,
    );
    final decoded = HomeSectionsOpen.decode(closed.encode());
    expect(decoded.recent, isFalse);
    expect(decoded.popular, isTrue);
    expect(decoded.quick, isFalse);
    expect(HomeSectionsOpen.decode(null).recent, isTrue);
    // Prefs con 5.º bit (tarjetas viejo): se ignora.
    expect(HomeSectionsOpen.decode('11110').events, isTrue);
  });
}
