import 'package:chevere_plan/core/testing/widget_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

class HomeRobot {
  HomeRobot(this.$);
  final PatrolIntegrationTester $;

  Future<void> tapSaveFab() async {
    await $(WidgetKeys.homeFabSave).tap();
    await $.pumpAndSettle();
  }

  Future<void> goTabInicio() async {
    await $(WidgetKeys.homeTabInicio).tap();
    await $.pumpAndSettle();
  }

  Future<void> goExplorar() async {
    await $(WidgetKeys.homeTabExplorar).tap();
    await $.pumpAndSettle();
  }

  Future<void> goPlanes() async {
    await $(WidgetKeys.homeTabPlanes).tap();
    await $.pumpAndSettle();
  }

  Future<void> goRutas() async {
    await $(WidgetKeys.homeTabRutas).tap();
    await $.pumpAndSettle();
  }

  Future<void> openSaveNamed(String name) async {
    await $(find.text(name)).tap();
    await $.pumpAndSettle();
  }

  void expectHome() {
    expect(find.byKey(WidgetKeys.homeShell), findsOneWidget);
  }
}

class SavePlaceRobot {
  SavePlaceRobot(this.$);
  final PatrolIntegrationTester $;

  Future<void> fillName(String name) async {
    await $(WidgetKeys.saveNameField).enterText(name);
  }

  Future<void> enterMapsUrl(String url) async {
    await $(WidgetKeys.saveMapsField).enterText(url);
    await $.tester.testTextInput.receiveAction(TextInputAction.done);
    await $.pumpAndSettle();
  }

  Future<void> tapSubmit() async {
    await $(WidgetKeys.saveSubmit).tap();
    await $.pumpAndSettle();
  }

  Future<void> openMap() async {
    await $(WidgetKeys.saveOpenMap).tap();
    await $.pumpAndSettle();
  }

  Future<void> toggleExactPinOff() async {
    await $(WidgetKeys.saveExactPinSwitch).tap();
    await $.pumpAndSettle();
  }

  Future<void> togglePublic() async {
    await $(WidgetKeys.savePublicSwitch).tap();
    await $.pumpAndSettle();
  }

  void expectSubmitEnabled(bool enabled) {
    final btn = $.tester.widget<FilledButton>(find.byKey(WidgetKeys.saveSubmit));
    expect(btn.onPressed != null, enabled);
  }

  void expectPublicEnabled(bool enabled) {
    final sw = $.tester.widget<Switch>(find.byKey(WidgetKeys.savePublicSwitch));
    expect(sw.onChanged != null, enabled);
  }

  void expectHasPin(bool has) {
    expect(
      find.byKey(has ? WidgetKeys.saveHasPin : WidgetKeys.saveNoPin),
      findsOneWidget,
    );
  }

  void expectLinksSection() {
    expect(find.byKey(WidgetKeys.saveLinksSection), findsOneWidget);
  }

  void expectDupeSoftNoAnyway() {
    expect(find.byKey(WidgetKeys.dupeKeepEditing), findsOneWidget);
    expect(find.byKey(WidgetKeys.dupeSaveAnyway), findsNothing);
  }

  void expectDupeHardHasAnyway() {
    expect(find.byKey(WidgetKeys.dupeSaveAnyway), findsOneWidget);
    expect(find.byKey(WidgetKeys.dupeKeepEditing), findsNothing);
  }
}

class LocationPickerRobot {
  LocationPickerRobot(this.$);
  final PatrolIntegrationTester $;

  Future<void> confirmPin() async {
    await $(WidgetKeys.locationConfirm).tap();
    await $.pumpAndSettle();
  }
}

class SiteDetailRobot {
  SiteDetailRobot(this.$);
  final PatrolIntegrationTester $;

  Future<void> openEdit() async {
    await $(find.byIcon(Icons.more_vert).first).tap();
    await $.pumpAndSettle();
    await $(WidgetKeys.siteDetailEdit).tap();
    await $.pumpAndSettle();
  }
}

class PlanBuilderRobot {
  PlanBuilderRobot(this.$);
  final PatrolIntegrationTester $;

  Future<void> setIncludePublic(bool on) async {
    final sw = $.tester.widget<SwitchListTile>(
      find.byKey(WidgetKeys.planBuilderIncludePublic),
    );
    if (sw.value != on) {
      await $(WidgetKeys.planBuilderIncludePublic).tap();
      await $.pumpAndSettle();
    }
  }
}

class PlanDetailRobot {
  PlanDetailRobot(this.$);
  final PatrolIntegrationTester $;

  Future<void> addSites() async {
    await $(WidgetKeys.planDetailAdd).tap();
    await $.pumpAndSettle();
  }

  Future<void> deletePlan() async {
    await $(WidgetKeys.planDetailMore).tap();
    await $.pumpAndSettle();
    await $(WidgetKeys.planMenuDelete).tap();
    await $.pumpAndSettle();
    await $(WidgetKeys.planDeleteConfirm).tap();
    await $.pumpAndSettle();
  }
}

class MyRoutesRobot {
  MyRoutesRobot(this.$);
  final PatrolIntegrationTester $;

  void expectNoAdmin() {
    expect(find.byKey(WidgetKeys.adminPage), findsNothing);
  }

  void expectEmptyOrList() {
    final empty = find.byKey(WidgetKeys.routesEmpty);
    final stats = find.byKey(WidgetKeys.routesStatVisited);
    expect(empty.evaluate().isNotEmpty || stats.evaluate().isNotEmpty, isTrue);
  }
}

class SearchRobot {
  SearchRobot(this.$);
  final PatrolIntegrationTester $;

  Future<void> search(String q) async {
    await $(WidgetKeys.searchQuery).enterText(q);
    await $.tester.testTextInput.receiveAction(TextInputAction.search);
    await $.pumpAndSettle();
  }

  Future<void> setIncludePublic(bool on) async {
    final sw = $.tester.widget<SwitchListTile>(
      find.byKey(WidgetKeys.searchIncludePublic),
    );
    if (sw.value != on) {
      await $(WidgetKeys.searchIncludePublic).tap();
      await $.pumpAndSettle();
    }
  }
}
