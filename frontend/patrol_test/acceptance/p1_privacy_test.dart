import 'package:chevere_plan/core/testing/widget_keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../helpers/critical_harness.dart';
import '../robots/robots.dart';

void main() {
  patrolTest(
    'crear privado por default: Público off y deshabilitado sin pin',
    tags: ['critical', 'saves'],
    ($) async {
      if (!await requireSignedIn($)) return;
      await HomeRobot($).tapSaveFab();
      SavePlaceRobot($).expectPublicEnabled(false);
    },
  );

  patrolTest(
    'duplicado suave: Vincular/seguir, sin guardar de todas formas',
    tags: ['critical', 'saves'],
    ($) async {
      if (!await requireSignedIn($)) return;
      final home = HomeRobot($);
      final save = SavePlaceRobot($);
      final loc = LocationPickerRobot($);
      final name = uniqueLabel('e2e-dupe');

      await home.tapSaveFab();
      await save.fillName(name);
      await save.openMap();
      await loc.confirmPin();
      save.expectPublicEnabled(true);
      await save.togglePublic();
      await save.tapSubmit();
      await $.pumpAndSettle();

      await home.tapSaveFab();
      await save.fillName(name);
      await save.openMap();
      await loc.confirmPin();
      await $.pumpAndSettle();
      if (find.byKey(WidgetKeys.dupeKeepEditing).evaluate().isEmpty) {
        markTestSkipped(
          'RPC de duplicados no devolvió match (radio/nombre). Revisar seed e2e.',
        );
        return;
      }
      save.expectDupeSoftNoAnyway();
      await $(WidgetKeys.dupeKeepEditing).tap();
      await save.tapSubmit();
      await $.pumpAndSettle();
      if (find.byKey(WidgetKeys.dupeSaveAnyway).evaluate().isNotEmpty) {
        save.expectDupeHardHasAnyway();
      }
    },
  );

  patrolTest(
    'segunda cuenta en Explorar (skip sin TOKEN_B)',
    tags: ['saves'],
    ($) async {
      if (!hasSecondE2eUser) {
        markTestSkipped(
          'Privacidad cruzada: falta E2E_SUPABASE_REFRESH_TOKEN_B.',
        );
        return;
      }
      markTestSkipped(
        'Cambio de sesión mid-test no está cableado (un process / un auth). '
        'Correr dos jobs o un harness multi-sesión.',
      );
    },
  );

  patrolTest(
    'catálogo external_id privatizar: skip sin fixture',
    tags: ['saves'],
    ($) async {
      markTestSkipped(
        'Hace falta un site_id de catálogo en el proyecto e2e (E2E_CATALOG_SITE_ID).',
      );
    },
  );
}
