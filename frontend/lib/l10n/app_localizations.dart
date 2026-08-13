import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('es')];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'Chevere Plan'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In es, this message translates to:
  /// **'Guarda lugares y arma planes\nen Colombia.'**
  String get appTagline;

  /// No description provided for @navHome.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get navHome;

  /// No description provided for @navExplore.
  ///
  /// In es, this message translates to:
  /// **'Explorar'**
  String get navExplore;

  /// No description provided for @navPlans.
  ///
  /// In es, this message translates to:
  /// **'Planes'**
  String get navPlans;

  /// No description provided for @navRoutes.
  ///
  /// In es, this message translates to:
  /// **'Rutas'**
  String get navRoutes;

  /// No description provided for @actionCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get actionCancel;

  /// No description provided for @actionDiscard.
  ///
  /// In es, this message translates to:
  /// **'Descartar'**
  String get actionDiscard;

  /// No description provided for @actionSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get actionSave;

  /// No description provided for @actionRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get actionRetry;

  /// No description provided for @actionComplete.
  ///
  /// In es, this message translates to:
  /// **'Completar'**
  String get actionComplete;

  /// No description provided for @actionAdjust.
  ///
  /// In es, this message translates to:
  /// **'Ajustar'**
  String get actionAdjust;

  /// No description provided for @actionSearch.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get actionSearch;

  /// No description provided for @greetingMorning.
  ///
  /// In es, this message translates to:
  /// **'Buenos días'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In es, this message translates to:
  /// **'Buenas tardes'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In es, this message translates to:
  /// **'Buenas noches'**
  String get greetingEvening;

  /// No description provided for @loginAcceptLegal.
  ///
  /// In es, this message translates to:
  /// **'Acepto los documentos legales del MVP.'**
  String get loginAcceptLegal;

  /// No description provided for @loginTerms.
  ///
  /// In es, this message translates to:
  /// **'Términos de Uso'**
  String get loginTerms;

  /// No description provided for @loginPrivacy.
  ///
  /// In es, this message translates to:
  /// **'Aviso de privacidad'**
  String get loginPrivacy;

  /// No description provided for @loginContinueGoogle.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get loginContinueGoogle;

  /// No description provided for @loginConnecting.
  ///
  /// In es, this message translates to:
  /// **'Conectando…'**
  String get loginConnecting;

  /// No description provided for @loginMustAcceptLegal.
  ///
  /// In es, this message translates to:
  /// **'Debes aceptar los Términos de Uso y el Aviso de privacidad para continuar.'**
  String get loginMustAcceptLegal;

  /// No description provided for @statusDraft.
  ///
  /// In es, this message translates to:
  /// **'Borrador'**
  String get statusDraft;

  /// No description provided for @statusPendingLocation.
  ///
  /// In es, this message translates to:
  /// **'Pendiente de ubicación'**
  String get statusPendingLocation;

  /// No description provided for @statusComplete.
  ///
  /// In es, this message translates to:
  /// **'Completo'**
  String get statusComplete;

  /// No description provided for @visibilityPublic.
  ///
  /// In es, this message translates to:
  /// **'Público'**
  String get visibilityPublic;

  /// No description provided for @visibilityPrivate.
  ///
  /// In es, this message translates to:
  /// **'Privado'**
  String get visibilityPrivate;

  /// No description provided for @labelOwn.
  ///
  /// In es, this message translates to:
  /// **'Tuyo'**
  String get labelOwn;

  /// No description provided for @homePendingBadge.
  ///
  /// In es, this message translates to:
  /// **'PENDIENTE'**
  String get homePendingBadge;

  /// No description provided for @homeDraftsToComplete.
  ///
  /// In es, this message translates to:
  /// **'{count} guardado(s) por completar'**
  String homeDraftsToComplete(int count);

  /// No description provided for @homeProximityRadius.
  ///
  /// In es, this message translates to:
  /// **'Radio {meters} m'**
  String homeProximityRadius(int meters);

  /// No description provided for @homeProximityPublicSuffix.
  ///
  /// In es, this message translates to:
  /// **' · públicos'**
  String get homeProximityPublicSuffix;

  /// No description provided for @homeOpenReports.
  ///
  /// In es, this message translates to:
  /// **'Reportes abiertos'**
  String get homeOpenReports;

  /// No description provided for @homeMySaves.
  ///
  /// In es, this message translates to:
  /// **'Mis guardados'**
  String get homeMySaves;

  /// No description provided for @homeEmptySaves.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes lugares. Usa el botón + o comparte un link desde IG/TikTok/FB.'**
  String get homeEmptySaves;

  /// No description provided for @homeAdminBadge.
  ///
  /// In es, this message translates to:
  /// **'A'**
  String get homeAdminBadge;

  /// No description provided for @homeDiscardTitle.
  ///
  /// In es, this message translates to:
  /// **'Descartar guardado'**
  String get homeDiscardTitle;

  /// No description provided for @homeDiscardConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar \"{name}\" de tu lista?'**
  String homeDiscardConfirm(String name);

  /// No description provided for @homeStaleDraftsSnack.
  ///
  /// In es, this message translates to:
  /// **'Tienes {count} borrador(es) por completar.'**
  String homeStaleDraftsSnack(int count);

  /// No description provided for @plansTitle.
  ///
  /// In es, this message translates to:
  /// **'Planes'**
  String get plansTitle;

  /// No description provided for @plansEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes planes. Crea uno y agrega sitios cuando quieras.'**
  String get plansEmpty;

  /// No description provided for @plansCreateFab.
  ///
  /// In es, this message translates to:
  /// **'Armar plan'**
  String get plansCreateFab;

  /// No description provided for @routesTitle.
  ///
  /// In es, this message translates to:
  /// **'Rutas'**
  String get routesTitle;

  /// No description provided for @routesEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay lugares visitados. En un plan, marca paradas como visitadas para verlas aquí.'**
  String get routesEmpty;

  /// No description provided for @reportsTitle.
  ///
  /// In es, this message translates to:
  /// **'Reportes de contenido'**
  String get reportsTitle;

  /// No description provided for @reportsEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay reportes abiertos.'**
  String get reportsEmpty;

  /// No description provided for @reportsPhotoFallback.
  ///
  /// In es, this message translates to:
  /// **'Foto reportada'**
  String get reportsPhotoFallback;

  /// No description provided for @reportsBy.
  ///
  /// In es, this message translates to:
  /// **'Por {name}'**
  String reportsBy(String name);

  /// No description provided for @reportsMarkReviewed.
  ///
  /// In es, this message translates to:
  /// **'Marcar revisado'**
  String get reportsMarkReviewed;

  /// No description provided for @reportsDismiss.
  ///
  /// In es, this message translates to:
  /// **'Descartar'**
  String get reportsDismiss;

  /// No description provided for @reportsActioned.
  ///
  /// In es, this message translates to:
  /// **'Acción tomada'**
  String get reportsActioned;

  /// No description provided for @searchTitle.
  ///
  /// In es, this message translates to:
  /// **'Explorar'**
  String get searchTitle;

  /// No description provided for @searchNoResults.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados.'**
  String get searchNoResults;

  /// No description provided for @searchQueryRequired.
  ///
  /// In es, this message translates to:
  /// **'Escribe algo para buscar.'**
  String get searchQueryRequired;

  /// No description provided for @searchSearching.
  ///
  /// In es, this message translates to:
  /// **'Buscando…'**
  String get searchSearching;

  /// No description provided for @actionEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get actionEdit;

  /// No description provided for @siteDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Sitio'**
  String get siteDetailTitle;

  /// No description provided for @siteDetailTabInfo.
  ///
  /// In es, this message translates to:
  /// **'Info'**
  String get siteDetailTabInfo;

  /// No description provided for @siteDetailTabReviews.
  ///
  /// In es, this message translates to:
  /// **'Reseñas'**
  String get siteDetailTabReviews;

  /// No description provided for @siteDetailTabMore.
  ///
  /// In es, this message translates to:
  /// **'Más info'**
  String get siteDetailTabMore;

  /// No description provided for @siteDetailLocation.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get siteDetailLocation;

  /// No description provided for @siteDetailOpenInMaps.
  ///
  /// In es, this message translates to:
  /// **'Ver en Maps'**
  String get siteDetailOpenInMaps;

  /// No description provided for @siteDetailDirections.
  ///
  /// In es, this message translates to:
  /// **'Cómo llegar'**
  String get siteDetailDirections;

  /// No description provided for @siteDetailNoCoords.
  ///
  /// In es, this message translates to:
  /// **'Este sitio aún no tiene punto en el mapa.'**
  String get siteDetailNoCoords;

  /// No description provided for @saveNeedsMapPoint.
  ///
  /// In es, this message translates to:
  /// **'Guardado. Falta el punto en el mapa para marcarlo completo.'**
  String get saveNeedsMapPoint;

  /// No description provided for @siteDetailCategories.
  ///
  /// In es, this message translates to:
  /// **'Categorías'**
  String get siteDetailCategories;

  /// No description provided for @siteDetailPrice.
  ///
  /// In es, this message translates to:
  /// **'Precio estimado'**
  String get siteDetailPrice;

  /// No description provided for @siteDetailDistance.
  ///
  /// In es, this message translates to:
  /// **'Distancia'**
  String get siteDetailDistance;

  /// No description provided for @siteDetailNotes.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get siteDetailNotes;

  /// No description provided for @siteDetailAlsoShared.
  ///
  /// In es, this message translates to:
  /// **'También guardado por'**
  String get siteDetailAlsoShared;

  /// No description provided for @siteDetailCreatedBy.
  ///
  /// In es, this message translates to:
  /// **'Creado por'**
  String get siteDetailCreatedBy;

  /// No description provided for @siteDetailCreatedAt.
  ///
  /// In es, this message translates to:
  /// **'Fecha de creación'**
  String get siteDetailCreatedAt;

  /// No description provided for @siteDetailUpdatedAt.
  ///
  /// In es, this message translates to:
  /// **'Última actualización'**
  String get siteDetailUpdatedAt;

  /// No description provided for @siteDetailJoinedAt.
  ///
  /// In es, this message translates to:
  /// **'Se sumó el {date}'**
  String siteDetailJoinedAt(String date);

  /// No description provided for @siteDetailCatalogBadge.
  ///
  /// In es, this message translates to:
  /// **'Sitio del catálogo público'**
  String get siteDetailCatalogBadge;

  /// No description provided for @siteDetailYourSaveAt.
  ///
  /// In es, this message translates to:
  /// **'Lo guardaste el {date}'**
  String siteDetailYourSaveAt(String date);

  /// No description provided for @siteDetailTraceEmpty.
  ///
  /// In es, this message translates to:
  /// **'Sin más datos de trazabilidad por ahora.'**
  String get siteDetailTraceEmpty;

  /// No description provided for @siteDetailPhotos.
  ///
  /// In es, this message translates to:
  /// **'Fotos'**
  String get siteDetailPhotos;

  /// No description provided for @siteDetailSource.
  ///
  /// In es, this message translates to:
  /// **'Origen'**
  String get siteDetailSource;

  /// No description provided for @siteDetailNotPhysical.
  ///
  /// In es, this message translates to:
  /// **'No es lugar físico'**
  String get siteDetailNotPhysical;

  /// No description provided for @siteDetailReviewsSoonTitle.
  ///
  /// In es, this message translates to:
  /// **'Reseñas próximamente'**
  String get siteDetailReviewsSoonTitle;

  /// No description provided for @siteDetailReviewsSoonBody.
  ///
  /// In es, this message translates to:
  /// **'Las calificaciones y comentarios de la comunidad llegarán en una fase posterior (especificación §8 / Fase 3).'**
  String get siteDetailReviewsSoonBody;

  /// No description provided for @siteDetailMoreSoonTitle.
  ///
  /// In es, this message translates to:
  /// **'Más opciones próximamente'**
  String get siteDetailMoreSoonTitle;

  /// No description provided for @siteDetailMoreSoonBody.
  ///
  /// In es, this message translates to:
  /// **'Aquí irán horario, ficha de negocio, reportes de precio y otras acciones del sitio.'**
  String get siteDetailMoreSoonBody;

  /// No description provided for @proximityTitle.
  ///
  /// In es, this message translates to:
  /// **'Recuerdos cercanos'**
  String get proximityTitle;

  /// No description provided for @proximitySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Te avisamos al acercarte a un lugar guardado.'**
  String get proximitySubtitle;

  /// No description provided for @proximityIncludePublic.
  ///
  /// In es, this message translates to:
  /// **'Incluir sitios públicos'**
  String get proximityIncludePublic;

  /// No description provided for @proximityIncludePublicSubtitle.
  ///
  /// In es, this message translates to:
  /// **'También recordarme lugares públicos de otros usuarios'**
  String get proximityIncludePublicSubtitle;

  /// No description provided for @proximityRadiusLabel.
  ///
  /// In es, this message translates to:
  /// **'Radio: {meters} m'**
  String proximityRadiusLabel(int meters);

  /// No description provided for @proximityNeedsLocation.
  ///
  /// In es, this message translates to:
  /// **'Activa la ubicación (siempre) para recibir recuerdos cercanos.'**
  String get proximityNeedsLocation;

  /// No description provided for @savePlaceTitle.
  ///
  /// In es, this message translates to:
  /// **'Guardar lugar'**
  String get savePlaceTitle;

  /// No description provided for @savePlaceEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Completar / editar lugar'**
  String get savePlaceEditTitle;

  /// No description provided for @savePlaceSubmit.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get savePlaceSubmit;

  /// No description provided for @savePlaceSubmitEdit.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get savePlaceSubmitEdit;

  /// No description provided for @saveStatusAfterSave.
  ///
  /// In es, this message translates to:
  /// **'Estado: {status}. Puedes completarlo después.'**
  String saveStatusAfterSave(String status);

  /// No description provided for @adminTitle.
  ///
  /// In es, this message translates to:
  /// **'Panel administrador'**
  String get adminTitle;

  /// No description provided for @adminTabCategories.
  ///
  /// In es, this message translates to:
  /// **'Categorías'**
  String get adminTabCategories;

  /// No description provided for @adminTabVehicles.
  ///
  /// In es, this message translates to:
  /// **'Vehículos'**
  String get adminTabVehicles;

  /// No description provided for @actionLoadMore.
  ///
  /// In es, this message translates to:
  /// **'Cargar más'**
  String get actionLoadMore;

  /// No description provided for @actionClear.
  ///
  /// In es, this message translates to:
  /// **'Limpiar'**
  String get actionClear;

  /// No description provided for @actionDone.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get actionDone;

  /// No description provided for @actionAcceptContinue.
  ///
  /// In es, this message translates to:
  /// **'Acepto y continuar'**
  String get actionAcceptContinue;

  /// No description provided for @actionUse.
  ///
  /// In es, this message translates to:
  /// **'Usar'**
  String get actionUse;

  /// No description provided for @actionDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get actionDelete;

  /// No description provided for @actionPaste.
  ///
  /// In es, this message translates to:
  /// **'Pegar'**
  String get actionPaste;

  /// No description provided for @actionReport.
  ///
  /// In es, this message translates to:
  /// **'Reportar'**
  String get actionReport;

  /// No description provided for @clipboardEmpty.
  ///
  /// In es, this message translates to:
  /// **'El portapapeles está vacío.'**
  String get clipboardEmpty;

  /// No description provided for @searchSimple.
  ///
  /// In es, this message translates to:
  /// **'Simple'**
  String get searchSimple;

  /// No description provided for @searchAdvanced.
  ///
  /// In es, this message translates to:
  /// **'Avanzada'**
  String get searchAdvanced;

  /// No description provided for @searchModeGeneral.
  ///
  /// In es, this message translates to:
  /// **'Búsqueda general'**
  String get searchModeGeneral;

  /// No description provided for @searchModeAdvanced.
  ///
  /// In es, this message translates to:
  /// **'Búsqueda avanzada'**
  String get searchModeAdvanced;

  /// No description provided for @searchHintPlace.
  ///
  /// In es, this message translates to:
  /// **'Ej. Tunja'**
  String get searchHintPlace;

  /// No description provided for @searchLabelText.
  ///
  /// In es, this message translates to:
  /// **'Texto (nombre o ciudad)'**
  String get searchLabelText;

  /// No description provided for @searchLabelLocationExtra.
  ///
  /// In es, this message translates to:
  /// **'Ciudad o departamento (extra)'**
  String get searchLabelLocationExtra;

  /// No description provided for @searchLabelCategory.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get searchLabelCategory;

  /// No description provided for @searchAny.
  ///
  /// In es, this message translates to:
  /// **'Cualquiera'**
  String get searchAny;

  /// No description provided for @searchLabelTransport.
  ///
  /// In es, this message translates to:
  /// **'Transporte'**
  String get searchLabelTransport;

  /// No description provided for @searchTransportPrivate.
  ///
  /// In es, this message translates to:
  /// **'Particular'**
  String get searchTransportPrivate;

  /// No description provided for @searchTransportPublic.
  ///
  /// In es, this message translates to:
  /// **'Público'**
  String get searchTransportPublic;

  /// No description provided for @searchTransportOther.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get searchTransportOther;

  /// No description provided for @searchBudgetMin.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto min'**
  String get searchBudgetMin;

  /// No description provided for @searchBudgetMax.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto max'**
  String get searchBudgetMax;

  /// No description provided for @searchUseMyLocation.
  ///
  /// In es, this message translates to:
  /// **'Usar mi ubicación + radio'**
  String get searchUseMyLocation;

  /// No description provided for @searchRadiusKm.
  ///
  /// In es, this message translates to:
  /// **'Radio (km)'**
  String get searchRadiusKm;

  /// No description provided for @searchHoursPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Horario: cuando los sitios tengan horario oficial.'**
  String get searchHoursPlaceholder;

  /// No description provided for @searchIncludePublic.
  ///
  /// In es, this message translates to:
  /// **'Incluir sitios públicos'**
  String get searchIncludePublic;

  /// No description provided for @searchLoadMoreRemaining.
  ///
  /// In es, this message translates to:
  /// **'Cargar más ({count} restantes)'**
  String searchLoadMoreRemaining(int count);

  /// No description provided for @searchEmptyHint.
  ///
  /// In es, this message translates to:
  /// **'Escribe y pulsa la lupa o Enter.'**
  String get searchEmptyHint;

  /// No description provided for @saveLocationSection.
  ///
  /// In es, this message translates to:
  /// **'1. Ubicación (opcional)'**
  String get saveLocationSection;

  /// No description provided for @saveLocationDraftHint.
  ///
  /// In es, this message translates to:
  /// **'Si no la tienes aún, guarda igual: queda en borrador.'**
  String get saveLocationDraftHint;

  /// No description provided for @saveLocationMap.
  ///
  /// In es, this message translates to:
  /// **'Mapa'**
  String get saveLocationMap;

  /// No description provided for @saveLocationGoogleLink.
  ///
  /// In es, this message translates to:
  /// **'Enlace Google'**
  String get saveLocationGoogleLink;

  /// No description provided for @saveLocationPointReady.
  ///
  /// In es, this message translates to:
  /// **'Punto listo'**
  String get saveLocationPointReady;

  /// No description provided for @saveLocationPickMap.
  ///
  /// In es, this message translates to:
  /// **'Elegir en el mapa'**
  String get saveLocationPickMap;

  /// No description provided for @saveLocationTapHint.
  ///
  /// In es, this message translates to:
  /// **'Toca el mapa o busca el lugar'**
  String get saveLocationTapHint;

  /// No description provided for @saveLocationClear.
  ///
  /// In es, this message translates to:
  /// **'Quitar ubicación'**
  String get saveLocationClear;

  /// No description provided for @saveMapsPasteLabel.
  ///
  /// In es, this message translates to:
  /// **'Pegar enlace de Google Maps'**
  String get saveMapsPasteLabel;

  /// No description provided for @saveMapsPasteHelper.
  ///
  /// In es, this message translates to:
  /// **'maps.app.goo.gl o google.com/maps'**
  String get saveMapsPasteHelper;

  /// No description provided for @saveMapsNeedExactPin.
  ///
  /// In es, this message translates to:
  /// **'No se obtuvo el punto exacto. Ábrelo en el mapa interactivo y confirma el pin.'**
  String get saveMapsNeedExactPin;

  /// No description provided for @saveMapsNeedGoogleKey.
  ///
  /// In es, this message translates to:
  /// **'Falta GOOGLE_MAPS_API_KEY en el build. Corre con: flutter run --dart-define-from-file=.env'**
  String get saveMapsNeedGoogleKey;

  /// No description provided for @planSearchCompleteOnlyHint.
  ///
  /// In es, this message translates to:
  /// **'Solo aparecen sitios completos con ubicación en el mapa.'**
  String get planSearchCompleteOnlyHint;

  /// No description provided for @planSearchEmptyQueryHint.
  ///
  /// In es, this message translates to:
  /// **'Deja el buscador vacío y toca buscar para ver todos tus sitios elegibles.'**
  String get planSearchEmptyQueryHint;

  /// No description provided for @planSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Nombre, ciudad… o vacío = todos'**
  String get planSearchHint;

  /// No description provided for @planOpeningMaps.
  ///
  /// In es, this message translates to:
  /// **'Preparando ruta en Maps…'**
  String get planOpeningMaps;

  /// No description provided for @saveMapsApproxPin.
  ///
  /// In es, this message translates to:
  /// **'Punto aproximado. Confirma o ajusta el pin en el mapa.'**
  String get saveMapsApproxPin;

  /// No description provided for @actionLoading.
  ///
  /// In es, this message translates to:
  /// **'Cargando…'**
  String get actionLoading;

  /// No description provided for @saveMapsNeedLink.
  ///
  /// In es, this message translates to:
  /// **'Pega un enlace de Google Maps.'**
  String get saveMapsNeedLink;

  /// No description provided for @saveMapsNeedCity.
  ///
  /// In es, this message translates to:
  /// **'Se leyó el enlace. Completa ciudad o elige en el mapa.'**
  String get saveMapsNeedCity;

  /// No description provided for @saveLocationAppliedNamed.
  ///
  /// In es, this message translates to:
  /// **'Ubicación aplicada: {name}, {city}.'**
  String saveLocationAppliedNamed(String name, String city);

  /// No description provided for @saveLocationApplied.
  ///
  /// In es, this message translates to:
  /// **'Ubicación aplicada.'**
  String get saveLocationApplied;

  /// No description provided for @saveNameDetails.
  ///
  /// In es, this message translates to:
  /// **'Nombre y detalles'**
  String get saveNameDetails;

  /// No description provided for @savePlaceName.
  ///
  /// In es, this message translates to:
  /// **'Nombre del lugar'**
  String get savePlaceName;

  /// No description provided for @savePlaceNameHelper.
  ///
  /// In es, this message translates to:
  /// **'Opcional. Se completa del mapa o queda “Sin nombre”'**
  String get savePlaceNameHelper;

  /// No description provided for @saveDepartment.
  ///
  /// In es, this message translates to:
  /// **'Departamento'**
  String get saveDepartment;

  /// No description provided for @saveCity.
  ///
  /// In es, this message translates to:
  /// **'Ciudad'**
  String get saveCity;

  /// No description provided for @saveAddress.
  ///
  /// In es, this message translates to:
  /// **'Dirección'**
  String get saveAddress;

  /// No description provided for @saveGeoCatalogMissing.
  ///
  /// In es, this message translates to:
  /// **'Catálogo no cargado. Ejecuta el reset DIVIPOLA.'**
  String get saveGeoCatalogMissing;

  /// No description provided for @savePickFromList.
  ///
  /// In es, this message translates to:
  /// **'Elige una opción de la lista'**
  String get savePickFromList;

  /// No description provided for @savePickDeptFirst.
  ///
  /// In es, this message translates to:
  /// **'Primero elige el departamento'**
  String get savePickDeptFirst;

  /// No description provided for @saveLinksSection.
  ///
  /// In es, this message translates to:
  /// **'2. Enlaces (opcional)'**
  String get saveLinksSection;

  /// No description provided for @saveSocialPaste.
  ///
  /// In es, this message translates to:
  /// **'Pegar enlace (IG, TikTok, FB…)'**
  String get saveSocialPaste;

  /// No description provided for @saveSocialInvalid.
  ///
  /// In es, this message translates to:
  /// **'Pega un enlace http(s) válido.'**
  String get saveSocialInvalid;

  /// No description provided for @saveSocialDuplicate.
  ///
  /// In es, this message translates to:
  /// **'Ese enlace ya está en la lista.'**
  String get saveSocialDuplicate;

  /// No description provided for @saveCategoriesSection.
  ///
  /// In es, this message translates to:
  /// **'3. Categorías'**
  String get saveCategoriesSection;

  /// No description provided for @saveCategoryHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. nadar, tejo, plaza, bar…'**
  String get saveCategoryHint;

  /// No description provided for @saveCategoryNone.
  ///
  /// In es, this message translates to:
  /// **'Sin coincidencias'**
  String get saveCategoryNone;

  /// No description provided for @saveCategorySuggestHint.
  ///
  /// In es, this message translates to:
  /// **'Se sugiere sola; o busca / abre el árbol.'**
  String get saveCategorySuggestHint;

  /// No description provided for @saveCategoryTree.
  ///
  /// In es, this message translates to:
  /// **'Árbol'**
  String get saveCategoryTree;

  /// No description provided for @saveCategorySuggested.
  ///
  /// In es, this message translates to:
  /// **'Sugerida según el nombre / Maps (puedes cambiarla)'**
  String get saveCategorySuggested;

  /// No description provided for @saveCategoryFallbackOtros.
  ///
  /// In es, this message translates to:
  /// **'Sin coincidencia clara → Otros (puedes cambiarla)'**
  String get saveCategoryFallbackOtros;

  /// No description provided for @saveVisibilitySection.
  ///
  /// In es, this message translates to:
  /// **'4. Visibilidad y foto'**
  String get saveVisibilitySection;

  /// No description provided for @saveIsPhysical.
  ///
  /// In es, this message translates to:
  /// **'Es un lugar físico'**
  String get saveIsPhysical;

  /// No description provided for @saveIsPhysicalSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Si no lo es (receta, tip…), quedará siempre privado'**
  String get saveIsPhysicalSubtitle;

  /// No description provided for @saveMakePublic.
  ///
  /// In es, this message translates to:
  /// **'Hacer público'**
  String get saveMakePublic;

  /// No description provided for @savePublicNeedLocation.
  ///
  /// In es, this message translates to:
  /// **'Primero indica ubicación para poder publicarlo'**
  String get savePublicNeedLocation;

  /// No description provided for @savePublicNonPhysical.
  ///
  /// In es, this message translates to:
  /// **'Los contenidos no físicos quedan privados'**
  String get savePublicNonPhysical;

  /// No description provided for @savePublicVisible.
  ///
  /// In es, this message translates to:
  /// **'Visible para otros en la capa pública'**
  String get savePublicVisible;

  /// No description provided for @saveAddPhoto.
  ///
  /// In es, this message translates to:
  /// **'Añadir foto (máx. 15)'**
  String get saveAddPhoto;

  /// No description provided for @savePhotoReady.
  ///
  /// In es, this message translates to:
  /// **'Foto lista para subir'**
  String get savePhotoReady;

  /// No description provided for @saveDraftFooter.
  ///
  /// In es, this message translates to:
  /// **'Puedes guardar ya: sin ubicación queda en borrador y te recordaremos completarlo.'**
  String get saveDraftFooter;

  /// No description provided for @sameSiteTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Es el mismo sitio?'**
  String get sameSiteTitle;

  /// No description provided for @sameSiteNew.
  ///
  /// In es, this message translates to:
  /// **'Es uno nuevo'**
  String get sameSiteNew;

  /// No description provided for @sameSiteYes.
  ///
  /// In es, this message translates to:
  /// **'Sí, es el mismo'**
  String get sameSiteYes;

  /// No description provided for @sameSiteStaffHint.
  ///
  /// In es, this message translates to:
  /// **'Hay un sitio público parecido. Edítalo desde su ficha o crea el tuyo como nuevo.'**
  String get sameSiteStaffHint;

  /// No description provided for @privacyBlockTitle.
  ///
  /// In es, this message translates to:
  /// **'No se puede hacer privado'**
  String get privacyBlockTitle;

  /// No description provided for @privacyBlockCatalog.
  ///
  /// In es, this message translates to:
  /// **'Este sitio es del catálogo público y debe seguir visible para todos.'**
  String get privacyBlockCatalog;

  /// No description provided for @privacyBlockOthers.
  ///
  /// In es, this message translates to:
  /// **'Otros usuarios ya lo guardaron, aportaron o lo usan en planes. Mientras eso exista, debe seguir público.'**
  String get privacyBlockOthers;

  /// No description provided for @locationPickerTitle.
  ///
  /// In es, this message translates to:
  /// **'Elegir ubicación'**
  String get locationPickerTitle;

  /// No description provided for @locationPickerSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar lugar, dirección, ciudad…'**
  String get locationPickerSearchHint;

  /// No description provided for @locationMyLocation.
  ///
  /// In es, this message translates to:
  /// **'Mi ubicación'**
  String get locationMyLocation;

  /// No description provided for @locationConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get locationConfirm;

  /// No description provided for @locationNoMatches.
  ///
  /// In es, this message translates to:
  /// **'Sin coincidencias. Prueba otro nombre o toca el mapa.'**
  String get locationNoMatches;

  /// No description provided for @locationNeedGps.
  ///
  /// In es, this message translates to:
  /// **'Activa la ubicación para centrar el mapa en ti.'**
  String get locationNeedGps;

  /// No description provided for @photoDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar foto'**
  String get photoDeleteTitle;

  /// No description provided for @photoDeleteConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Quieres eliminar esta foto del sitio?'**
  String get photoDeleteConfirm;

  /// No description provided for @photoReportTitle.
  ///
  /// In es, this message translates to:
  /// **'Reportar foto'**
  String get photoReportTitle;

  /// No description provided for @photoReportSend.
  ///
  /// In es, this message translates to:
  /// **'Enviar reporte'**
  String get photoReportSend;

  /// No description provided for @directionsMaps.
  ///
  /// In es, this message translates to:
  /// **'Cómo llegar (Google Maps)'**
  String get directionsMaps;

  /// No description provided for @planCreateTitle.
  ///
  /// In es, this message translates to:
  /// **'Armar plan'**
  String get planCreateTitle;

  /// No description provided for @planCreateStepTitleHint.
  ///
  /// In es, this message translates to:
  /// **'Ponle un nombre al plan. Luego eliges los sitios.'**
  String get planCreateStepTitleHint;

  /// No description provided for @actionNext.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get actionNext;

  /// No description provided for @planTitleOptional.
  ///
  /// In es, this message translates to:
  /// **'Título (opcional)'**
  String get planTitleOptional;

  /// No description provided for @planTabSearch.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get planTabSearch;

  /// No description provided for @planTabResults.
  ///
  /// In es, this message translates to:
  /// **'Resultados'**
  String get planTabResults;

  /// No description provided for @planTabAdded.
  ///
  /// In es, this message translates to:
  /// **'Agregados ({count})'**
  String planTabAdded(int count);

  /// No description provided for @planTimelineEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay sitios. Busca y agrégalos.'**
  String get planTimelineEmpty;

  /// No description provided for @planSearchFirst.
  ///
  /// In es, this message translates to:
  /// **'Busca arriba y verás los resultados aquí.'**
  String get planSearchFirst;

  /// No description provided for @planAddSite.
  ///
  /// In es, this message translates to:
  /// **'Agregar al plan'**
  String get planAddSite;

  /// No description provided for @planSiteAdded.
  ///
  /// In es, this message translates to:
  /// **'Sitio agregado al plan.'**
  String get planSiteAdded;

  /// No description provided for @planStatusDraft.
  ///
  /// In es, this message translates to:
  /// **'Borrador'**
  String get planStatusDraft;

  /// No description provided for @planStopsCount.
  ///
  /// In es, this message translates to:
  /// **'{count} sitios'**
  String planStopsCount(int count);

  /// No description provided for @planMenuAddSites.
  ///
  /// In es, this message translates to:
  /// **'Agregar sitios'**
  String get planMenuAddSites;

  /// No description provided for @planMenuShare.
  ///
  /// In es, this message translates to:
  /// **'Compartir'**
  String get planMenuShare;

  /// No description provided for @planMenuOpenMaps.
  ///
  /// In es, this message translates to:
  /// **'Llevar a Maps'**
  String get planMenuOpenMaps;

  /// No description provided for @planMenuMore.
  ///
  /// In es, this message translates to:
  /// **'Más opciones'**
  String get planMenuMore;

  /// No description provided for @planMarkDone.
  ///
  /// In es, this message translates to:
  /// **'Marcar como hecho'**
  String get planMarkDone;

  /// No description provided for @planMarkPending.
  ///
  /// In es, this message translates to:
  /// **'Marcar pendiente'**
  String get planMarkPending;

  /// No description provided for @planRemoveStop.
  ///
  /// In es, this message translates to:
  /// **'Quitar del plan'**
  String get planRemoveStop;

  /// No description provided for @planNoPendingStops.
  ///
  /// In es, this message translates to:
  /// **'No hay sitios pendientes para Maps.'**
  String get planNoPendingStops;

  /// No description provided for @planStopsMissingCoords.
  ///
  /// In es, this message translates to:
  /// **'Algún sitio pendiente no tiene ubicación.'**
  String get planStopsMissingCoords;

  /// No description provided for @planNeedLocation.
  ///
  /// In es, this message translates to:
  /// **'Activa la ubicación para usar tu posición como inicio.'**
  String get planNeedLocation;

  /// No description provided for @planShareCopied.
  ///
  /// In es, this message translates to:
  /// **'Plan copiado al portapapeles.'**
  String get planShareCopied;

  /// No description provided for @planDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar plan'**
  String get planDeleteTitle;

  /// No description provided for @planDeleteConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar este plan y sus paradas?'**
  String get planDeleteConfirm;

  /// No description provided for @adminActive.
  ///
  /// In es, this message translates to:
  /// **'Activa'**
  String get adminActive;

  /// No description provided for @adminAgeRestricted.
  ///
  /// In es, this message translates to:
  /// **'Restringida +18'**
  String get adminAgeRestricted;

  /// No description provided for @adminEditTransport.
  ///
  /// In es, this message translates to:
  /// **'Editar transporte'**
  String get adminEditTransport;

  /// No description provided for @adminKmInvalid.
  ///
  /// In es, this message translates to:
  /// **'Km inválido'**
  String get adminKmInvalid;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
