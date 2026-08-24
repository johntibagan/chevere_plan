import 'package:chevere_plan/features/home/domain/home_sections_open.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('HomeSectionsOpen encode/decode', () {
    const closed = HomeSectionsOpen(
      recent: false,
      popular: true,
      quick: false,
    );
    expect(HomeSectionsOpen.decode(closed.encode()).recent, isFalse);
    expect(HomeSectionsOpen.decode(closed.encode()).popular, isTrue);
    expect(HomeSectionsOpen.decode(null).recent, isTrue);
  });
}
