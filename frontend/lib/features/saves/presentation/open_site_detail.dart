import 'package:chevere_plan/features/saves/data/save_models.dart';
import 'package:chevere_plan/features/saves/data/site_ficha.dart';
import 'package:chevere_plan/features/saves/presentation/site_detail_page.dart';
import 'package:chevere_plan/features/search/data/search_models.dart';
import 'package:flutter/material.dart';

export 'package:chevere_plan/features/saves/data/site_ficha.dart'
    show SiteDetailLaunchConfig, SiteDetailOutcome;

/// Abre la ficha unificada desde Inicio, búsqueda, etc.
Future<SiteDetailOutcome> openSiteDetail(
  BuildContext context, {
  UserSave? save,
  SearchHit? hit,
  String? siteId,
  SiteDetailLaunchConfig launch = const SiteDetailLaunchConfig(),
  NavigatorState? navigator,
}) async {
  final id = siteId ?? save?.siteId ?? hit?.siteId;
  if (id == null || id.isEmpty) return SiteDetailOutcome.none;

  final nav = navigator ?? Navigator.of(context);
  final result = await nav.push<SiteDetailOutcome>(
    MaterialPageRoute(
      builder: (_) => SiteDetailPage(
        siteId: id,
        initialSave: save,
        initialHit: hit,
        launch: launch,
      ),
    ),
  );
  return result ?? SiteDetailOutcome.none;
}
