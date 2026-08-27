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
  /// **'Guarda, organiza y descubre los mejores planes de Colombia'**
  String get appTagline;

  /// No description provided for @navPressBackAgainToExit.
  ///
  /// In es, this message translates to:
  /// **'Pulsa atrás otra vez para salir.'**
  String get navPressBackAgainToExit;

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

  /// No description provided for @moreMenuOpenTooltip.
  ///
  /// In es, this message translates to:
  /// **'Más opciones'**
  String get moreMenuOpenTooltip;

  /// No description provided for @moreMenuManageAccount.
  ///
  /// In es, this message translates to:
  /// **'Ver perfil'**
  String get moreMenuManageAccount;

  /// No description provided for @moreMenuProximitySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Radio y sitios públicos'**
  String get moreMenuProximitySubtitle;

  /// No description provided for @moreMenuDuplicateRadiusSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Al guardar un sitio (siempre en metros)'**
  String get moreMenuDuplicateRadiusSubtitle;

  /// No description provided for @duplicateRadiusTitle.
  ///
  /// In es, this message translates to:
  /// **'Mismo sitio al guardar'**
  String get duplicateRadiusTitle;

  /// No description provided for @duplicateRadiusSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Si hay otro sitio dentro de este radio, te avisamos para no duplicarlo. Por defecto 100 m.'**
  String get duplicateRadiusSubtitle;

  /// No description provided for @duplicateRadiusMetersInfo.
  ///
  /// In es, this message translates to:
  /// **'Este radio va siempre en metros. La unidad de distancia del menú (km, millas…) aplica en recuerdos cercanos, Explorar y etiquetas; no aquí.'**
  String get duplicateRadiusMetersInfo;

  /// No description provided for @moreMenuDistanceUnit.
  ///
  /// In es, this message translates to:
  /// **'Unidad de distancia'**
  String get moreMenuDistanceUnit;

  /// No description provided for @moreMenuDistanceUnitSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Cómo se muestran km, millas…'**
  String get moreMenuDistanceUnitSubtitle;

  /// No description provided for @distanceUnitSheetTitle.
  ///
  /// In es, this message translates to:
  /// **'Unidad de distancia'**
  String get distanceUnitSheetTitle;

  /// No description provided for @distanceUnitSheetHint.
  ///
  /// In es, this message translates to:
  /// **'Se aplica en recuerdos cercanos, Explorar y etiquetas de distancia. El radio de sitios duplicados siempre usa metros.'**
  String get distanceUnitSheetHint;

  /// No description provided for @profileDuplicateRadiusLabel.
  ///
  /// In es, this message translates to:
  /// **'Radio: {meters} m'**
  String profileDuplicateRadiusLabel(int meters);

  /// No description provided for @moreMenuReports.
  ///
  /// In es, this message translates to:
  /// **'Reportes'**
  String get moreMenuReports;

  /// No description provided for @moreMenuSignOut.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get moreMenuSignOut;

  /// No description provided for @moreMenuAppVersion.
  ///
  /// In es, this message translates to:
  /// **'Versión {version}'**
  String moreMenuAppVersion(String version);

  /// No description provided for @moreMenuTheme.
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get moreMenuTheme;

  /// No description provided for @moreMenuThemeLight.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get moreMenuThemeLight;

  /// No description provided for @moreMenuThemeDark.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get moreMenuThemeDark;

  /// No description provided for @moreMenuThemeSystem.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get moreMenuThemeSystem;

  /// No description provided for @moreMenuProfileComingTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil'**
  String get moreMenuProfileComingTitle;

  /// No description provided for @moreMenuProfileComingBody.
  ///
  /// In es, this message translates to:
  /// **'Pronto vas a poder ver y editar tu cuenta desde aquí.'**
  String get moreMenuProfileComingBody;

  /// No description provided for @profileSettingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil'**
  String get profileSettingsTitle;

  /// No description provided for @profileUsernameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre de usuario'**
  String get profileUsernameLabel;

  /// No description provided for @profileUsernameHint.
  ///
  /// In es, this message translates to:
  /// **'usuario'**
  String get profileUsernameHint;

  /// No description provided for @profileUsernameHelp.
  ///
  /// In es, this message translates to:
  /// **'3–20 caracteres: letras, números, punto o guion bajo. Se muestra como @usuario en reseñas y fotos.'**
  String get profileUsernameHelp;

  /// No description provided for @profileUsernameAvailable.
  ///
  /// In es, this message translates to:
  /// **'Disponible'**
  String get profileUsernameAvailable;

  /// No description provided for @profileUsernameTaken.
  ///
  /// In es, this message translates to:
  /// **'Ya está en uso'**
  String get profileUsernameTaken;

  /// No description provided for @profileUsernameInvalid.
  ///
  /// In es, this message translates to:
  /// **'Solo letras minúsculas, números, punto o guion bajo'**
  String get profileUsernameInvalid;

  /// No description provided for @profileUsernameLength.
  ///
  /// In es, this message translates to:
  /// **'Entre 3 y 20 caracteres'**
  String get profileUsernameLength;

  /// No description provided for @profileUsernameReserved.
  ///
  /// In es, this message translates to:
  /// **'Ese nombre no está disponible'**
  String get profileUsernameReserved;

  /// No description provided for @profileUsernameChecking.
  ///
  /// In es, this message translates to:
  /// **'Comprobando…'**
  String get profileUsernameChecking;

  /// No description provided for @profileUsernameSuggestions.
  ///
  /// In es, this message translates to:
  /// **'Sugerencias'**
  String get profileUsernameSuggestions;

  /// No description provided for @profileUsernameRequired.
  ///
  /// In es, this message translates to:
  /// **'Elegí un nombre de usuario para continuar'**
  String get profileUsernameRequired;

  /// No description provided for @profileAvatarSection.
  ///
  /// In es, this message translates to:
  /// **'Foto de perfil'**
  String get profileAvatarSection;

  /// No description provided for @profileUseGoogleAvatar.
  ///
  /// In es, this message translates to:
  /// **'Usar foto de Google'**
  String get profileUseGoogleAvatar;

  /// No description provided for @profileUseGoogleAvatarHint.
  ///
  /// In es, this message translates to:
  /// **'Por defecto no se muestra. Podés activarla o subir otra.'**
  String get profileUseGoogleAvatarHint;

  /// No description provided for @profileAvatarSourceLabel.
  ///
  /// In es, this message translates to:
  /// **'Foto activa'**
  String get profileAvatarSourceLabel;

  /// No description provided for @profileAvatarSourceGoogle.
  ///
  /// In es, this message translates to:
  /// **'Google'**
  String get profileAvatarSourceGoogle;

  /// No description provided for @profileAvatarSourceCustom.
  ///
  /// In es, this message translates to:
  /// **'Personalizada'**
  String get profileAvatarSourceCustom;

  /// No description provided for @profileChangePhoto.
  ///
  /// In es, this message translates to:
  /// **'Cambiar foto'**
  String get profileChangePhoto;

  /// No description provided for @profileRemoveCustomPhoto.
  ///
  /// In es, this message translates to:
  /// **'Quitar foto propia'**
  String get profileRemoveCustomPhoto;

  /// No description provided for @profileNoPhoto.
  ///
  /// In es, this message translates to:
  /// **'Sin foto (iniciales)'**
  String get profileNoPhoto;

  /// No description provided for @profileSaved.
  ///
  /// In es, this message translates to:
  /// **'Perfil actualizado'**
  String get profileSaved;

  /// No description provided for @profileSaveUsernameFirst.
  ///
  /// In es, this message translates to:
  /// **'Guardá un nombre de usuario válido'**
  String get profileSaveUsernameFirst;

  /// No description provided for @profileUsernameLocked.
  ///
  /// In es, this message translates to:
  /// **'Podés cambiar el @usuario cada 3 meses. Próximo cambio: {date}.'**
  String profileUsernameLocked(String date);

  /// No description provided for @profileUsernameMustSet.
  ///
  /// In es, this message translates to:
  /// **'Elegí un @usuario para usar la app. Se muestra en reseñas y fotos; las relaciones internas usan tu id, no el nombre.'**
  String get profileUsernameMustSet;

  /// No description provided for @profileUsernameCooldownToast.
  ///
  /// In es, this message translates to:
  /// **'Todavía no podés cambiar el nombre de usuario.'**
  String get profileUsernameCooldownToast;

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
  /// **'Buenos días ☀️'**
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
  /// **'Acepto los'**
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

  /// No description provided for @labelLinked.
  ///
  /// In es, this message translates to:
  /// **'Vinculado'**
  String get labelLinked;

  /// No description provided for @labelCatalog.
  ///
  /// In es, this message translates to:
  /// **'Catálogo'**
  String get labelCatalog;

  /// No description provided for @labelPublic.
  ///
  /// In es, this message translates to:
  /// **'Público'**
  String get labelPublic;

  /// No description provided for @labelCard.
  ///
  /// In es, this message translates to:
  /// **'Tarjeta'**
  String get labelCard;

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

  /// No description provided for @homeNearbyMemoryLabel.
  ///
  /// In es, this message translates to:
  /// **'Recuerdo cercano'**
  String get homeNearbyMemoryLabel;

  /// No description provided for @homeNearbyMemoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Te avisamos cuando estés cerca'**
  String get homeNearbyMemoryTitle;

  /// No description provided for @homeDraftsHint.
  ///
  /// In es, this message translates to:
  /// **'Sin punto en el mapa no entra en Explorar, planes ni rutas'**
  String get homeDraftsHint;

  /// No description provided for @draftNeedsMapPointWarning.
  ///
  /// In es, this message translates to:
  /// **'Este sitio está en borrador: no se tendrá en cuenta en Explorar, planes, rutas ni recuerdos cercanos hasta que asignes un punto en el mapa.'**
  String get draftNeedsMapPointWarning;

  /// No description provided for @nonPhysicalCardWarning.
  ///
  /// In es, this message translates to:
  /// **'Esta tarjeta no es un lugar físico: no se tendrá en cuenta en Explorar, planes, rutas ni recuerdos cercanos.'**
  String get nonPhysicalCardWarning;

  /// No description provided for @homeCardsSection.
  ///
  /// In es, this message translates to:
  /// **'Tarjetas'**
  String get homeCardsSection;

  /// No description provided for @homeCardsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes tarjetas (contenido que no es un lugar).'**
  String get homeCardsEmpty;

  /// No description provided for @moreMenuCardsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Contenido que no es un lugar físico'**
  String get moreMenuCardsSubtitle;

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

  /// No description provided for @homeRecentSaves.
  ///
  /// In es, this message translates to:
  /// **'Guardados recientes'**
  String get homeRecentSaves;

  /// No description provided for @homeSeeAll.
  ///
  /// In es, this message translates to:
  /// **'Ver más'**
  String get homeSeeAll;

  /// No description provided for @homeFeedView.
  ///
  /// In es, this message translates to:
  /// **'Vista'**
  String get homeFeedView;

  /// No description provided for @homeEvents.
  ///
  /// In es, this message translates to:
  /// **'Eventos'**
  String get homeEvents;

  /// No description provided for @homeEventsComingSoon.
  ///
  /// In es, this message translates to:
  /// **'Próximamente.'**
  String get homeEventsComingSoon;

  /// No description provided for @homePopularNearby.
  ///
  /// In es, this message translates to:
  /// **'Populares cerca'**
  String get homePopularNearby;

  /// No description provided for @homeExploreLink.
  ///
  /// In es, this message translates to:
  /// **'Explorar'**
  String get homeExploreLink;

  /// No description provided for @homeQuickActions.
  ///
  /// In es, this message translates to:
  /// **'Acciones rápidas'**
  String get homeQuickActions;

  /// No description provided for @homeQuickActionsPin.
  ///
  /// In es, this message translates to:
  /// **'Fijar abajo'**
  String get homeQuickActionsPin;

  /// No description provided for @homeQuickActionsUnpin.
  ///
  /// In es, this message translates to:
  /// **'Desfijar'**
  String get homeQuickActionsUnpin;

  /// No description provided for @homeActionNearMe.
  ///
  /// In es, this message translates to:
  /// **'Cerca de mí'**
  String get homeActionNearMe;

  /// No description provided for @homeActionMySaves.
  ///
  /// In es, this message translates to:
  /// **'Mis guardados'**
  String get homeActionMySaves;

  /// No description provided for @homeActionMyFavorites.
  ///
  /// In es, this message translates to:
  /// **'Mis favoritos'**
  String get homeActionMyFavorites;

  /// No description provided for @homeActionMostSaved.
  ///
  /// In es, this message translates to:
  /// **'Más guardados'**
  String get homeActionMostSaved;

  /// No description provided for @homeActionByCategory.
  ///
  /// In es, this message translates to:
  /// **'Por categoría'**
  String get homeActionByCategory;

  /// No description provided for @homeNearbyEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay lugares públicos cerca por ahora.'**
  String get homeNearbyEmpty;

  /// No description provided for @homeNearbyNeedGps.
  ///
  /// In es, this message translates to:
  /// **'Activa la ubicación para ver lugares cerca.'**
  String get homeNearbyNeedGps;

  /// No description provided for @homeSavedToday.
  ///
  /// In es, this message translates to:
  /// **'hoy'**
  String get homeSavedToday;

  /// No description provided for @homeSavedYesterday.
  ///
  /// In es, this message translates to:
  /// **'ayer'**
  String get homeSavedYesterday;

  /// No description provided for @homeSavedDaysAgo.
  ///
  /// In es, this message translates to:
  /// **'hace {count} días'**
  String homeSavedDaysAgo(int count);

  /// No description provided for @homeSavedWeeksAgo.
  ///
  /// In es, this message translates to:
  /// **'hace {count} sem.'**
  String homeSavedWeeksAgo(int count);

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
  /// **'Mis rutas'**
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
  /// **'Guardado como borrador. Sin punto en el mapa no entra en Explorar, planes, rutas ni recuerdos cercanos.'**
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

  /// No description provided for @photoAddTooltip.
  ///
  /// In es, this message translates to:
  /// **'Añadir foto'**
  String get photoAddTooltip;

  /// No description provided for @siteDetailPhotosEmptyManage.
  ///
  /// In es, this message translates to:
  /// **'Sin fotos. Usa el icono de cámara para añadir.'**
  String get siteDetailPhotosEmptyManage;

  /// No description provided for @siteDetailPhotosEmpty.
  ///
  /// In es, this message translates to:
  /// **'Este sitio no tiene fotos.'**
  String get siteDetailPhotosEmpty;

  /// No description provided for @sitePhotoViewerClose.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get sitePhotoViewerClose;

  /// No description provided for @sitePhotoViewerIndex.
  ///
  /// In es, this message translates to:
  /// **'{current} de {total}'**
  String sitePhotoViewerIndex(int current, int total);

  /// No description provided for @sitePhotoMenuTooltip.
  ///
  /// In es, this message translates to:
  /// **'Opciones de la foto'**
  String get sitePhotoMenuTooltip;

  /// No description provided for @sitePhotoSetAsCover.
  ///
  /// In es, this message translates to:
  /// **'Usar como portada del sitio'**
  String get sitePhotoSetAsCover;

  /// No description provided for @sitePhotoAlreadyCover.
  ///
  /// In es, this message translates to:
  /// **'Esta es la portada'**
  String get sitePhotoAlreadyCover;

  /// No description provided for @sitePhotoUploadedBy.
  ///
  /// In es, this message translates to:
  /// **'Subida por {name}'**
  String sitePhotoUploadedBy(String name);

  /// No description provided for @sitePhotoUploadedAt.
  ///
  /// In es, this message translates to:
  /// **'{date}'**
  String sitePhotoUploadedAt(String date);

  /// No description provided for @sitePhotoUploaderUnknown.
  ///
  /// In es, this message translates to:
  /// **'alguien'**
  String get sitePhotoUploaderUnknown;

  /// No description provided for @photoCoverSet.
  ///
  /// In es, this message translates to:
  /// **'Portada del sitio actualizada.'**
  String get photoCoverSet;

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
  /// **'Radio: {value} {symbol}'**
  String proximityRadiusLabel(String value, String symbol);

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

  /// No description provided for @adminTabDistanceUnits.
  ///
  /// In es, this message translates to:
  /// **'Distancias'**
  String get adminTabDistanceUnits;

  /// No description provided for @adminStatDistanceUnits.
  ///
  /// In es, this message translates to:
  /// **'Unidades'**
  String get adminStatDistanceUnits;

  /// No description provided for @adminEditDistanceUnit.
  ///
  /// In es, this message translates to:
  /// **'Editar unidad de distancia'**
  String get adminEditDistanceUnit;

  /// No description provided for @adminNewDistanceUnit.
  ///
  /// In es, this message translates to:
  /// **'Nueva unidad'**
  String get adminNewDistanceUnit;

  /// No description provided for @adminDistanceSymbol.
  ///
  /// In es, this message translates to:
  /// **'Símbolo (m, km, mi…)'**
  String get adminDistanceSymbol;

  /// No description provided for @adminDistanceMetersPerUnit.
  ///
  /// In es, this message translates to:
  /// **'Metros por unidad'**
  String get adminDistanceMetersPerUnit;

  /// No description provided for @adminDistanceDefault.
  ///
  /// In es, this message translates to:
  /// **'Por defecto (usuarios nuevos)'**
  String get adminDistanceDefault;

  /// No description provided for @adminDistanceSlug.
  ///
  /// In es, this message translates to:
  /// **'Slug (único)'**
  String get adminDistanceSlug;

  /// No description provided for @adminDistanceInvalidMeters.
  ///
  /// In es, this message translates to:
  /// **'Metros por unidad inválido.'**
  String get adminDistanceInvalidMeters;

  /// No description provided for @adminDistanceInvalidSlug.
  ///
  /// In es, this message translates to:
  /// **'Slug inválido (solo letras, números y _).'**
  String get adminDistanceInvalidSlug;

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
  /// **'Busca lugares, ciudades...'**
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

  /// No description provided for @searchRadiusLabel.
  ///
  /// In es, this message translates to:
  /// **'Radio ({symbol})'**
  String searchRadiusLabel(String symbol);

  /// No description provided for @searchRadiusInvalid.
  ///
  /// In es, this message translates to:
  /// **'Radio inválido. Usá entre {min} y {max} {symbol}.'**
  String searchRadiusInvalid(String min, String max, String symbol);

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
  /// **'Escribí y tocá la lupa (o Enter). El texto no es obligatorio.'**
  String get searchEmptyHint;

  /// No description provided for @searchResultsCount.
  ///
  /// In es, this message translates to:
  /// **'{count} resultados'**
  String searchResultsCount(int count);

  /// No description provided for @searchMySavesOnly.
  ///
  /// In es, this message translates to:
  /// **'Mis guardados'**
  String get searchMySavesOnly;

  /// No description provided for @searchMyFavoritesOnly.
  ///
  /// In es, this message translates to:
  /// **'Mis favoritos'**
  String get searchMyFavoritesOnly;

  /// No description provided for @searchResetFilters.
  ///
  /// In es, this message translates to:
  /// **'Borrar filtros'**
  String get searchResetFilters;

  /// No description provided for @searchCategoryMulti.
  ///
  /// In es, this message translates to:
  /// **'Varias categorías'**
  String get searchCategoryMulti;

  /// No description provided for @searchChipAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get searchChipAll;

  /// No description provided for @searchViewGrid.
  ///
  /// In es, this message translates to:
  /// **'Grilla'**
  String get searchViewGrid;

  /// No description provided for @searchViewList.
  ///
  /// In es, this message translates to:
  /// **'Lista'**
  String get searchViewList;

  /// No description provided for @feedLayoutList.
  ///
  /// In es, this message translates to:
  /// **'Lista'**
  String get feedLayoutList;

  /// No description provided for @feedLayoutGrid2.
  ///
  /// In es, this message translates to:
  /// **'Cuadrícula 2'**
  String get feedLayoutGrid2;

  /// No description provided for @feedLayoutGrid3.
  ///
  /// In es, this message translates to:
  /// **'Cuadrícula 3'**
  String get feedLayoutGrid3;

  /// No description provided for @feedLayoutGrid4.
  ///
  /// In es, this message translates to:
  /// **'Cuadrícula 4'**
  String get feedLayoutGrid4;

  /// No description provided for @plansSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tus itinerarios guardados'**
  String get plansSubtitle;

  /// No description provided for @plansCreateCardTitle.
  ///
  /// In es, this message translates to:
  /// **'Crear un plan'**
  String get plansCreateCardTitle;

  /// No description provided for @plansCreateCardHint.
  ///
  /// In es, this message translates to:
  /// **'Título, zona, paradas y presupuesto'**
  String get plansCreateCardHint;

  /// No description provided for @plansSavedHeading.
  ///
  /// In es, this message translates to:
  /// **'Mis planes guardados'**
  String get plansSavedHeading;

  /// No description provided for @plansStatusUpcoming.
  ///
  /// In es, this message translates to:
  /// **'Próximo'**
  String get plansStatusUpcoming;

  /// No description provided for @routesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tu historial de aventuras'**
  String get routesSubtitle;

  /// No description provided for @routesStatVisited.
  ///
  /// In es, this message translates to:
  /// **'Visitados'**
  String get routesStatVisited;

  /// No description provided for @routesStatCities.
  ///
  /// In es, this message translates to:
  /// **'Ciudades'**
  String get routesStatCities;

  /// No description provided for @routesStatPlans.
  ///
  /// In es, this message translates to:
  /// **'Planes'**
  String get routesStatPlans;

  /// No description provided for @routesHistoryHeading.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get routesHistoryHeading;

  /// No description provided for @saveLocationSection.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
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
  /// **'Enlace'**
  String get saveLocationGoogleLink;

  /// No description provided for @saveLocationCamera.
  ///
  /// In es, this message translates to:
  /// **'Cámara'**
  String get saveLocationCamera;

  /// No description provided for @saveCameraHint.
  ///
  /// In es, this message translates to:
  /// **'Toma una foto del lugar. Al confirmarla en la cámara se guarda la imagen y, si aún no hay ubicación, se captura la tuya automáticamente.'**
  String get saveCameraHint;

  /// No description provided for @saveCameraTake.
  ///
  /// In es, this message translates to:
  /// **'Tomar foto'**
  String get saveCameraTake;

  /// No description provided for @saveCameraLocating.
  ///
  /// In es, this message translates to:
  /// **'Capturando ubicación…'**
  String get saveCameraLocating;

  /// No description provided for @saveCameraNeedLocation.
  ///
  /// In es, this message translates to:
  /// **'Activa la ubicación para registrar el sitio.'**
  String get saveCameraNeedLocation;

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

  /// No description provided for @saveExactPinTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Guardar el punto exacto?'**
  String get saveExactPinTitle;

  /// No description provided for @saveExactPinBody.
  ///
  /// In es, this message translates to:
  /// **'Por nombre, Maps suele mostrar la ficha del lugar (fotos y reseñas). Guarda el pin solo si necesitas el punto preciso: entrada, mirador, finca, etc.'**
  String get saveExactPinBody;

  /// No description provided for @saveExactPinNo.
  ///
  /// In es, this message translates to:
  /// **'No, solo el lugar'**
  String get saveExactPinNo;

  /// No description provided for @saveExactPinYes.
  ///
  /// In es, this message translates to:
  /// **'Sí, guardar pin'**
  String get saveExactPinYes;

  /// No description provided for @saveExactPinSwitch.
  ///
  /// In es, this message translates to:
  /// **'Punto exacto en el mapa'**
  String get saveExactPinSwitch;

  /// No description provided for @saveExactPinMapsPin.
  ///
  /// In es, this message translates to:
  /// **'Maps abrirá el pin (lat, lng), no el buscador.'**
  String get saveExactPinMapsPin;

  /// No description provided for @saveExactPinMapsPlace.
  ///
  /// In es, this message translates to:
  /// **'Maps abrirá la ficha del lugar por nombre.'**
  String get saveExactPinMapsPlace;

  /// No description provided for @saveExactPinSwitchHint.
  ///
  /// In es, this message translates to:
  /// **'Apagado (recomendado): Maps abre la ficha del lugar por nombre. Encendido: abre el pin (lat, lng).'**
  String get saveExactPinSwitchHint;

  /// No description provided for @saveMapsPasteLabel.
  ///
  /// In es, this message translates to:
  /// **'Pegar enlace de Google Maps'**
  String get saveMapsPasteLabel;

  /// No description provided for @saveLocationSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar o pegar enlace de Google Maps'**
  String get saveLocationSearchHint;

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
  /// **'El mapa o el enlace suelen completarlo.'**
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
  /// **'Enlaces'**
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
  /// **'Categorías'**
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
  /// **'Visibilidad'**
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

  /// No description provided for @savePhysicalLabel.
  ///
  /// In es, this message translates to:
  /// **'Lugar físico'**
  String get savePhysicalLabel;

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

  /// No description provided for @savePhotoUploadPartialFail.
  ///
  /// In es, this message translates to:
  /// **'El sitio se guardó, pero una o más fotos no se subieron. Podés añadirlas después desde la ficha.'**
  String get savePhotoUploadPartialFail;

  /// No description provided for @savePhotoMaxReached.
  ///
  /// In es, this message translates to:
  /// **'Máximo {max} fotos por sitio.'**
  String savePhotoMaxReached(int max);

  /// No description provided for @saveDraftFooter.
  ///
  /// In es, this message translates to:
  /// **'Puedes guardar ya: sin ubicación queda en borrador y te recordaremos completarlo.'**
  String get saveDraftFooter;

  /// No description provided for @saveNameSection.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get saveNameSection;

  /// No description provided for @saveExtraNameVisibility.
  ///
  /// In es, this message translates to:
  /// **'Nombre - Visibilidad'**
  String get saveExtraNameVisibility;

  /// No description provided for @savePublicSection.
  ///
  /// In es, this message translates to:
  /// **'Público'**
  String get savePublicSection;

  /// No description provided for @saveNameRequired.
  ///
  /// In es, this message translates to:
  /// **'Escribe un nombre para guardar.'**
  String get saveNameRequired;

  /// No description provided for @saveAddSection.
  ///
  /// In es, this message translates to:
  /// **'Añadir sección'**
  String get saveAddSection;

  /// No description provided for @saveExtraDetails.
  ///
  /// In es, this message translates to:
  /// **'Detalles'**
  String get saveExtraDetails;

  /// No description provided for @saveExtraPhoto.
  ///
  /// In es, this message translates to:
  /// **'Fotos'**
  String get saveExtraPhoto;

  /// No description provided for @saveInfoLocation.
  ///
  /// In es, this message translates to:
  /// **'Mapa o enlace de Google. El pin habilita Público. Sin ubicación el guardado queda en borrador.'**
  String get saveInfoLocation;

  /// No description provided for @saveInfoExactPin.
  ///
  /// In es, this message translates to:
  /// **'Se guardan las dos: el lugar (nombre / Place ID) y el pin. El interruptor solo elige cuál abre Maps. Apagado = ficha del lugar. Encendido = coordenadas.'**
  String get saveInfoExactPin;

  /// No description provided for @saveInfoName.
  ///
  /// In es, this message translates to:
  /// **'Obligatorio. El mapa o el enlace de Google suelen completarlo.'**
  String get saveInfoName;

  /// No description provided for @saveInfoPublic.
  ///
  /// In es, this message translates to:
  /// **'Privado por defecto. Para publicar hace falta lugar físico y pin en el mapa. Sin pin el interruptor queda desactivado.'**
  String get saveInfoPublic;

  /// No description provided for @saveInfoDetails.
  ///
  /// In es, this message translates to:
  /// **'Departamento y ciudad de la lista oficial; dirección opcional. El mapa suele rellenarlos.'**
  String get saveInfoDetails;

  /// No description provided for @saveInfoLinks.
  ///
  /// In es, this message translates to:
  /// **'Instagram, TikTok u otra red del lugar. Pegá el enlace en el campo.'**
  String get saveInfoLinks;

  /// No description provided for @saveInfoCategories.
  ///
  /// In es, this message translates to:
  /// **'Se sugiere según el nombre. Al crear, si no hay coincidencia queda Otros.'**
  String get saveInfoCategories;

  /// No description provided for @saveInfoPhoto.
  ///
  /// In es, this message translates to:
  /// **'Hasta 15 fotos. Se suben al guardar.'**
  String get saveInfoPhoto;

  /// No description provided for @saveInfoPhysical.
  ///
  /// In es, this message translates to:
  /// **'Por defecto es un lugar físico. Si es receta, tip u otro contenido, apagá esto: quedará siempre privado.'**
  String get saveInfoPhysical;

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
  /// **'Usarlo y reseñar'**
  String get sameSiteYes;

  /// No description provided for @sameSiteReviewPublic.
  ///
  /// In es, this message translates to:
  /// **'Usarlo + reseña pública'**
  String get sameSiteReviewPublic;

  /// No description provided for @sameSiteReviewPublicHint.
  ///
  /// In es, this message translates to:
  /// **'Escribes una reseña visible en la ficha del sitio. Cuenta en el promedio público.'**
  String get sameSiteReviewPublicHint;

  /// No description provided for @sameSiteJournalPrivate.
  ///
  /// In es, this message translates to:
  /// **'Usarlo + reseña privada'**
  String get sameSiteJournalPrivate;

  /// No description provided for @sameSiteJournalPrivateHint.
  ///
  /// In es, this message translates to:
  /// **'Escribes una reseña solo para ti en ese sitio. No aparece en la ficha pública.'**
  String get sameSiteJournalPrivateHint;

  /// No description provided for @sameSiteReviewPrivateHint.
  ///
  /// In es, this message translates to:
  /// **'Escribes una reseña solo para ti en ese sitio. No aparece en la ficha pública.'**
  String get sameSiteReviewPrivateHint;

  /// No description provided for @sameSiteKeepEditing.
  ///
  /// In es, this message translates to:
  /// **'Seguir con el mío'**
  String get sameSiteKeepEditing;

  /// No description provided for @sameSiteKeepEditingHint.
  ///
  /// In es, this message translates to:
  /// **'Cierra este aviso y seguí editando tu guardado como sitio nuevo.'**
  String get sameSiteKeepEditingHint;

  /// No description provided for @sameSiteSaveAnyway.
  ///
  /// In es, this message translates to:
  /// **'Guardar de todas formas'**
  String get sameSiteSaveAnyway;

  /// No description provided for @sameSiteSaveAnywayHint.
  ///
  /// In es, this message translates to:
  /// **'Creas un sitio público nuevo aunque haya uno parecido en Explorar.'**
  String get sameSiteSaveAnywayHint;

  /// No description provided for @sameSiteFavorite.
  ///
  /// In es, this message translates to:
  /// **'Agregar a mis favoritos'**
  String get sameSiteFavorite;

  /// No description provided for @sameSiteFavoriteHint.
  ///
  /// In es, this message translates to:
  /// **'No crea un guardado nuevo. Marca el sitio con corazón y abre su ficha.'**
  String get sameSiteFavoriteHint;

  /// No description provided for @sameSiteFavoriteTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Agregar a favoritos?'**
  String get sameSiteFavoriteTitle;

  /// No description provided for @sameSiteFavoriteBody.
  ///
  /// In es, this message translates to:
  /// **'Se descarta este guardado. El sitio quedará en Mis favoritos y verás su ficha.'**
  String get sameSiteFavoriteBody;

  /// No description provided for @sameSiteLinkNeedPublic.
  ///
  /// In es, this message translates to:
  /// **'La reseña pública solo aplica en sitios públicos.'**
  String get sameSiteLinkNeedPublic;

  /// No description provided for @sameSitePickSiteFirst.
  ///
  /// In es, this message translates to:
  /// **'Toca Usar como en una tarjeta; luego elige una opción abajo.'**
  String get sameSitePickSiteFirst;

  /// No description provided for @sameSiteHardBody.
  ///
  /// In es, this message translates to:
  /// **'Ya existe un sitio público parecido. Puedes usarlo (quedarás como «compartido por») o guardar el tuyo de todas formas.'**
  String get sameSiteHardBody;

  /// No description provided for @sameSiteSoftBody.
  ///
  /// In es, this message translates to:
  /// **'Ya existe un sitio público parecido. Úsalo para evitar duplicados, o sigue editando.'**
  String get sameSiteSoftBody;

  /// No description provided for @sameSitePickHint.
  ///
  /// In es, this message translates to:
  /// **'En cada tarjeta: Ver ficha o Usar como.'**
  String get sameSitePickHint;

  /// No description provided for @sameSiteHardPickHint.
  ///
  /// In es, this message translates to:
  /// **'Tocá Usar como si es el mismo sitio; abajo podés guardar de todas formas.'**
  String get sameSiteHardPickHint;

  /// No description provided for @sameSiteTapForDetail.
  ///
  /// In es, this message translates to:
  /// **'Ver ficha'**
  String get sameSiteTapForDetail;

  /// No description provided for @sameSiteUseIt.
  ///
  /// In es, this message translates to:
  /// **'Usar como'**
  String get sameSiteUseIt;

  /// No description provided for @sameSiteUsePickOption.
  ///
  /// In es, this message translates to:
  /// **'Elige una opción y confirma abajo.'**
  String get sameSiteUsePickOption;

  /// No description provided for @sameSiteUseConfirmSave.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get sameSiteUseConfirmSave;

  /// No description provided for @sameSiteDiscardConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Descartar este guardado?'**
  String get sameSiteDiscardConfirmTitle;

  /// No description provided for @sameSiteDiscardConfirmBodyReview.
  ///
  /// In es, this message translates to:
  /// **'Se descartará lo que estabas guardando. Irás a la ficha del sitio, pestaña Reseñas, para escribir tu reseña pública.'**
  String get sameSiteDiscardConfirmBodyReview;

  /// No description provided for @sameSiteDiscardConfirmBodyJournal.
  ///
  /// In es, this message translates to:
  /// **'Se descartará lo que estabas guardando. Irás a la ficha del sitio, pestaña Reseñas, para escribir tu reseña privada.'**
  String get sameSiteDiscardConfirmBodyJournal;

  /// No description provided for @sameSiteDiscardConfirmBodyFavorite.
  ///
  /// In es, this message translates to:
  /// **'Se descartará lo que estabas guardando. El sitio quedará en favoritos y verás su ficha en Info.'**
  String get sameSiteDiscardConfirmBodyFavorite;

  /// No description provided for @sameSiteDiscardConfirmBodyGeneric.
  ///
  /// In es, this message translates to:
  /// **'Se descartará lo que estabas guardando e irás al sitio elegido.'**
  String get sameSiteDiscardConfirmBodyGeneric;

  /// No description provided for @sameSiteOptionReviewPublic.
  ///
  /// In es, this message translates to:
  /// **'Reseña pública'**
  String get sameSiteOptionReviewPublic;

  /// No description provided for @sameSiteOptionReviewPrivate.
  ///
  /// In es, this message translates to:
  /// **'Reseña privada'**
  String get sameSiteOptionReviewPrivate;

  /// No description provided for @sameSiteOptionJournal.
  ///
  /// In es, this message translates to:
  /// **'Reseña privada'**
  String get sameSiteOptionJournal;

  /// No description provided for @sameSiteOptionFavorite.
  ///
  /// In es, this message translates to:
  /// **'Agregar a favoritos'**
  String get sameSiteOptionFavorite;

  /// No description provided for @sameSiteInfoTitle.
  ///
  /// In es, this message translates to:
  /// **'Información'**
  String get sameSiteInfoTitle;

  /// No description provided for @sameSiteMarkThis.
  ///
  /// In es, this message translates to:
  /// **'Marcar este'**
  String get sameSiteMarkThis;

  /// No description provided for @sameSiteMetersAway.
  ///
  /// In es, this message translates to:
  /// **'a {meters} m'**
  String sameSiteMetersAway(int meters);

  /// No description provided for @sameSiteStaffHint.
  ///
  /// In es, this message translates to:
  /// **'Hay un sitio público parecido. Edítalo desde su ficha; no creamos duplicados.'**
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

  /// No description provided for @reviewEditorTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu reseña'**
  String get reviewEditorTitle;

  /// No description provided for @reviewRatingLabel.
  ///
  /// In es, this message translates to:
  /// **'Puntuación'**
  String get reviewRatingLabel;

  /// No description provided for @reviewCommentLabel.
  ///
  /// In es, this message translates to:
  /// **'Comentario'**
  String get reviewCommentLabel;

  /// No description provided for @reviewAddPhoto.
  ///
  /// In es, this message translates to:
  /// **'Foto'**
  String get reviewAddPhoto;

  /// No description provided for @reviewSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar reseña'**
  String get reviewSave;

  /// No description provided for @reviewMaxPhotos.
  ///
  /// In es, this message translates to:
  /// **'Máximo 3 fotos por reseña.'**
  String get reviewMaxPhotos;

  /// No description provided for @reviewEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay reseñas. Sé el primero.'**
  String get reviewEmpty;

  /// No description provided for @reviewWrite.
  ///
  /// In es, this message translates to:
  /// **'Escribir reseña'**
  String get reviewWrite;

  /// No description provided for @reviewEditMine.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get reviewEditMine;

  /// No description provided for @reviewDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get reviewDelete;

  /// No description provided for @reviewDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar reseña?'**
  String get reviewDeleteTitle;

  /// No description provided for @reviewDeleteBody.
  ///
  /// In es, this message translates to:
  /// **'Se borrará esta reseña y sus fotos. No se puede deshacer.'**
  String get reviewDeleteBody;

  /// No description provided for @reviewDeleted.
  ///
  /// In es, this message translates to:
  /// **'Reseña eliminada.'**
  String get reviewDeleted;

  /// No description provided for @reviewMakePublic.
  ///
  /// In es, this message translates to:
  /// **'Visible en la ficha'**
  String get reviewMakePublic;

  /// No description provided for @reviewPublicHint.
  ///
  /// In es, this message translates to:
  /// **'Aparece en la ficha y cuenta para el promedio'**
  String get reviewPublicHint;

  /// No description provided for @reviewPrivateHint.
  ///
  /// In es, this message translates to:
  /// **'Solo tú la ves (bitácora / historial)'**
  String get reviewPrivateHint;

  /// No description provided for @reviewPrivateBadge.
  ///
  /// In es, this message translates to:
  /// **'Bitácora'**
  String get reviewPrivateBadge;

  /// No description provided for @staffModeBanner.
  ///
  /// In es, this message translates to:
  /// **'{role}: privilegios de dueño en sitios y contenido público (las bitácoras privadas solo las ve su autor).'**
  String staffModeBanner(String role);

  /// No description provided for @staffRoleAdmin.
  ///
  /// In es, this message translates to:
  /// **'Admin'**
  String get staffRoleAdmin;

  /// No description provided for @staffRoleRoot.
  ///
  /// In es, this message translates to:
  /// **'Root'**
  String get staffRoleRoot;

  /// No description provided for @visibilityTooltipPublic.
  ///
  /// In es, this message translates to:
  /// **'Visible para todos'**
  String get visibilityTooltipPublic;

  /// No description provided for @visibilityTooltipPrivate.
  ///
  /// In es, this message translates to:
  /// **'Solo tú'**
  String get visibilityTooltipPrivate;

  /// No description provided for @reviewFilterAll.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get reviewFilterAll;

  /// No description provided for @reviewFilterMine.
  ///
  /// In es, this message translates to:
  /// **'Mías'**
  String get reviewFilterMine;

  /// No description provided for @reviewFilterEmpty.
  ///
  /// In es, this message translates to:
  /// **'Ninguna reseña con ese filtro.'**
  String get reviewFilterEmpty;

  /// No description provided for @reviewSortLabel.
  ///
  /// In es, this message translates to:
  /// **'Ordenar'**
  String get reviewSortLabel;

  /// No description provided for @reviewSortNewest.
  ///
  /// In es, this message translates to:
  /// **'Más recientes'**
  String get reviewSortNewest;

  /// No description provided for @reviewSortOldest.
  ///
  /// In es, this message translates to:
  /// **'Más antiguas'**
  String get reviewSortOldest;

  /// No description provided for @reviewSortRatingHigh.
  ///
  /// In es, this message translates to:
  /// **'Mejor puntuación'**
  String get reviewSortRatingHigh;

  /// No description provided for @reviewSortRatingLow.
  ///
  /// In es, this message translates to:
  /// **'Peor puntuación'**
  String get reviewSortRatingLow;

  /// No description provided for @reviewAvg.
  ///
  /// In es, this message translates to:
  /// **'{avg} · {count} reseñas'**
  String reviewAvg(String avg, int count);

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

  /// No description provided for @locationMarkMapFirst.
  ///
  /// In es, this message translates to:
  /// **'Buscá un lugar o tocá el mapa para confirmar.'**
  String get locationMarkMapFirst;

  /// No description provided for @locationPinOnly.
  ///
  /// In es, this message translates to:
  /// **'Solo este punto'**
  String get locationPinOnly;

  /// No description provided for @locationNearbyPlace.
  ///
  /// In es, this message translates to:
  /// **'Lugar'**
  String get locationNearbyPlace;

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

  /// No description provided for @planMenuEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar plan'**
  String get planMenuEdit;

  /// No description provided for @planEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar plan'**
  String get planEditTitle;

  /// No description provided for @planEditTitleHint.
  ///
  /// In es, this message translates to:
  /// **'Nombre, zona y presupuesto de este plan.'**
  String get planEditTitleHint;

  /// No description provided for @planEditSaved.
  ///
  /// In es, this message translates to:
  /// **'Plan actualizado.'**
  String get planEditSaved;

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

  /// No description provided for @planItinerary.
  ///
  /// In es, this message translates to:
  /// **'Itinerario'**
  String get planItinerary;

  /// No description provided for @planStatStops.
  ///
  /// In es, this message translates to:
  /// **'Paradas'**
  String get planStatStops;

  /// No description provided for @planStatBudget.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto'**
  String get planStatBudget;

  /// No description provided for @planStatZone.
  ///
  /// In es, this message translates to:
  /// **'Zona'**
  String get planStatZone;

  /// No description provided for @cardSavedHeart.
  ///
  /// In es, this message translates to:
  /// **'En tus guardados'**
  String get cardSavedHeart;

  /// No description provided for @favoriteAdd.
  ///
  /// In es, this message translates to:
  /// **'Agregar a favoritos'**
  String get favoriteAdd;

  /// No description provided for @favoriteRemove.
  ///
  /// In es, this message translates to:
  /// **'Quitar de favoritos'**
  String get favoriteRemove;

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

  /// No description provided for @planReorderStop.
  ///
  /// In es, this message translates to:
  /// **'Reordenar'**
  String get planReorderStop;

  /// No description provided for @planReorderHint.
  ///
  /// In es, this message translates to:
  /// **'Arrastra el ícono para cambiar el orden de los sitios.'**
  String get planReorderHint;

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

  /// No description provided for @comingSoonBadge.
  ///
  /// In es, this message translates to:
  /// **'Próximamente'**
  String get comingSoonBadge;

  /// No description provided for @comingSoonAiTitle.
  ///
  /// In es, this message translates to:
  /// **'Armame un plan con IA'**
  String get comingSoonAiTitle;

  /// No description provided for @comingSoonAiBody.
  ///
  /// In es, this message translates to:
  /// **'La generación automática de planes estará disponible más adelante. Podés armar el plan eligiendo sitios que ya guardaste.'**
  String get comingSoonAiBody;

  /// No description provided for @comingSoonTransportTitle.
  ///
  /// In es, this message translates to:
  /// **'Transporte entre paradas'**
  String get comingSoonTransportTitle;

  /// No description provided for @comingSoonTransportBody.
  ///
  /// In es, this message translates to:
  /// **'El cálculo de transporte sugerido entre paradas estará disponible más adelante.'**
  String get comingSoonTransportBody;

  /// No description provided for @planZoneHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Villa de Leyva, Boyacá'**
  String get planZoneHint;

  /// No description provided for @planIncludePublicSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Suma sitios públicos de otros a las opciones'**
  String get planIncludePublicSubtitle;

  /// No description provided for @planCreateNextStops.
  ///
  /// In es, this message translates to:
  /// **'Siguiente: armar paradas'**
  String get planCreateNextStops;

  /// No description provided for @planCreateAiCta.
  ///
  /// In es, this message translates to:
  /// **'Armame un plan con IA'**
  String get planCreateAiCta;

  /// No description provided for @categoryPickerSelectGroup.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar todo el grupo'**
  String get categoryPickerSelectGroup;

  /// No description provided for @categoryPickerSummary.
  ///
  /// In es, this message translates to:
  /// **'{total} categorías · {groups} grupos'**
  String categoryPickerSummary(int total, int groups);

  /// No description provided for @categoryPickerResults.
  ///
  /// In es, this message translates to:
  /// **'{count} resultado(s)'**
  String categoryPickerResults(int count);

  /// No description provided for @adminStatCategories.
  ///
  /// In es, this message translates to:
  /// **'Categorías'**
  String get adminStatCategories;

  /// No description provided for @adminStatVehicles.
  ///
  /// In es, this message translates to:
  /// **'Vehículos'**
  String get adminStatVehicles;

  /// No description provided for @adminStatReports.
  ///
  /// In es, this message translates to:
  /// **'Reportes abiertos'**
  String get adminStatReports;

  /// No description provided for @errorGeneric.
  ///
  /// In es, this message translates to:
  /// **'Error en la app. Intenta de nuevo.'**
  String get errorGeneric;

  /// No description provided for @errorGenericLead.
  ///
  /// In es, this message translates to:
  /// **'Error en la app.'**
  String get errorGenericLead;

  /// No description provided for @errorRetryAction.
  ///
  /// In es, this message translates to:
  /// **'Intenta de nuevo'**
  String get errorRetryAction;

  /// No description provided for @errorProblemToast.
  ///
  /// In es, this message translates to:
  /// **'Se ha presentado un problema.'**
  String get errorProblemToast;

  /// No description provided for @errorLoadRetry.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar. Intenta de nuevo.'**
  String get errorLoadRetry;

  /// No description provided for @siteDetailOpenMapsFail.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir Google Maps.'**
  String get siteDetailOpenMapsFail;

  /// No description provided for @photoTermsBody.
  ///
  /// In es, this message translates to:
  /// **'Al subir una foto confirmas que cumple los Términos de Uso de Chevere Plan (turismo, gastronomía y planes de ocio; sin contenido sexual, ilegal o de acoso).'**
  String get photoTermsBody;

  /// No description provided for @photoAdded.
  ///
  /// In es, this message translates to:
  /// **'Foto añadida.'**
  String get photoAdded;

  /// No description provided for @photoDeleted.
  ///
  /// In es, this message translates to:
  /// **'Foto eliminada.'**
  String get photoDeleted;

  /// No description provided for @photoReportReason.
  ///
  /// In es, this message translates to:
  /// **'Motivo (opcional)'**
  String get photoReportReason;

  /// No description provided for @photoReportSent.
  ///
  /// In es, this message translates to:
  /// **'Reporte enviado. Un administrador lo revisará.'**
  String get photoReportSent;

  /// No description provided for @reviewReportTitle.
  ///
  /// In es, this message translates to:
  /// **'Reportar reseña'**
  String get reviewReportTitle;

  /// No description provided for @reviewReportSent.
  ///
  /// In es, this message translates to:
  /// **'Reporte enviado. Un administrador lo revisará.'**
  String get reviewReportSent;

  /// No description provided for @reviewReportAlready.
  ///
  /// In es, this message translates to:
  /// **'Ya reportaste esta reseña.'**
  String get reviewReportAlready;

  /// No description provided for @reportsReviewFallback.
  ///
  /// In es, this message translates to:
  /// **'Reseña reportada'**
  String get reportsReviewFallback;

  /// No description provided for @reportsReviewLabel.
  ///
  /// In es, this message translates to:
  /// **'Reseña'**
  String get reportsReviewLabel;

  /// No description provided for @reportsPhotoLabel.
  ///
  /// In es, this message translates to:
  /// **'Foto'**
  String get reportsPhotoLabel;

  /// No description provided for @adminInactive.
  ///
  /// In es, this message translates to:
  /// **'Inactiva'**
  String get adminInactive;

  /// No description provided for @adminKeywords.
  ///
  /// In es, this message translates to:
  /// **'Palabras clave'**
  String get adminKeywords;

  /// No description provided for @adminKeywordsHint.
  ///
  /// In es, this message translates to:
  /// **'Separadas por coma (ej. nadar, agua, pool)'**
  String get adminKeywordsHint;

  /// No description provided for @adminNameEs.
  ///
  /// In es, this message translates to:
  /// **'Nombre (es)'**
  String get adminNameEs;

  /// No description provided for @adminEditCategory.
  ///
  /// In es, this message translates to:
  /// **'Editar categoría'**
  String get adminEditCategory;

  /// No description provided for @adminEditSubcategory.
  ///
  /// In es, this message translates to:
  /// **'Editar subcategoría'**
  String get adminEditSubcategory;

  /// No description provided for @adminTransportActive.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get adminTransportActive;

  /// No description provided for @adminTransportMaxKm.
  ///
  /// In es, this message translates to:
  /// **'Máx. km por defecto (vacío = sin tope)'**
  String get adminTransportMaxKm;

  /// No description provided for @locationMapsUnavailable.
  ///
  /// In es, this message translates to:
  /// **'El mapa no está disponible. Busca o toca el mapa.'**
  String get locationMapsUnavailable;

  /// No description provided for @locationSearchMinChars.
  ///
  /// In es, this message translates to:
  /// **'Escribe al menos 3 letras y toca buscar.'**
  String get locationSearchMinChars;

  /// No description provided for @locationGpsFail.
  ///
  /// In es, this message translates to:
  /// **'No se pudo obtener tu ubicación. Busca o toca el mapa.'**
  String get locationGpsFail;

  /// No description provided for @locationProviderGoogle.
  ///
  /// In es, this message translates to:
  /// **'Google Maps · buscar solo con 🔍'**
  String get locationProviderGoogle;

  /// No description provided for @locationProviderFallback.
  ///
  /// In es, this message translates to:
  /// **'Búsqueda alternativa activa'**
  String get locationProviderFallback;

  /// No description provided for @locationProviderNone.
  ///
  /// In es, this message translates to:
  /// **'Mapa no disponible'**
  String get locationProviderNone;

  /// No description provided for @formatDistanceKm.
  ///
  /// In es, this message translates to:
  /// **'{km} km'**
  String formatDistanceKm(String km);

  /// No description provided for @formatDistanceValue.
  ///
  /// In es, this message translates to:
  /// **'{value} {symbol}'**
  String formatDistanceValue(String value, String symbol);

  /// No description provided for @defaultUserDisplayName.
  ///
  /// In es, this message translates to:
  /// **'Usuario'**
  String get defaultUserDisplayName;

  /// No description provided for @reviewAuthorYou.
  ///
  /// In es, this message translates to:
  /// **'Tú'**
  String get reviewAuthorYou;

  /// No description provided for @notifChannelProximityName.
  ///
  /// In es, this message translates to:
  /// **'Recuerdos cercanos'**
  String get notifChannelProximityName;

  /// No description provided for @notifChannelProximityDesc.
  ///
  /// In es, this message translates to:
  /// **'Avisos cuando estás cerca de un lugar guardado'**
  String get notifChannelProximityDesc;

  /// No description provided for @notifChannelDraftName.
  ///
  /// In es, this message translates to:
  /// **'Recordatorios de borradores'**
  String get notifChannelDraftName;

  /// No description provided for @notifChannelDraftDesc.
  ///
  /// In es, this message translates to:
  /// **'Te recuerda completar lugares guardados incompletos'**
  String get notifChannelDraftDesc;

  /// No description provided for @notifChannelEventName.
  ///
  /// In es, this message translates to:
  /// **'Eventos de interés'**
  String get notifChannelEventName;

  /// No description provided for @notifChannelEventDesc.
  ///
  /// In es, this message translates to:
  /// **'Avisos de eventos cerca de tus guardados (próximamente)'**
  String get notifChannelEventDesc;

  /// No description provided for @notifChannelSummaryName.
  ///
  /// In es, this message translates to:
  /// **'Resúmenes'**
  String get notifChannelSummaryName;

  /// No description provided for @notifChannelSummaryDesc.
  ///
  /// In es, this message translates to:
  /// **'Resumen mensual de planes y visitas (próximamente)'**
  String get notifChannelSummaryDesc;

  /// No description provided for @notifProximityContext.
  ///
  /// In es, this message translates to:
  /// **'Lugar cerca de ti'**
  String get notifProximityContext;

  /// No description provided for @notifDraftContext.
  ///
  /// In es, this message translates to:
  /// **'Completa tu guardado'**
  String get notifDraftContext;

  /// No description provided for @notifEventContext.
  ///
  /// In es, this message translates to:
  /// **'Evento de interés'**
  String get notifEventContext;

  /// No description provided for @notifSummaryContext.
  ///
  /// In es, this message translates to:
  /// **'Resumen del mes'**
  String get notifSummaryContext;

  /// No description provided for @notifPlaceFallback.
  ///
  /// In es, this message translates to:
  /// **'Lugar guardado'**
  String get notifPlaceFallback;

  /// No description provided for @notifTestSectionTitle.
  ///
  /// In es, this message translates to:
  /// **'Pruebas · notificaciones'**
  String get notifTestSectionTitle;

  /// No description provided for @notifTestSectionHint.
  ///
  /// In es, this message translates to:
  /// **'Solo etapa de pruebas; se quitará luego.'**
  String get notifTestSectionHint;

  /// No description provided for @notifTestChipProximity.
  ///
  /// In es, this message translates to:
  /// **'Cerca'**
  String get notifTestChipProximity;

  /// No description provided for @notifTestChipDraft.
  ///
  /// In es, this message translates to:
  /// **'Borrador'**
  String get notifTestChipDraft;

  /// No description provided for @notifTestChipEvent.
  ///
  /// In es, this message translates to:
  /// **'Evento'**
  String get notifTestChipEvent;

  /// No description provided for @notifTestChipSummary.
  ///
  /// In es, this message translates to:
  /// **'Resumen'**
  String get notifTestChipSummary;

  /// No description provided for @notifTestSent.
  ///
  /// In es, this message translates to:
  /// **'Notificación enviada.'**
  String get notifTestSent;

  /// No description provided for @reviewEditedOn.
  ///
  /// In es, this message translates to:
  /// **' · editado {date}'**
  String reviewEditedOn(String date);

  /// No description provided for @saveSuccessTitleCreate.
  ///
  /// In es, this message translates to:
  /// **'¡Lugar guardado!'**
  String get saveSuccessTitleCreate;

  /// No description provided for @saveSuccessTitleUpdate.
  ///
  /// In es, this message translates to:
  /// **'¡Actualizado!'**
  String get saveSuccessTitleUpdate;

  /// No description provided for @saveSuccessStaffBody.
  ///
  /// In es, this message translates to:
  /// **'Cambios del sitio guardados.'**
  String get saveSuccessStaffBody;

  /// No description provided for @saveSuccessCompleteBody.
  ///
  /// In es, this message translates to:
  /// **'Quedó completo en tu lista.'**
  String get saveSuccessCompleteBody;

  /// No description provided for @saveSuccessPrivateSuffix.
  ///
  /// In es, this message translates to:
  /// **' Privado por defecto.'**
  String get saveSuccessPrivateSuffix;

  /// No description provided for @saveLinkFallback.
  ///
  /// In es, this message translates to:
  /// **'Enlace'**
  String get saveLinkFallback;

  /// No description provided for @adminTransportInactive.
  ///
  /// In es, this message translates to:
  /// **'Inactivo'**
  String get adminTransportInactive;

  /// No description provided for @adminTransportNoKmCap.
  ///
  /// In es, this message translates to:
  /// **'Sin tope km'**
  String get adminTransportNoKmCap;

  /// No description provided for @adminTransportMaxKmShort.
  ///
  /// In es, this message translates to:
  /// **'Máx {km} km'**
  String adminTransportMaxKmShort(int km);

  /// No description provided for @adminTransportGroupOther.
  ///
  /// In es, this message translates to:
  /// **'Otro (plataformas)'**
  String get adminTransportGroupOther;
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
