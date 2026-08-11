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
  /// **'Aún no tienes planes. Arma uno a partir de tus guardados por ciudad o departamento.'**
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

  /// No description provided for @searchEmptyHint.
  ///
  /// In es, this message translates to:
  /// **'Escribe y pulsa Buscar.'**
  String get searchEmptyHint;

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
