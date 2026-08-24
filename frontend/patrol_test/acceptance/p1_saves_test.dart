import 'package:chevere_plan/app.dart';
import 'package:chevere_plan/core/di/providers.dart';
import 'package:chevere_plan/core/testing/widget_keys.dart';
import 'package:chevere_plan/features/saves/presentation/save_place_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../helpers/critical_harness.dart';
import '../robots/robots.dart';

void main() {
  patrolTest(
    'crear vacío solo con nombre → borrador',
    tags: ['critical', 'smoke', 'saves'],
    ($) async {
      if (!await requireSignedIn($)) return;
      final home = HomeRobot($);
      final save = SavePlaceRobot($);
      final name = uniqueLabel('e2e-draft');
      await home.tapSaveFab();
      await save.fillName(name);
      await save.tapSubmit();
      await home.goTabInicio();
      expect(find.text(name), findsWidgets);
    },
  );

  patrolTest(
    'sin nombre → Guardar deshabilitado',
    tags: ['critical', 'saves'],
    ($) async {
      if (!await requireSignedIn($)) return;
      await HomeRobot($).tapSaveFab();
      SavePlaceRobot($).expectSubmitEnabled(false);
    },
  );

  patrolTest(
    'público sin pin → switch visible y deshabilitado',
    tags: ['critical', 'saves'],
    ($) async {
      if (!await requireSignedIn($)) return;
      await HomeRobot($).tapSaveFab();
      SavePlaceRobot($).expectPublicEnabled(false);
      expect(find.byKey(WidgetKeys.savePublicSwitch), findsOneWidget);
    },
  );

  patrolTest(
    'pin en mapa → coords y Público habilitable',
    tags: ['critical', 'saves'],
    ($) async {
      if (!await requireSignedIn($)) return;
      try {
        await $.platform.mobile.grantPermissionWhenInUse();
      } catch (_) {
        // Sin diálogo nativo: el mapa igual confirma el pin de Colombia.
      }
      final save = SavePlaceRobot($);
      await HomeRobot($).tapSaveFab();
      await save.fillName(uniqueLabel('e2e-pin'));
      await save.openMap();
      await LocationPickerRobot($).confirmPin();
      save.expectHasPin(true);
      save.expectPublicEnabled(true);
    },
  );

  patrolTest(
    'apagar Punto exacto limpia pin y bloquea Público',
    tags: ['critical', 'saves'],
    ($) async {
      if (!await requireSignedIn($)) return;
      final save = SavePlaceRobot($);
      await HomeRobot($).tapSaveFab();
      await save.fillName(uniqueLabel('e2e-exact'));
      await save.openMap();
      await LocationPickerRobot($).confirmPin();
      save.expectHasPin(true);
      await save.toggleExactPinOff();
      save.expectHasPin(false);
      save.expectPublicEnabled(false);
    },
  );

  patrolTest(
    'share-intent simulado abre Enlaces',
    tags: ['saves'],
    ($) async {
      if (!await requireSignedIn($)) return;
      final nav = appNavigatorKey.currentState;
      if (nav == null) {
        fail('Navigator de la app no listo');
      }
      final repo =
          ProviderScope.containerOf(nav.context).read(savesRepositoryProvider);
      await nav.push<void>(
        MaterialPageRoute<void>(
          builder: (_) => SavePlacePage(
            initialSharedText: 'https://www.instagram.com/p/e2eTest/',
            savesRepository: repo,
          ),
        ),
      );
      await $.pumpAndSettle();
      SavePlaceRobot($).expectLinksSection();
    },
  );

  patrolTest(
    'pegar Maps autocompleta pin sin diálogo punto exacto',
    tags: ['saves'],
    ($) async {
      if (!await requireSignedIn($)) return;
      if (!hasMapsUrlFixture) {
        markTestSkipped('Definí E2E_MAPS_URL (enlace real de Google Maps).');
        return;
      }
      await HomeRobot($).tapSaveFab();
      await Clipboard.setData(ClipboardData(text: e2eMapsUrl));
      final save = SavePlaceRobot($);
      await save.enterMapsUrl(e2eMapsUrl);
      await $.pump(const Duration(seconds: 8));
      await $.pumpAndSettle();
      expect(find.textContaining('punto exacto'), findsNothing);
      expect(find.textContaining('¿guardar el punto'), findsNothing);
    },
  );
}
