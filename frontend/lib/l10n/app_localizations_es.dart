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
  String get appTagline =>
      'Guarda, organiza y descubre los mejores planes de Colombia';

  @override
  String get navPressBackAgainToExit => 'Pulsa atrás otra vez para salir.';

  @override
  String get navHome => 'Inicio';

  @override
  String get navExplore => 'Explorar';

  @override
  String get navPlans => 'Planes';

  @override
  String get navRoutes => 'Rutas';

  @override
  String get moreMenuOpenTooltip => 'Más opciones';

  @override
  String get moreMenuManageAccount => 'Ver perfil';

  @override
  String get moreMenuProximitySubtitle => 'Radio y sitios públicos';

  @override
  String get moreMenuDuplicateRadiusSubtitle =>
      'Al guardar un sitio (siempre en metros)';

  @override
  String get duplicateRadiusTitle => 'Mismo sitio al guardar';

  @override
  String get duplicateRadiusSubtitle =>
      'Si hay otro sitio dentro de este radio, te avisamos para no duplicarlo. Por defecto 100 m.';

  @override
  String get duplicateRadiusMetersInfo =>
      'Este radio va siempre en metros. La unidad de distancia del menú (km, millas…) aplica en recuerdos cercanos, Explorar y etiquetas; no aquí.';

  @override
  String get moreMenuDistanceUnit => 'Unidad de distancia';

  @override
  String get moreMenuDistanceUnitSubtitle => 'Cómo se muestran km, millas…';

  @override
  String get distanceUnitSheetTitle => 'Unidad de distancia';

  @override
  String get distanceUnitSheetHint =>
      'Se aplica en recuerdos cercanos, Explorar y etiquetas de distancia. El radio de sitios duplicados siempre usa metros.';

  @override
  String profileDuplicateRadiusLabel(int meters) {
    return 'Radio: $meters m';
  }

  @override
  String get moreMenuReports => 'Reportes';

  @override
  String get moreMenuSignOut => 'Cerrar sesión';

  @override
  String moreMenuAppVersion(String version) {
    return 'Versión $version';
  }

  @override
  String moreMenuAppEnvironment(String env) {
    return 'Entorno: $env';
  }

  @override
  String get moreMenuTheme => 'Tema';

  @override
  String get moreMenuThemeLight => 'Claro';

  @override
  String get moreMenuThemeDark => 'Oscuro';

  @override
  String get moreMenuThemeSystem => 'Sistema';

  @override
  String get moreMenuProfileComingTitle => 'Tu perfil';

  @override
  String get moreMenuProfileComingBody =>
      'Pronto vas a poder ver y editar tu cuenta desde aquí.';

  @override
  String get profileSettingsTitle => 'Tu perfil';

  @override
  String get profileUsernameLabel => 'Nombre de usuario';

  @override
  String get profileUsernameHint => 'usuario';

  @override
  String get profileUsernameHelp =>
      '3–20 caracteres: letras, números, punto o guion bajo. Se muestra como @usuario en reseñas y fotos.';

  @override
  String get profileUsernameAvailable => 'Disponible';

  @override
  String get profileUsernameTaken => 'Ya está en uso';

  @override
  String get profileUsernameInvalid =>
      'Solo letras minúsculas, números, punto o guion bajo';

  @override
  String get profileUsernameLength => 'Entre 3 y 20 caracteres';

  @override
  String get profileUsernameReserved => 'Ese nombre no está disponible';

  @override
  String get profileUsernameChecking => 'Comprobando…';

  @override
  String get profileUsernameSuggestions => 'Sugerencias';

  @override
  String get profileUsernameRequired =>
      'Elegí un nombre de usuario para continuar';

  @override
  String get profileAvatarSection => 'Foto de perfil';

  @override
  String get profileUseGoogleAvatar => 'Usar foto de Google';

  @override
  String get profileUseGoogleAvatarHint =>
      'Por defecto no se muestra. Podés activarla o subir otra.';

  @override
  String get profileAvatarSourceLabel => 'Foto activa';

  @override
  String get profileAvatarSourceGoogle => 'Google';

  @override
  String get profileAvatarSourceCustom => 'Personalizada';

  @override
  String get profileChangePhoto => 'Cambiar foto';

  @override
  String get profileRemoveCustomPhoto => 'Quitar foto propia';

  @override
  String get profileNoPhoto => 'Sin foto (iniciales)';

  @override
  String get profileSaved => 'Perfil actualizado';

  @override
  String get profileSaveUsernameFirst => 'Guardá un nombre de usuario válido';

  @override
  String profileUsernameLocked(String date) {
    return 'Podés cambiar el @usuario cada 3 meses. Próximo cambio: $date.';
  }

  @override
  String get profileUsernameMustSet =>
      'Elegí un @usuario para usar la app. Se muestra en reseñas y fotos; las relaciones internas usan tu id, no el nombre.';

  @override
  String get profileUsernameCooldownToast =>
      'Todavía no podés cambiar el nombre de usuario.';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionDiscard => 'Descartar';

  @override
  String get actionSave => 'Guardar';

  @override
  String get discardChangesTitle => '¿Descartar cambios?';

  @override
  String get discardChangesBody => 'Se perderá lo que no hayas guardado.';

  @override
  String get discardChangesStay => 'Seguir editando';

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
  String get loginAcceptLegal => 'Acepto los';

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
  String get labelPublic => 'Público';

  @override
  String get labelCard => 'Tarjeta';

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
  String get homeDraftsHint =>
      'Sin punto en el mapa no entra en Explorar, planes ni rutas';

  @override
  String get draftNeedsMapPointWarning =>
      'Este sitio está en borrador: no se tendrá en cuenta en Explorar, planes, rutas ni recuerdos cercanos hasta que asignes un punto en el mapa.';

  @override
  String get nonPhysicalCardWarning =>
      'Esta tarjeta no es un lugar físico: no se tendrá en cuenta en Explorar, planes, rutas ni recuerdos cercanos.';

  @override
  String get homeCardsSection => 'Tarjetas';

  @override
  String get homeCardsEmpty =>
      'Aún no tienes tarjetas (contenido que no es un lugar).';

  @override
  String get moreMenuCardsSubtitle => 'Contenido que no es un lugar físico';

  @override
  String get homeOpenReports => 'Reportes abiertos';

  @override
  String get homeMySaves => 'Mis guardados';

  @override
  String get homeRecentSaves => 'Guardados recientes';

  @override
  String get homeSeeAll => 'Ver más';

  @override
  String get homeFeedView => 'Vista';

  @override
  String get homeEvents => 'Eventos';

  @override
  String get homeEventsComingSoon => 'Próximamente.';

  @override
  String get homePopularNearby => 'Populares cerca';

  @override
  String get homeExploreLink => 'Explorar';

  @override
  String get homeQuickActions => 'Acciones rápidas';

  @override
  String get homeQuickActionsPin => 'Fijar abajo';

  @override
  String get homeQuickActionsUnpin => 'Desfijar';

  @override
  String get homeActionNearMe => 'Cerca de mí';

  @override
  String get homeActionMySaves => 'Mis guardados';

  @override
  String get homeActionMyFavorites => 'Mis favoritos';

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
  String get homeDiscardTitle => '¿Descartar guardado?';

  @override
  String homeDiscardConfirm(String name) {
    return 'Se quitará \"$name\" de tu lista.';
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
  String get routesTitle => 'Mis rutas';

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
  String get reportsActioned => 'Eliminar foto';

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
      'Guardado como borrador. Sin punto en el mapa no entra en Explorar, planes, rutas ni recuerdos cercanos.';

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
  String get photoAddTooltip => 'Añadir foto';

  @override
  String get siteDetailPhotosEmptyManage =>
      'Sin fotos. Usa el icono de cámara para añadir.';

  @override
  String get siteDetailPhotosEmpty => 'Este sitio no tiene fotos.';

  @override
  String get sitePhotoViewerClose => 'Cerrar';

  @override
  String sitePhotoViewerIndex(int current, int total) {
    return '$current de $total';
  }

  @override
  String get sitePhotoMenuTooltip => 'Opciones de la foto';

  @override
  String get sitePhotoSetAsCover => 'Usar como portada del sitio';

  @override
  String get sitePhotoAlreadyCover => 'Esta es la portada';

  @override
  String sitePhotoUploadedBy(String name) {
    return 'Subida por $name';
  }

  @override
  String sitePhotoUploadedAt(String date) {
    return '$date';
  }

  @override
  String get sitePhotoUploaderUnknown => 'alguien';

  @override
  String get photoCoverSet => 'Portada del sitio actualizada.';

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
  String proximityRadiusLabel(String value, String symbol) {
    return 'Radio: $value $symbol';
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
  String get adminTabDistanceUnits => 'Distancias';

  @override
  String get adminStatDistanceUnits => 'Unidades';

  @override
  String get adminEditDistanceUnit => 'Editar unidad de distancia';

  @override
  String get adminNewDistanceUnit => 'Nueva unidad';

  @override
  String get adminDistanceSymbol => 'Símbolo (m, km, mi…)';

  @override
  String get adminDistanceMetersPerUnit => 'Metros por unidad';

  @override
  String get adminDistanceDefault => 'Por defecto (usuarios nuevos)';

  @override
  String get adminDistanceSlug => 'Slug (único)';

  @override
  String get adminDistanceInvalidMeters => 'Metros por unidad inválido.';

  @override
  String get adminDistanceInvalidSlug =>
      'Slug inválido (solo letras, números y _).';

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
  String searchRadiusLabel(String symbol) {
    return 'Radio ($symbol)';
  }

  @override
  String searchRadiusInvalid(String min, String max, String symbol) {
    return 'Radio inválido. Usá entre $min y $max $symbol.';
  }

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
  String get searchEmptyHint =>
      'Escribí y tocá la lupa (o Enter). El texto no es obligatorio.';

  @override
  String searchResultsCount(int count) {
    return '$count resultados';
  }

  @override
  String get searchMySavesOnly => 'Mis guardados';

  @override
  String get searchMyFavoritesOnly => 'Mis favoritos';

  @override
  String get searchResetFilters => 'Borrar filtros';

  @override
  String get searchCategoryMulti => 'Varias categorías';

  @override
  String get searchChipAll => 'Todos';

  @override
  String get searchViewGrid => 'Grilla';

  @override
  String get searchViewList => 'Lista';

  @override
  String get feedLayoutList => 'Lista';

  @override
  String get feedLayoutGrid2 => 'Cuadrícula 2';

  @override
  String get feedLayoutGrid3 => 'Cuadrícula 3';

  @override
  String get feedLayoutGrid4 => 'Cuadrícula 4';

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
  String get routesHistoryHeading => 'Historial';

  @override
  String get saveLocationSection => 'Ubicación';

  @override
  String get saveLocationDraftHint =>
      'Si no la tienes aún, guarda igual: queda en borrador.';

  @override
  String get saveLocationMap => 'Mapa';

  @override
  String get saveLocationGoogleLink => 'Enlace';

  @override
  String get saveLocationCamera => 'Cámara';

  @override
  String get saveCameraHint =>
      'Toma una foto del lugar. Al confirmarla en la cámara se guarda la imagen y, si aún no hay ubicación, se captura la tuya automáticamente.';

  @override
  String get saveCameraTake => 'Tomar foto';

  @override
  String get saveCameraLocating => 'Capturando ubicación…';

  @override
  String get saveCameraNeedLocation =>
      'Activa la ubicación para registrar el sitio.';

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
  String get saveExactPinMapsPin =>
      'Maps abrirá el pin (lat, lng), no el buscador.';

  @override
  String get saveExactPinMapsPlace =>
      'Maps abrirá la ficha del lugar por nombre.';

  @override
  String get saveExactPinSwitchHint =>
      'Apagado (recomendado): Maps abre la ficha del lugar por nombre. Encendido: abre el pin (lat, lng).';

  @override
  String get saveMapsPasteLabel => 'Pegar enlace de Google Maps';

  @override
  String get saveLocationSearchHint => 'Buscar o pegar enlace de Google Maps';

  @override
  String get saveMapsPasteHelper => 'maps.app.goo.gl o google.com/maps';

  @override
  String get saveMapsNeedExactPin =>
      'No se obtuvo el punto exacto. Ábrelo en el mapa interactivo y confirma el pin.';

  @override
  String get saveMapsNeedGoogleKey =>
      'Falta GOOGLE_MAPS_API_KEY. Corre: flutter run --dart-define-from-file=env/test.env';

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
  String get savePhysicalLabel => 'Lugar físico';

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
  String get savePhotoUploadPartialFail =>
      'El sitio se guardó, pero una o más fotos no se subieron. Podés añadirlas después desde la ficha.';

  @override
  String savePhotoMaxReached(int max) {
    return 'Máximo $max fotos por sitio.';
  }

  @override
  String get saveDraftFooter =>
      'Puedes guardar ya: sin ubicación queda en borrador y te recordaremos completarlo.';

  @override
  String get saveNameSection => 'Nombre';

  @override
  String get saveExtraNameVisibility => 'Nombre - Visibilidad';

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
  String get saveInfoLocation =>
      'Mapa o enlace de Google. El pin habilita Público. Sin ubicación el guardado queda en borrador.';

  @override
  String get saveInfoExactPin =>
      'Se guardan las dos: el lugar (nombre / Place ID) y el pin. El interruptor solo elige cuál abre Maps. Apagado = ficha del lugar. Encendido = coordenadas.';

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
  String get sameSiteReviewPublic => 'Usarlo + reseña pública';

  @override
  String get sameSiteReviewPublicHint =>
      'Escribes una reseña visible en la ficha del sitio. Cuenta en el promedio público.';

  @override
  String get sameSiteJournalPrivate => 'Usarlo + reseña privada';

  @override
  String get sameSiteJournalPrivateHint =>
      'Escribes una reseña solo para ti en ese sitio. No aparece en la ficha pública.';

  @override
  String get sameSiteReviewPrivateHint =>
      'Escribes una reseña solo para ti en ese sitio. No aparece en la ficha pública.';

  @override
  String get sameSiteKeepEditing => 'Seguir con el mío';

  @override
  String get sameSiteKeepEditingHint =>
      'Cierra este aviso y seguí editando tu guardado como sitio nuevo.';

  @override
  String get sameSiteSaveAnyway => 'Guardar de todas formas';

  @override
  String get sameSiteSaveAnywayHint =>
      'Creas un sitio público nuevo aunque haya uno parecido en Explorar.';

  @override
  String get sameSiteFavorite => 'Agregar a mis favoritos';

  @override
  String get sameSiteFavoriteHint =>
      'No crea un guardado nuevo. Lo agrega a favoritos y abre su ficha.';

  @override
  String get sameSiteFavoriteTitle => '¿Agregar a favoritos?';

  @override
  String get sameSiteFavoriteBody =>
      'Se descarta este guardado. El sitio quedará en Mis favoritos y verás su ficha.';

  @override
  String get sameSiteLinkNeedPublic =>
      'La reseña pública solo aplica en sitios públicos.';

  @override
  String get sameSitePickSiteFirst =>
      'Toca Usar como en una tarjeta; luego elige una opción abajo.';

  @override
  String get sameSiteHardBody =>
      'Ya existe un sitio público parecido. Puedes usarlo (quedarás como «compartido por») o guardar el tuyo de todas formas.';

  @override
  String get sameSiteSoftBody =>
      'Ya existe un sitio público parecido. Úsalo para evitar duplicados, o sigue editando.';

  @override
  String get sameSitePickHint => 'En cada tarjeta: Ver ficha o Usar como.';

  @override
  String get sameSiteHardPickHint =>
      'Tocá Usar como si es el mismo sitio; abajo podés guardar de todas formas.';

  @override
  String get sameSiteTapForDetail => 'Ver ficha';

  @override
  String get sameSiteUseIt => 'Usar como';

  @override
  String get sameSiteUsePickOption => 'Elige una opción y confirma abajo.';

  @override
  String get sameSiteUseConfirmSave => 'Confirmar';

  @override
  String get sameSiteDiscardConfirmTitle => '¿Usar este sitio?';

  @override
  String get sameSiteDiscardConfirmBodyReview =>
      'Se descarta tu guardado nuevo. Abrirás reseña pública en este sitio.';

  @override
  String get sameSiteDiscardConfirmBodyJournal =>
      'Se descarta tu guardado nuevo. Abrirás bitácora privada en este sitio.';

  @override
  String get sameSiteDiscardConfirmBodyFavorite =>
      'Se descarta tu guardado nuevo. El sitio queda en favoritos.';

  @override
  String get sameSiteDiscardConfirmBodyGeneric =>
      'Se descarta tu guardado nuevo e irás al sitio elegido.';

  @override
  String get sameSiteOptionReviewPublic => 'Reseña pública';

  @override
  String get sameSiteOptionReviewPrivate => 'Reseña privada';

  @override
  String get sameSiteOptionJournal => 'Reseña privada';

  @override
  String get sameSiteOptionFavorite => 'Agregar a favoritos';

  @override
  String get sameSiteInfoTitle => 'Información';

  @override
  String get sameSiteMarkThis => 'Marcar este';

  @override
  String sameSiteMetersAway(int meters) {
    return 'a $meters m';
  }

  @override
  String get sameSiteStaffHint =>
      'Hay un sitio público parecido. Edítalo desde su ficha; no creamos duplicados.';

  @override
  String get privacyBlockTitle => 'Debe seguir público';

  @override
  String get privacyBlockReasonCatalog => 'Es del catálogo público.';

  @override
  String privacyBlockReasonSaves(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas lo tienen guardado.',
      one: 'Otra persona lo tiene guardado.',
    );
    return '$_temp0';
  }

  @override
  String privacyBlockReasonContributors(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hay aportes de $count usuarios.',
      one: 'Hay un aporte de otro usuario.',
    );
    return '$_temp0';
  }

  @override
  String privacyBlockReasonPlanStops(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Está en planes de $count usuarios.',
      one: 'Está en un plan de otro usuario.',
    );
    return '$_temp0';
  }

  @override
  String privacyBlockReasonReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hay $count reseñas públicas de otros usuarios.',
      one: 'Hay una reseña pública de otro usuario.',
    );
    return '$_temp0';
  }

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
      'Se borrará la reseña y sus fotos. No se puede deshacer.';

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
  String get reviewPublishConfirmTitle => '¿Publicar en la ficha?';

  @override
  String get reviewPublishConfirmBody =>
      'Esto será visible para otros usuarios.';

  @override
  String get reviewPublishAction => 'Publicar';

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
  String get locationMarkMapFirst =>
      'Buscá un lugar o tocá el mapa para confirmar.';

  @override
  String get locationPinOnly => 'Solo este punto';

  @override
  String get locationNearbyPlace => 'Lugar';

  @override
  String get locationNoMatches =>
      'Sin coincidencias. Prueba otro nombre o toca el mapa.';

  @override
  String get locationNeedGps =>
      'Activa la ubicación para centrar el mapa en ti.';

  @override
  String get photoDeleteTitle => '¿Eliminar foto?';

  @override
  String get photoDeleteConfirm =>
      'Se borrará del sitio. No se puede deshacer.';

  @override
  String get photoReportTitle => '¿Reportar foto?';

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
  String get planMenuEdit => 'Editar plan';

  @override
  String get planEditTitle => 'Editar plan';

  @override
  String get planEditTitleHint => 'Nombre, zona y presupuesto de este plan.';

  @override
  String get planEditSaved => 'Plan actualizado.';

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
  String get planDeleteTitle => '¿Eliminar plan?';

  @override
  String get planDeleteConfirm => 'Se borrará el plan y sus paradas.';

  @override
  String get adminActive => 'Activa';

  @override
  String get adminEditTransport => 'Editar transporte';

  @override
  String get adminKmInvalid => 'Km inválido';

  @override
  String get comingSoonBadge => 'Próximamente';

  @override
  String get comingSoonAiTitle => 'Armame un plan con IA';

  @override
  String get comingSoonAiBody =>
      'La generación automática de planes estará disponible más adelante. Podés armar el plan eligiendo sitios que ya guardaste.';

  @override
  String get comingSoonTransportTitle => 'Transporte entre paradas';

  @override
  String get comingSoonTransportBody =>
      'El cálculo de transporte sugerido entre paradas estará disponible más adelante.';

  @override
  String get planZoneHint => 'Ej. Villa de Leyva, Boyacá';

  @override
  String get planIncludePublicSubtitle =>
      'Suma sitios públicos de otros a las opciones';

  @override
  String get planCreateNextStops => 'Siguiente: armar paradas';

  @override
  String get planCreateAiCta => 'Armame un plan con IA';

  @override
  String get categoryPickerSelectGroup => 'Seleccionar todo el grupo';

  @override
  String categoryPickerSummary(int total, int groups) {
    return '$total categorías · $groups grupos';
  }

  @override
  String categoryPickerResults(int count) {
    return '$count resultado(s)';
  }

  @override
  String get adminStatCategories => 'Categorías';

  @override
  String get adminStatVehicles => 'Vehículos';

  @override
  String get adminStatReports => 'Reportes abiertos';

  @override
  String get errorGeneric => 'Error en la app. Intenta de nuevo.';

  @override
  String get errorGenericLead => 'Error en la app.';

  @override
  String get errorRetryAction => 'Intenta de nuevo';

  @override
  String get errorProblemToast => 'Se ha presentado un problema.';

  @override
  String get errorLoadRetry => 'No se pudo cargar. Intenta de nuevo.';

  @override
  String get siteDetailOpenMapsFail => 'No se pudo abrir Google Maps.';

  @override
  String get photoTermsTitle => 'Antes de subir la foto';

  @override
  String get photoTermsBody =>
      'La foto debe ser de turismo, gastronomía u ocio. Sin contenido sexual, ilegal o de acoso.';

  @override
  String get photoAdded => 'Foto añadida.';

  @override
  String get photoDeleted => 'Foto eliminada.';

  @override
  String get photoReportReason => 'Motivo (opcional)';

  @override
  String get photoReportSent =>
      'Reporte enviado. Un administrador lo revisará.';

  @override
  String get reviewReportTitle => '¿Reportar reseña?';

  @override
  String get reviewReportSent =>
      'Reporte enviado. Un administrador lo revisará.';

  @override
  String get reviewReportAlready => 'Ya reportaste esta reseña.';

  @override
  String get reportsReviewFallback => 'Reseña reportada';

  @override
  String get reportsReviewLabel => 'Reseña';

  @override
  String get reportsPhotoLabel => 'Foto';

  @override
  String get adminInactive => 'Inactiva';

  @override
  String get adminKeywords => 'Palabras clave';

  @override
  String get adminKeywordsHint => 'Separadas por coma (ej. nadar, agua, pool)';

  @override
  String get adminNameEs => 'Nombre (es)';

  @override
  String get adminEditCategory => 'Editar categoría';

  @override
  String get adminEditSubcategory => 'Editar subcategoría';

  @override
  String get adminTransportActive => 'Activo';

  @override
  String get adminTransportMaxKm => 'Máx. km por defecto (vacío = sin tope)';

  @override
  String get locationMapsUnavailable =>
      'El mapa no está disponible. Busca o toca el mapa.';

  @override
  String get locationSearchMinChars =>
      'Escribe al menos 3 letras y toca buscar.';

  @override
  String get locationGpsFail =>
      'No se pudo obtener tu ubicación. Busca o toca el mapa.';

  @override
  String get locationProviderGoogle => 'Google Maps · buscar solo con 🔍';

  @override
  String get locationProviderFallback => 'Búsqueda alternativa activa';

  @override
  String get locationProviderNone => 'Mapa no disponible';

  @override
  String formatDistanceKm(String km) {
    return '$km km';
  }

  @override
  String formatDistanceValue(String value, String symbol) {
    return '$value $symbol';
  }

  @override
  String get defaultUserDisplayName => 'Usuario';

  @override
  String get reviewAuthorYou => 'Tú';

  @override
  String get notifChannelProximityName => 'Recuerdos cercanos';

  @override
  String get notifChannelProximityDesc =>
      'Avisos cuando estás cerca de un lugar guardado';

  @override
  String get notifChannelDraftName => 'Recordatorios de borradores';

  @override
  String get notifChannelDraftDesc =>
      'Te recuerda completar lugares guardados incompletos';

  @override
  String get notifChannelEventName => 'Eventos de interés';

  @override
  String get notifChannelEventDesc =>
      'Avisos de eventos cerca de tus guardados (próximamente)';

  @override
  String get notifChannelSummaryName => 'Resúmenes';

  @override
  String get notifChannelSummaryDesc =>
      'Resumen mensual de planes y visitas (próximamente)';

  @override
  String get notifProximityContext => 'Lugar cerca de ti';

  @override
  String get notifDraftContext => 'Completa tu guardado';

  @override
  String get notifEventContext => 'Evento de interés';

  @override
  String get notifSummaryContext => 'Resumen del mes';

  @override
  String get notifPlaceFallback => 'Lugar guardado';

  @override
  String get notifTestSectionTitle => 'Pruebas · notificaciones';

  @override
  String get notifTestSectionHint => 'Solo etapa de pruebas; se quitará luego.';

  @override
  String get notifTestChipProximity => 'Cerca';

  @override
  String get notifTestChipDraft => 'Borrador';

  @override
  String get notifTestChipEvent => 'Evento';

  @override
  String get notifTestChipSummary => 'Resumen';

  @override
  String get notifTestSent => 'Notificación enviada.';

  @override
  String reviewEditedOn(String date) {
    return ' · editado $date';
  }

  @override
  String get saveSuccessTitleCreate => '¡Lugar guardado!';

  @override
  String get saveSuccessTitleUpdate => '¡Actualizado!';

  @override
  String get saveSuccessStaffBody => 'Cambios del sitio guardados.';

  @override
  String get saveSuccessCompleteBody => 'Quedó completo en tu lista.';

  @override
  String get saveSuccessPrivateSuffix => ' Privado por defecto.';

  @override
  String get saveLinkFallback => 'Enlace';

  @override
  String get adminTransportInactive => 'Inactivo';

  @override
  String get adminTransportNoKmCap => 'Sin tope km';

  @override
  String adminTransportMaxKmShort(int km) {
    return 'Máx $km km';
  }

  @override
  String get adminTransportGroupOther => 'Otro (plataformas)';

  @override
  String get betaUpdateTitle => 'Actualización disponible';

  @override
  String betaUpdateBody(String version) {
    return 'Hay una versión más reciente ($version). Instálala para seguir usando la app.';
  }

  @override
  String betaUpdateCurrentVersion(String version) {
    return 'Tu versión: $version';
  }

  @override
  String get betaUpdateDownload => 'Descargar e instalar';

  @override
  String get betaUpdateRetry => 'Revisar de nuevo';
}
