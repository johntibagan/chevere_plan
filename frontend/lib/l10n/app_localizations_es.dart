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
  String get greetingMorning => 'Buenos días ☀️';

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
  String get labelLinked => 'Vinculado';

  @override
  String get labelCatalog => 'Catálogo';

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
  String get homeNearbyMemoryLabel => 'Recuerdo cercano';

  @override
  String get homeNearbyMemoryTitle => 'Te avisamos cuando estés cerca';

  @override
  String get homeDraftsHint => 'Completalo para poder compartirlo';

  @override
  String get homeOpenReports => 'Reportes abiertos';

  @override
  String get homeMySaves => 'Mis guardados';

  @override
  String get homeRecentSaves => 'Guardados recientes';

  @override
  String get homeSeeAll => 'Ver todos';

  @override
  String get homePopularNearby => 'Populares cerca';

  @override
  String get homeExploreLink => 'Explorar';

  @override
  String get homeQuickActions => 'Acciones rápidas';

  @override
  String get homeActionNearMe => 'Cerca de mí';

  @override
  String get homeActionMostSaved => 'Más guardados';

  @override
  String get homeActionByCategory => 'Por categoría';

  @override
  String get homeNearbyEmpty => 'No hay lugares públicos cerca por ahora.';

  @override
  String get homeNearbyNeedGps => 'Activa la ubicación para ver lugares cerca.';

  @override
  String get homeSavedToday => 'hoy';

  @override
  String get homeSavedYesterday => 'ayer';

  @override
  String homeSavedDaysAgo(int count) {
    return 'hace $count días';
  }

  @override
  String homeSavedWeeksAgo(int count) {
    return 'hace $count sem.';
  }

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
      'Aún no tienes planes. Crea uno y agrega sitios cuando quieras.';

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
  String get searchNoResults => 'Sin resultados.';

  @override
  String get searchQueryRequired => 'Escribe algo para buscar.';

  @override
  String get searchSearching => 'Buscando…';

  @override
  String get actionEdit => 'Editar';

  @override
  String get siteDetailTitle => 'Sitio';

  @override
  String get siteDetailTabInfo => 'Info';

  @override
  String get siteDetailTabReviews => 'Reseñas';

  @override
  String get siteDetailTabMore => 'Más info';

  @override
  String get siteDetailLocation => 'Ubicación';

  @override
  String get siteDetailOpenInMaps => 'Ver en Maps';

  @override
  String get siteDetailDirections => 'Cómo llegar';

  @override
  String get siteDetailNoCoords => 'Este sitio aún no tiene punto en el mapa.';

  @override
  String get saveNeedsMapPoint =>
      'Guardado. Falta el punto en el mapa para marcarlo completo.';

  @override
  String get siteDetailCategories => 'Categorías';

  @override
  String get siteDetailPrice => 'Precio estimado';

  @override
  String get siteDetailDistance => 'Distancia';

  @override
  String get siteDetailNotes => 'Notas';

  @override
  String get siteDetailAlsoShared => 'También guardado por';

  @override
  String get siteDetailCreatedBy => 'Creado por';

  @override
  String get siteDetailCreatedAt => 'Fecha de creación';

  @override
  String get siteDetailUpdatedAt => 'Última actualización';

  @override
  String siteDetailJoinedAt(String date) {
    return 'Se sumó el $date';
  }

  @override
  String get siteDetailCatalogBadge => 'Sitio del catálogo público';

  @override
  String siteDetailYourSaveAt(String date) {
    return 'Lo guardaste el $date';
  }

  @override
  String get siteDetailTraceEmpty => 'Sin más datos de trazabilidad por ahora.';

  @override
  String get siteDetailPhotos => 'Fotos';

  @override
  String get siteDetailSource => 'Origen';

  @override
  String get siteDetailNotPhysical => 'No es lugar físico';

  @override
  String get siteDetailReviewsSoonTitle => 'Reseñas próximamente';

  @override
  String get siteDetailReviewsSoonBody =>
      'Las calificaciones y comentarios de la comunidad llegarán en una fase posterior (especificación §8 / Fase 3).';

  @override
  String get siteDetailMoreSoonTitle => 'Más opciones próximamente';

  @override
  String get siteDetailMoreSoonBody =>
      'Aquí irán horario, ficha de negocio, reportes de precio y otras acciones del sitio.';

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

  @override
  String get actionLoadMore => 'Cargar más';

  @override
  String get actionClear => 'Limpiar';

  @override
  String get actionDone => 'Listo';

  @override
  String get actionAcceptContinue => 'Acepto y continuar';

  @override
  String get actionUse => 'Usar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionPaste => 'Pegar';

  @override
  String get actionReport => 'Reportar';

  @override
  String get clipboardEmpty => 'El portapapeles está vacío.';

  @override
  String get searchSimple => 'Simple';

  @override
  String get searchAdvanced => 'Avanzada';

  @override
  String get searchModeGeneral => 'Búsqueda general';

  @override
  String get searchModeAdvanced => 'Búsqueda avanzada';

  @override
  String get searchHintPlace => 'Busca lugares, ciudades...';

  @override
  String get searchLabelText => 'Texto (nombre o ciudad)';

  @override
  String get searchLabelLocationExtra => 'Ciudad o departamento (extra)';

  @override
  String get searchLabelCategory => 'Categoría';

  @override
  String get searchAny => 'Cualquiera';

  @override
  String get searchLabelTransport => 'Transporte';

  @override
  String get searchTransportPrivate => 'Particular';

  @override
  String get searchTransportPublic => 'Público';

  @override
  String get searchTransportOther => 'Otro';

  @override
  String get searchBudgetMin => 'Presupuesto min';

  @override
  String get searchBudgetMax => 'Presupuesto max';

  @override
  String get searchUseMyLocation => 'Usar mi ubicación + radio';

  @override
  String get searchRadiusKm => 'Radio (km)';

  @override
  String get searchHoursPlaceholder =>
      'Horario: cuando los sitios tengan horario oficial.';

  @override
  String get searchIncludePublic => 'Incluir sitios públicos';

  @override
  String searchLoadMoreRemaining(int count) {
    return 'Cargar más ($count restantes)';
  }

  @override
  String get searchEmptyHint => 'Escribe y pulsa la lupa o Enter.';

  @override
  String searchResultsCount(int count) {
    return '$count resultados';
  }

  @override
  String get searchChipAll => 'Todos';

  @override
  String get searchViewGrid => 'Grilla';

  @override
  String get searchViewList => 'Lista';

  @override
  String get plansSubtitle => 'Tus itinerarios guardados';

  @override
  String get plansCreateCardTitle => 'Crear un plan';

  @override
  String get plansCreateCardHint => 'Título, zona, paradas y presupuesto';

  @override
  String get plansSavedHeading => 'Mis planes guardados';

  @override
  String get plansStatusUpcoming => 'Próximo';

  @override
  String get routesSubtitle => 'Tu historial de aventuras';

  @override
  String get routesStatVisited => 'Visitados';

  @override
  String get routesStatCities => 'Ciudades';

  @override
  String get routesStatPlans => 'Planes';

  @override
  String get routesHistoryHeading => 'Historial de lugares';

  @override
  String get saveLocationSection => 'Ubicación';

  @override
  String get saveLocationDraftHint =>
      'Si no la tienes aún, guarda igual: queda en borrador.';

  @override
  String get saveLocationMap => 'Mapa';

  @override
  String get saveLocationGoogleLink => 'Enlace Google';

  @override
  String get saveLocationPointReady => 'Punto listo';

  @override
  String get saveLocationPickMap => 'Elegir en el mapa';

  @override
  String get saveLocationTapHint => 'Toca el mapa o busca el lugar';

  @override
  String get saveLocationClear => 'Quitar ubicación';

  @override
  String get saveExactPinTitle => '¿Guardar el punto exacto?';

  @override
  String get saveExactPinBody =>
      'Por nombre, Maps suele mostrar la ficha del lugar (fotos y reseñas). Guarda el pin solo si necesitas el punto preciso: entrada, mirador, finca, etc.';

  @override
  String get saveExactPinNo => 'No, solo el lugar';

  @override
  String get saveExactPinYes => 'Sí, guardar pin';

  @override
  String get saveExactPinSwitch => 'Punto exacto en el mapa';

  @override
  String get saveExactPinSwitchHint =>
      'Si está apagado, Maps abre la ficha por nombre. Enciéndelo para rutas y el pin preciso.';

  @override
  String get saveMapsPasteLabel => 'Pegar enlace de Google Maps';

  @override
  String get saveMapsPasteHelper => 'maps.app.goo.gl o google.com/maps';

  @override
  String get saveMapsNeedExactPin =>
      'No se obtuvo el punto exacto. Ábrelo en el mapa interactivo y confirma el pin.';

  @override
  String get saveMapsNeedGoogleKey =>
      'Falta GOOGLE_MAPS_API_KEY en el build. Corre con: flutter run --dart-define-from-file=.env';

  @override
  String get planSearchCompleteOnlyHint =>
      'Solo aparecen sitios completos con ubicación en el mapa.';

  @override
  String get planSearchEmptyQueryHint =>
      'Deja el buscador vacío y toca buscar para ver todos tus sitios elegibles.';

  @override
  String get planSearchHint => 'Nombre, ciudad… o vacío = todos';

  @override
  String get planOpeningMaps => 'Preparando ruta en Maps…';

  @override
  String get saveMapsApproxPin =>
      'Punto aproximado. Confirma o ajusta el pin en el mapa.';

  @override
  String get actionLoading => 'Cargando…';

  @override
  String get saveMapsNeedLink => 'Pega un enlace de Google Maps.';

  @override
  String get saveMapsNeedCity =>
      'Se leyó el enlace. Completa ciudad o elige en el mapa.';

  @override
  String saveLocationAppliedNamed(String name, String city) {
    return 'Ubicación aplicada: $name, $city.';
  }

  @override
  String get saveLocationApplied => 'Ubicación aplicada.';

  @override
  String get saveNameDetails => 'Nombre y detalles';

  @override
  String get savePlaceName => 'Nombre del lugar';

  @override
  String get savePlaceNameHelper => 'El mapa o el enlace suelen completarlo.';

  @override
  String get saveDepartment => 'Departamento';

  @override
  String get saveCity => 'Ciudad';

  @override
  String get saveAddress => 'Dirección';

  @override
  String get saveGeoCatalogMissing =>
      'Catálogo no cargado. Ejecuta el reset DIVIPOLA.';

  @override
  String get savePickFromList => 'Elige una opción de la lista';

  @override
  String get savePickDeptFirst => 'Primero elige el departamento';

  @override
  String get saveLinksSection => 'Enlaces';

  @override
  String get saveSocialPaste => 'Pegar enlace (IG, TikTok, FB…)';

  @override
  String get saveSocialInvalid => 'Pega un enlace http(s) válido.';

  @override
  String get saveSocialDuplicate => 'Ese enlace ya está en la lista.';

  @override
  String get saveCategoriesSection => 'Categorías';

  @override
  String get saveCategoryHint => 'Ej. nadar, tejo, plaza, bar…';

  @override
  String get saveCategoryNone => 'Sin coincidencias';

  @override
  String get saveCategorySuggestHint =>
      'Se sugiere sola; o busca / abre el árbol.';

  @override
  String get saveCategoryTree => 'Árbol';

  @override
  String get saveCategorySuggested =>
      'Sugerida según el nombre / Maps (puedes cambiarla)';

  @override
  String get saveCategoryFallbackOtros =>
      'Sin coincidencia clara → Otros (puedes cambiarla)';

  @override
  String get saveVisibilitySection => 'Visibilidad';

  @override
  String get saveIsPhysical => 'Es un lugar físico';

  @override
  String get saveIsPhysicalSubtitle =>
      'Si no lo es (receta, tip…), quedará siempre privado';

  @override
  String get saveMakePublic => 'Hacer público';

  @override
  String get savePublicNeedLocation =>
      'Primero indica ubicación para poder publicarlo';

  @override
  String get savePublicNonPhysical =>
      'Los contenidos no físicos quedan privados';

  @override
  String get savePublicVisible => 'Visible para otros en la capa pública';

  @override
  String get saveAddPhoto => 'Añadir foto (máx. 15)';

  @override
  String get savePhotoReady => 'Foto lista para subir';

  @override
  String get saveDraftFooter =>
      'Puedes guardar ya: sin ubicación queda en borrador y te recordaremos completarlo.';

  @override
  String get saveNameSection => 'Nombre';

  @override
  String get savePublicSection => 'Público';

  @override
  String get saveNameRequired => 'Escribe un nombre para guardar.';

  @override
  String get saveAddSection => 'Añadir sección';

  @override
  String get saveExtraDetails => 'Detalles';

  @override
  String get saveExtraPhoto => 'Fotos';

  @override
  String get saveExtraPhysical => 'Visibilidad del lugar físico';

  @override
  String get saveInfoLocation =>
      'Mapa o enlace de Google. El pin habilita Público. Sin ubicación el guardado queda en borrador.';

  @override
  String get saveInfoExactPin =>
      'Encendido guarda el pin para rutas. Apagado abre la ficha en Maps por nombre y quita las coordenadas.';

  @override
  String get saveInfoName =>
      'Obligatorio. El mapa o el enlace de Google suelen completarlo.';

  @override
  String get saveInfoPublic =>
      'Privado por defecto. Para publicar hace falta lugar físico y pin en el mapa. Sin pin el interruptor queda desactivado.';

  @override
  String get saveInfoDetails =>
      'Departamento y ciudad de la lista oficial; dirección opcional. El mapa suele rellenarlos.';

  @override
  String get saveInfoLinks =>
      'Instagram, TikTok u otra red del lugar. Pegá el enlace en el campo.';

  @override
  String get saveInfoCategories =>
      'Se sugiere según el nombre. Al crear, si no hay coincidencia queda Otros.';

  @override
  String get saveInfoPhoto => 'Hasta 15 fotos. Se suben al guardar.';

  @override
  String get saveInfoPhysical =>
      'Por defecto es un lugar físico. Si es receta, tip u otro contenido, apagá esto: quedará siempre privado.';

  @override
  String get sameSiteTitle => '¿Es el mismo sitio?';

  @override
  String get sameSiteNew => 'Es uno nuevo';

  @override
  String get sameSiteYes => 'Usarlo y reseñar';

  @override
  String get sameSiteReviewPublic => 'Usarlo + reseña visible';

  @override
  String get sameSiteJournalPrivate => 'Usarlo + bitácora privada';

  @override
  String get sameSiteKeepEditing => 'Seguir editando';

  @override
  String get sameSiteSaveAnyway => 'Guardar de todas formas';

  @override
  String get sameSiteHardBody =>
      'Ya existe un sitio público parecido. Puedes usarlo (quedarás como «compartido por») o guardar el tuyo de todas formas.';

  @override
  String get sameSiteSoftBody =>
      'Ya existe un sitio público parecido. Úsalo para evitar duplicados, o sigue editando.';

  @override
  String get sameSiteStaffHint =>
      'Hay un sitio público parecido. Edítalo desde su ficha; no creamos duplicados.';

  @override
  String get privacyBlockTitle => 'No se puede hacer privado';

  @override
  String get privacyBlockCatalog =>
      'Este sitio es del catálogo público y debe seguir visible para todos.';

  @override
  String get privacyBlockOthers =>
      'Otros usuarios ya lo guardaron, aportaron o lo usan en planes. Mientras eso exista, debe seguir público.';

  @override
  String get reviewEditorTitle => 'Tu reseña';

  @override
  String get reviewRatingLabel => 'Puntuación';

  @override
  String get reviewCommentLabel => 'Comentario';

  @override
  String get reviewAddPhoto => 'Foto';

  @override
  String get reviewSave => 'Guardar reseña';

  @override
  String get reviewMaxPhotos => 'Máximo 3 fotos por reseña.';

  @override
  String get reviewEmpty => 'Aún no hay reseñas. Sé el primero.';

  @override
  String get reviewWrite => 'Escribir reseña';

  @override
  String get reviewEditMine => 'Editar';

  @override
  String get reviewDelete => 'Eliminar';

  @override
  String get reviewDeleteTitle => '¿Eliminar reseña?';

  @override
  String get reviewDeleteBody =>
      'Se borrará esta reseña y sus fotos. No se puede deshacer.';

  @override
  String get reviewDeleted => 'Reseña eliminada.';

  @override
  String get reviewMakePublic => 'Visible en la ficha';

  @override
  String get reviewPublicHint =>
      'Aparece en la ficha y cuenta para el promedio';

  @override
  String get reviewPrivateHint => 'Solo tú la ves (bitácora / historial)';

  @override
  String get reviewPrivateBadge => 'Bitácora';

  @override
  String staffModeBanner(String role) {
    return '$role: privilegios de dueño en sitios y contenido público (las bitácoras privadas solo las ve su autor).';
  }

  @override
  String get staffRoleAdmin => 'Admin';

  @override
  String get staffRoleRoot => 'Root';

  @override
  String get visibilityTooltipPublic => 'Visible para todos';

  @override
  String get visibilityTooltipPrivate => 'Solo tú';

  @override
  String get reviewFilterAll => 'Todas';

  @override
  String get reviewFilterMine => 'Mías';

  @override
  String get reviewFilterEmpty => 'Ninguna reseña con ese filtro.';

  @override
  String get reviewSortLabel => 'Ordenar';

  @override
  String get reviewSortNewest => 'Más recientes';

  @override
  String get reviewSortOldest => 'Más antiguas';

  @override
  String get reviewSortRatingHigh => 'Mejor puntuación';

  @override
  String get reviewSortRatingLow => 'Peor puntuación';

  @override
  String reviewAvg(String avg, int count) {
    return '$avg · $count reseñas';
  }

  @override
  String get locationPickerTitle => 'Elegir ubicación';

  @override
  String get locationPickerSearchHint => 'Buscar lugar, dirección, ciudad…';

  @override
  String get locationMyLocation => 'Mi ubicación';

  @override
  String get locationConfirm => 'Confirmar';

  @override
  String get locationNoMatches =>
      'Sin coincidencias. Prueba otro nombre o toca el mapa.';

  @override
  String get locationNeedGps =>
      'Activa la ubicación para centrar el mapa en ti.';

  @override
  String get photoDeleteTitle => 'Eliminar foto';

  @override
  String get photoDeleteConfirm => '¿Quieres eliminar esta foto del sitio?';

  @override
  String get photoReportTitle => 'Reportar foto';

  @override
  String get photoReportSend => 'Enviar reporte';

  @override
  String get directionsMaps => 'Cómo llegar (Google Maps)';

  @override
  String get planCreateTitle => 'Armar plan';

  @override
  String get planCreateStepTitleHint =>
      'Ponle un nombre al plan. Luego eliges los sitios.';

  @override
  String get actionNext => 'Siguiente';

  @override
  String get planTitleOptional => 'Título (opcional)';

  @override
  String get planTabSearch => 'Buscar';

  @override
  String get planTabResults => 'Resultados';

  @override
  String planTabAdded(int count) {
    return 'Agregados ($count)';
  }

  @override
  String get planTimelineEmpty => 'Aún no hay sitios. Busca y agrégalos.';

  @override
  String get planSearchFirst => 'Busca arriba y verás los resultados aquí.';

  @override
  String get planAddSite => 'Agregar al plan';

  @override
  String get planSiteAdded => 'Sitio agregado al plan.';

  @override
  String get planStatusDraft => 'Borrador';

  @override
  String planStopsCount(int count) {
    return '$count sitios';
  }

  @override
  String get planMenuAddSites => 'Agregar sitios';

  @override
  String get planMenuShare => 'Compartir';

  @override
  String get planMenuOpenMaps => 'Llevar a Maps';

  @override
  String get planMenuMore => 'Más opciones';

  @override
  String get planItinerary => 'Itinerario';

  @override
  String get planStatStops => 'Paradas';

  @override
  String get planStatBudget => 'Presupuesto';

  @override
  String get planStatZone => 'Zona';

  @override
  String get cardSavedHeart => 'En tus guardados';

  @override
  String get favoriteAdd => 'Agregar a favoritos';

  @override
  String get favoriteRemove => 'Quitar de favoritos';

  @override
  String get planMarkDone => 'Marcar como hecho';

  @override
  String get planMarkPending => 'Marcar pendiente';

  @override
  String get planRemoveStop => 'Quitar del plan';

  @override
  String get planReorderStop => 'Reordenar';

  @override
  String get planReorderHint =>
      'Arrastra el ícono para cambiar el orden de los sitios.';

  @override
  String get planNoPendingStops => 'No hay sitios pendientes para Maps.';

  @override
  String get planStopsMissingCoords =>
      'Algún sitio pendiente no tiene ubicación.';

  @override
  String get planNeedLocation =>
      'Activa la ubicación para usar tu posición como inicio.';

  @override
  String get planShareCopied => 'Plan copiado al portapapeles.';

  @override
  String get planDeleteTitle => 'Eliminar plan';

  @override
  String get planDeleteConfirm => '¿Eliminar este plan y sus paradas?';

  @override
  String get adminActive => 'Activa';

  @override
  String get adminAgeRestricted => 'Restringida +18';

  @override
  String get adminEditTransport => 'Editar transporte';

  @override
  String get adminKmInvalid => 'Km inválido';
}
