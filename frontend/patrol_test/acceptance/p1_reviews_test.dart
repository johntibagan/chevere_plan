import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../helpers/critical_harness.dart';

void main() {
  patrolTest(
    'reseña pública: abre editor (fotos de galería nativa: skip cubierto en unit)',
    tags: ['saves'],
    ($) async {
      if (!await requireSignedIn($)) return;
      markTestSkipped(
        'ImagePicker nativo + promedio RPC: el promedio está en review_policies_test. '
        'E2E de fotos/galería queda para nightly con fixture de imagen.',
      );
    },
  );
}
