import '../../saves/data/save_models.dart';
import '../../saves/data/saves_repository.dart';
import 'plan_models.dart';

/// Completa portada/categorías de paradas en **un** lote (`loadSiteLooks`).
///
/// [coverStopsOnly]: solo la parada de portada (lista de planes). En detalle
/// pasar false para hidratar también la timeline.
Future<List<Plan>> enrichPlansCovers(
  List<Plan> plans,
  SavesRepository saves, {
  bool coverStopsOnly = false,
}) async {
  if (plans.isEmpty) return plans;
  final needIds = <String>{};
  for (final plan in plans) {
    final targets = coverStopsOnly
        ? [if (plan.coverStop != null) plan.coverStop!]
        : plan.stops;
    for (final stop in targets) {
      final path = stop.coverStoragePath?.trim();
      final missingPath = path == null || path.isEmpty;
      final missingCats = stop.categoryNames.isEmpty;
      if ((missingPath || missingCats) && stop.siteId.trim().isNotEmpty) {
        needIds.add(stop.siteId);
      }
    }
  }
  if (needIds.isEmpty) return plans;

  final looks = await saves.loadSiteLooks(needIds);
  if (looks.isEmpty) return plans;

  return [
    for (final plan in plans)
      plan.copyWith(
        stops: [
          for (final stop in plan.stops) _enrichStop(stop, looks[stop.siteId]),
        ],
      ),
  ];
}

Future<Plan> enrichPlanCovers(Plan plan, SavesRepository saves) async {
  final list = await enrichPlansCovers([plan], saves);
  return list.first;
}

PlanStop _enrichStop(PlanStop stop, SiteLook? look) {
  if (look == null) return stop;
  final path = stop.coverStoragePath?.trim();
  final hasPath = path != null && path.isNotEmpty;
  final hasCats = stop.categoryNames.isNotEmpty;
  if (hasPath && hasCats) return stop;
  final lookPath = look.coverStoragePath?.trim();
  return stop.copyWith(
    coverStoragePath: hasPath
        ? stop.coverStoragePath
        : (lookPath != null && lookPath.isNotEmpty
            ? look.coverStoragePath
            : stop.coverStoragePath),
    categoryNames: hasCats
        ? stop.categoryNames
        : (look.categoryNames.isNotEmpty
            ? look.categoryNames
            : stop.categoryNames),
  );
}
