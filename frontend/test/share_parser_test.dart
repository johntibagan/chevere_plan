import 'package:chevere_plan/features/saves/data/share_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('acepta https de Maps', () {
    final r = ShareParser.parse(
      'https://maps.app.goo.gl/abc Villa de Leyva',
    );
    expect(r.url, startsWith('https://'));
    expect(r.network, 'google_maps');
    expect(r.hasNavigableContent, isTrue);
  });

  test('rechaza javascript sin http', () {
    final r = ShareParser.parse('javascript:alert(1)');
    expect(r.url, isNull);
    expect(r.hasNavigableContent, isFalse);
  });

  test('rechaza data: y file:', () {
    expect(ShareParser.parse('data:text/html,hi').hasNavigableContent, isFalse);
    expect(ShareParser.parse('file:///etc/passwd').hasNavigableContent, isFalse);
  });

  test('recorta payloads enormes', () {
    final r = ShareParser.parse('x' * 20000);
    expect(r.rawText!.length, ShareParser.maxInputChars);
  });
}
