// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Chevere Plan';

  @override
  String get appTagline => 'Guarda lugares y arma planes\nen Colombia.';

  @override
  String get navHome => 'Inicio';

  @override
  String get navExplore => 'Explorar';

  @override
  String get navPlans => 'Planes';

  @override
  String get navRoutes => 'Rutas';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionDiscard => 'Descartar';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionRetry => 'Reintentar';

  @override
  String get actionComplete => 'Completar';

  @override
  String get actionAdjust => 'Ajustar';

  @override
  String get actionSearch => 'Buscar';

  @override
  String get greetingMorning => 'Buenos días';

  @override
  String get greetingAfternoon => 'Buenas tardes';

  @override
  String get greetingEvening => 'Buenas noches';

  @override
  String get loginAcceptLegal => 'Acepto los documentos legales del MVP.';

  @override
  String get loginTerms => 'Términos de Uso';

  @override
  String get loginPrivacy => 'Aviso de privacidad';

  @override
  String get loginContinueGoogle => 'Continuar con Google';

  @override
  String get loginConnecting => 'Conectando…';

  @override
  String get loginMustAcceptLegal =>
      'Debes aceptar los Términos de Uso y el Aviso de privacidad para continuar.';

  @override
  String get statusDraft => 'Borrador';

  @override
  String get statusPendingLocation => 'Pendiente de ubicación';

  @override
  String get statusComplete => 'Completo';

  @override
  String get visibilityPublic => 'Público';

  @override
  String get visibilityPrivate => 'Privado';

  @override
  String get labelOwn => 'Tuyo';

  @override
  String get homePendingBadge => 'PENDIENTE';

  @override
  String homeDraftsToComplete(int count) {
    return '$count guardado(s) por completar';
  }

  @override
  String homeProximityRadius(int meters) {
    return 'Radio $meters m';
  }

  @override
  String get homeProximityPublicSuffix => ' · públicos';

  @override
  String get homeOpenReports => 'Reportes abiertos';

  @override
  String get homeMySaves => 'Mis guardados';

  @override
  String get homeEmptySaves =>
      'Aún no tienes lugares. Usa el botón + o comparte un link desde IG/TikTok/FB.';

  @override
  String get homeAdminBadge => 'A';

  @override
  String get homeDiscardTitle => 'Descartar guardado';

  @override
  String homeDiscardConfirm(String name) {
    return '¿Eliminar \"$name\" de tu lista?';
  }

  @override
  String homeStaleDraftsSnack(int count) {
    return 'Tienes $count borrador(es) por completar.';
  }

  @override
  String get plansTitle => 'Planes';

  @override
  String get plansEmpty =>
      'Aún no tienes planes. Arma uno a partir de tus guardados por ciudad o departamento.';

  @override
  String get plansCreateFab => 'Armar plan';

  @override
  String get routesTitle => 'Rutas';

  @override
  String get routesEmpty =>
      'Aún no hay lugares visitados. En un plan, marca paradas como visitadas para verlas aquí.';

  @override
  String get reportsTitle => 'Reportes de contenido';

  @override
  String get reportsEmpty => 'No hay reportes abiertos.';

  @override
  String get reportsPhotoFallback => 'Foto reportada';

  @override
  String reportsBy(String name) {
    return 'Por $name';
  }

  @override
  String get reportsMarkReviewed => 'Marcar revisado';

  @override
  String get reportsDismiss => 'Descartar';

  @override
  String get reportsActioned => 'Acción tomada';

  @override
  String get searchTitle => 'Explorar';

  @override
  String get searchEmptyHint => 'Escribe y pulsa Buscar.';

  @override
  String get searchNoResults => 'Sin resultados.';

  @override
  String get searchQueryRequired => 'Escribe algo para buscar.';

  @override
  String get searchSearching => 'Buscando…';

  @override
  String get proximityTitle => 'Recuerdos cercanos';

  @override
  String get proximitySubtitle =>
      'Te avisamos al acercarte a un lugar guardado.';

  @override
  String get proximityIncludePublic => 'Incluir sitios públicos';

  @override
  String get proximityIncludePublicSubtitle =>
      'También recordarme lugares públicos de otros usuarios';

  @override
  String proximityRadiusLabel(int meters) {
    return 'Radio: $meters m';
  }

  @override
  String get proximityNeedsLocation =>
      'Activa la ubicación (siempre) para recibir recuerdos cercanos.';

  @override
  String get savePlaceTitle => 'Guardar lugar';

  @override
  String get savePlaceEditTitle => 'Completar / editar lugar';

  @override
  String get savePlaceSubmit => 'Guardar';

  @override
  String get savePlaceSubmitEdit => 'Guardar cambios';

  @override
  String saveStatusAfterSave(String status) {
    return 'Estado: $status. Puedes completarlo después.';
  }

  @override
  String get adminTitle => 'Panel administrador';

  @override
  String get adminTabCategories => 'Categorías';

  @override
  String get adminTabVehicles => 'Vehículos';
}
