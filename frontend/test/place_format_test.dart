import 'package:chevere_plan/core/formatters/place_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatDeptCity departamento - municipio', () {
    expect(formatDeptCity('Boyacá', 'Tunja'), 'Boyacá - Tunja');
    expect(formatDeptCity('Boyacá', null), 'Boyacá');
    expect(formatDeptCity(null, 'Tunja'), 'Tunja');
    expect(formatDeptCity('  ', ''), '');
  });
}
