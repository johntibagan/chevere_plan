import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../../core/cache/cache_ttl.dart';
import '../../../core/cache/search_cache.dart';
import '../../../core/config/env.dart';
import '../../../core/di/providers.dart';
import '../../../core/logging/client_debug_log.dart';
import '../../../core/testing/widget_keys.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_form_card.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_retry_callout.dart';
import '../../../core/widgets/app_section_label.dart';
import '../../../core/widgets/app_select_chip.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/field_action_icon.dart';
import 'site_look_cover.dart';
import '../../admin/data/admin_models.dart';
import '../../geo/domain/geo_models.dart';
import '../../geo/domain/geo_fuzzy.dart';
import '../../geo/presentation/geo_typeahead_field.dart';
import '../../moderation/data/moderation_models.dart';
import '../data/geo_place.dart';
import '../data/google_maps_link_importer.dart';
import '../data/google_places_client.dart';
import '../data/place_geocoder.dart';
import '../data/save_models.dart';
import '../data/saves_repository.dart';
import '../data/share_parser.dart';
import '../data/site_review_models.dart';
import '../data/social_link_models.dart';
import '../data/social_place_extractor.dart';
import '../domain/category_suggester.dart';
import '../domain/save_policies.dart';
import 'category_picker_sheet.dart';
import 'location_picker_page.dart';
import 'same_site_picker_page.dart';
import 'site_review_editor_page.dart';
import 'site_status_l10n.dart';
import 'social_link_preview_card.dart';

enum _SaveExtra { name, details, links, categories, photo }

/// Foto pendiente en memoria (no archivo temp: Android puede borrarlo y la
/// miniatura seguiría viéndose por ImageCache).
class _PendingPhoto {
  const _PendingPhoto({required this.bytes, required this.ext});

  final Uint8List bytes;
  final String ext;
}

class SavePlacePage extends ConsumerStatefulWidget {
  const SavePlacePage({
    super.key,
    this.initialSharedText,
    this.existingSaveId,
    this.existingSiteId,
    required this.savesRepository,
  }) : assert(
          existingSaveId == null || existingSiteId == null,
          'Usar existingSaveId o existingSiteId, no ambos',
        );

  final String? initialSharedText;
  /// Si viene, carga y actualiza ese guardado (completar borrador / editar).
  final String? existingSaveId;
  /// Admin/root o creador sin guardado: edita sitio sin `user_saves`.
  final String? existingSiteId;
  final SavesRepository savesRepository;

  @override
  ConsumerState<SavePlacePage> createState() => _SavePlacePageState();
}

class _SavePlacePageState extends ConsumerState<SavePlacePage>
    with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _mapsCtrl = TextEditingController();
  final _socialCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();
  final _deptFocus = FocusNode();
  final _cityFocus = FocusNode();
  final _addressCtrl = TextEditingController();
  final _categorySearchCtrl = TextEditingController();
  GeoCatalog? _geoCatalog;
  GeoDepartment? _selectedDept;
  GeoCity? _selectedCity;

  double? _lat;
  double? _lng;
  String? _googlePlaceId;
  /// false = Maps abre el **lugar** (nombre/place id); true = **punto exacto** (lat/lng).
  bool _useExactPin = false;
  /// Había pin persistido al abrir (editar). Si lo quitan, hay que borrar en DB.
  bool _hadStoredCoords = false;

  List<Category> _categories = [];
  final Set<String> _selectedCategoryIds = {};
  bool _isPublic = false;
  bool _isPhysical = true;
  bool _loadingCats = true;
  bool _saving = false;
  bool _importingMaps = false;
  bool _addingSocial = false;
  TabController? _locationTabCtrl;
  bool _cameraBusy = false;
  /// true = pegar enlace Google Maps; false = mapa interactivo.
  final Set<_SaveExtra> _openExtras = {};
  final List<_PendingPhoto> _pendingPhotos = [];
  final List<SitePhoto> _existingPhotos = [];
  final Map<String, String> _existingPhotoUrls = {};
  bool _loadingExistingPhotos = false;
  bool _existingPhotosLoaded = false;
  final _photoUuid = const Uuid();
  String? _pendingMapImageUrl;
  String? _editSaveId;
  String? _editSiteId;
  /// Visibilidad al cargar (editar): detecta público → privado.
  bool _loadedIsPublic = false;
  final List<SocialLinkDraft> _socialLinks = [];
  final _socialExtractor = SocialPlaceExtractor();

  PlaceGeocoder get _placeGeocoder => ref.read(placeGeocoderProvider);
  GooglePlacesClient get _placesClient => ref.read(googlePlacesClientProvider);
  GoogleMapsLinkImporter get _mapsImporter => GoogleMapsLinkImporter(
        geocoder: _placeGeocoder,
        places: _placesClient,
      );
  /// Si el usuario eligió/quitó categorías a mano, no sobrescribir la sugerencia.
  bool _categoriesUserTouched = false;
  bool _categoryWasAutoSuggested = false;
  bool _categoriesUnavailable = false;
  bool _reloadingCategories = false;

  bool get _isEditing => _editSaveId != null || _editSiteId != null;
  bool get _isStaffSiteEdit =>
      _editSaveId == null && _editSiteId != null;

  void _openNameSectionIfNeeded({String? name}) {
    if (_isEditing) return;
    if (_openExtras.contains(_SaveExtra.name)) return;
    if ((name ?? _nameCtrl.text).trim().isNotEmpty) {
      setState(() => _openExtras.add(_SaveExtra.name));
    }
  }

  Future<void> _warmDeviceLocation() async {
    final loc = ref.read(deviceLocationProvider);
    await loc.access(request: false);
    await loc.lastKnown();
  }

  void _bindGeo({
    String? departmentId,
    String? cityId,
    String? department,
    String? city,
  }) {
    final cat = _geoCatalog;
    if (cat == null) return;
    if (departmentId != null) {
      _selectedDept = cat.departmentById(departmentId);
    }
    if (cityId != null) {
      _selectedCity = cat.cityById(cityId);
      if (_selectedCity != null) {
        _selectedDept ??= cat.departmentById(_selectedCity!.departmentId);
      }
    }
    if (_selectedDept == null || _selectedCity == null) {
      final m = GeoFuzzy.match(
        catalog: cat,
        departmentHint: department,
        cityHint: city,
      );
      _selectedDept ??= m.department;
      if (_selectedDept != null) {
        _selectedCity ??= m.city;
      }
    }
    _deptCtrl.text = _selectedDept?.name ?? '';
    _cityCtrl.text = _selectedCity?.name ?? '';
  }

  void _applyGeoHints({String? department, String? city}) {
    final cat = _geoCatalog;
    if (cat == null) return;
    final m = GeoFuzzy.match(
      catalog: cat,
      departmentHint: department,
      cityHint: city,
    );
    if (m.department != null) {
      _setDepartment(m.department, clearCity: m.city == null);
    }
    if (m.city != null) _setCity(m.city);
  }

  void _setDepartment(GeoDepartment? d, {bool clearCity = true}) {
    final changed = d?.id != _selectedDept?.id;
    _selectedDept = d;
    _deptCtrl.text = d?.name ?? '';
    if (changed && clearCity) {
      _selectedCity = null;
      _cityCtrl.clear();
    }
  }

  void _setCity(GeoCity? c) {
    _selectedCity = c;
    _cityCtrl.text = c?.name ?? '';
    if (c != null && _geoCatalog != null) {
      _selectedDept ??= _geoCatalog!.departmentById(c.departmentId);
      if (_selectedDept != null) _deptCtrl.text = _selectedDept!.name;
    }
  }

  @override
  void initState() {
    super.initState();
    if (!_isEditing) {
      _locationTabCtrl = TabController(length: 3, vsync: this)
        ..addListener(() {
          if (_locationTabCtrl!.indexIsChanging) return;
          if (_locationTabCtrl!.index == 2) {
            unawaited(_warmDeviceLocation());
          }
          setState(() {});
        });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_warmDeviceLocation());
      });
    }
    final parsed = ShareParser.parse(widget.initialSharedText);
    if (parsed.url != null) {
      if (GoogleMapsLinkImporter.looksLikeMapsUrl(parsed.url)) {
        _mapsCtrl.text = parsed.url!;
        _locationTabCtrl?.index = 1;
      } else {
        _socialCtrl.text = parsed.url!;
      }
    }
    if (parsed.suggestedName != null) _nameCtrl.text = parsed.suggestedName!;
    final shared = widget.initialSharedText?.trim();
    if (shared != null && shared.isNotEmpty) {
      _openExtras.add(_SaveExtra.links);
      final url = parsed.url;
      if (url == null || !GoogleMapsLinkImporter.looksLikeMapsUrl(url)) {
        _openExtras.add(_SaveExtra.name);
      }
    }
    _bootstrapForm();
  }

  Future<List<Category>> _loadCategoriesForForm() async {
    try {
      var cats = await ref.read(categoriesProvider.future);
      var active = cats.where((c) => c.isActive).toList();
      if (active.isEmpty) {
        cats = await ref.read(categoriesProvider.notifier).reloadFromNetwork();
        active = cats.where((c) => c.isActive).toList();
      }
      return active;
    } catch (_) {
      final cats =
          await ref.read(categoriesProvider.notifier).reloadFromNetwork();
      return cats.where((c) => c.isActive).toList();
    }
  }

  void _applyCategories(List<Category> active) {
    _categories = active;
    _categoriesUnavailable = active.isEmpty;
  }

  Future<void> _reloadCategories() async {
    if (_reloadingCategories) return;
    _reloadingCategories = true;
    if (mounted) {
      setState(() => _categoriesUnavailable = false);
    }
    try {
      final cats =
          await ref.read(categoriesProvider.notifier).reloadFromNetwork();
      if (!mounted) return;
      final active = cats.where((c) => c.isActive).toList();
      setState(() => _applyCategories(active));
      if (active.isNotEmpty && !_categoriesUserTouched) {
        _maybeSuggestCategories();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _categoriesUnavailable = true);
    } finally {
      _reloadingCategories = false;
    }
  }

  Future<void> _bootstrapForm() async {
    try {
      final catsFuture = _loadCategoriesForForm();
      GeoCatalog? catalog;
      try {
        catalog = await ref.read(geoCatalogProvider.future);
      } catch (_) {
        catalog = null;
      }
      final cats = await catsFuture;
      if (!mounted) return;
      setState(() {
        _geoCatalog = catalog;
        _applyCategories(cats);
      });

      final saveId = widget.existingSaveId;
      final siteIdOnly = widget.existingSiteId;
      if (saveId != null) {
        final data = await widget.savesRepository.loadForEdit(saveId);
        if (!mounted) return;
        final s = data.save;
        _nameCtrl.text = s.siteName == 'Sin nombre' ? '' : s.siteName;
        _addressCtrl.text = s.addressLine ?? '';
        _bindGeo(
          departmentId: s.departmentId,
          cityId: s.cityId,
          department: s.department,
          city: s.city,
        );
        final links = await widget.savesRepository.listSocialLinks(s.siteId);
        if (!mounted) return;
        setState(() {
          _editSaveId = s.id;
          _editSiteId = s.siteId;
          _isPublic = s.isPublic;
          _loadedIsPublic = s.isPublic;
          _isPhysical = s.isPhysicalPlace;
          _lat = data.latitude;
          _lng = data.longitude;
          _googlePlaceId = s.googlePlaceId;
          _useExactPin = s.useExactPin;
          _hadStoredCoords = data.latitude != null && data.longitude != null;
          _selectedCategoryIds
            ..clear()
            ..addAll(data.categoryIds);
          _categoriesUserTouched = data.categoryIds.isNotEmpty;
          _categoryWasAutoSuggested = false;
          _socialLinks
            ..clear()
            ..addAll(
              links.map(
                (l) => SocialLinkDraft(
                  url: l.url,
                  network: l.network,
                  title: l.title,
                  description: l.description,
                  imageUrl: l.imageUrl,
                  existingId: l.id,
                ),
              ),
            );
          if (_socialLinks.isEmpty &&
              (s.sourceUrl?.trim().isNotEmpty ?? false)) {
            _socialLinks.add(
              SocialLinkDraft(
                url: s.sourceUrl!,
                network: s.sourceNetwork,
              ),
            );
          }
          _openExtras.addAll(_SaveExtra.values);
          _loadingCats = false;
        });
      } else if (siteIdOnly != null) {
        final data =
            await widget.savesRepository.loadSiteForStaffEdit(siteIdOnly);
        if (!mounted) return;
        _nameCtrl.text = data.name == 'Sin nombre' ? '' : data.name;
        _addressCtrl.text = data.addressLine ?? '';
        _bindGeo(
          departmentId: data.departmentId,
          cityId: data.cityId,
          department: data.department,
          city: data.city,
        );
        final links =
            await widget.savesRepository.listSocialLinks(data.siteId);
        if (!mounted) return;
        setState(() {
          _editSaveId = null;
          _editSiteId = data.siteId;
          _isPublic = data.isPublic;
          _loadedIsPublic = data.isPublic;
          _isPhysical = data.isPhysicalPlace;
          _lat = data.latitude;
          _lng = data.longitude;
          _googlePlaceId = data.googlePlaceId;
          _useExactPin = data.useExactPin;
          _hadStoredCoords = data.latitude != null && data.longitude != null;
          _selectedCategoryIds
            ..clear()
            ..addAll(data.categoryIds);
          _categoriesUserTouched = data.categoryIds.isNotEmpty;
          _categoryWasAutoSuggested = false;
          _socialLinks
            ..clear()
            ..addAll(
              links.map(
                (l) => SocialLinkDraft(
                  url: l.url,
                  network: l.network,
                  title: l.title,
                  description: l.description,
                  imageUrl: l.imageUrl,
                  existingId: l.id,
                ),
              ),
            );
          _openExtras.addAll(_SaveExtra.values);
          _loadingCats = false;
        });
      } else {
        // Pintar form al toque (categorías listas). Social/Maps no bloquean.
        if (mounted) setState(() => _loadingCats = false);
        final social = _socialCtrl.text.trim();
        if (social.isNotEmpty) {
          _socialCtrl.clear();
          unawaited(_addSocialLink(social));
        }
        if (_mapsCtrl.text.trim().isNotEmpty) {
          unawaited(_importFromGoogleMaps());
        } else if (social.isEmpty) {
          _maybeSuggestCategories();
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingCats = false;
        _categoriesUnavailable = true;
      });
      AppToast.error(context, e, logContext: 'save_place_bootstrap');
    }
  }

  @override
  void dispose() {
    _locationTabCtrl?.dispose();
    _nameCtrl.dispose();
    _mapsCtrl.dispose();
    _socialCtrl.dispose();
    _cityCtrl.dispose();
    _deptCtrl.dispose();
    _deptFocus.dispose();
    _cityFocus.dispose();
    _addressCtrl.dispose();
    _categorySearchCtrl.dispose();
    super.dispose();
  }

  /// Escribe en el form lo que trajo Maps o el mapa. Igual en crear y editar.
  void _fillFromPlace({
    String? name,
    String? city,
    String? department,
    String? address,
    double? lat,
    double? lng,
    String? staticMapUrl,
    String? googlePlaceId,
  }) {
    void put(TextEditingController c, String? v) {
      if (v != null && v.trim().isNotEmpty) c.text = v.trim();
    }

    setState(() {
      put(_nameCtrl, name);
      put(_addressCtrl, address);
      _applyGeoHints(department: department, city: city);
      _lat = lat ?? _lat;
      _lng = lng ?? _lng;
      if (googlePlaceId != null && googlePlaceId.trim().isNotEmpty) {
        _googlePlaceId = googlePlaceId.trim();
      }
      if (staticMapUrl != null && staticMapUrl.isNotEmpty) {
        _pendingMapImageUrl = staticMapUrl;
      }
      _openNameSectionIfNeeded(name: name);
    });
    if (!_isEditing) _maybeSuggestCategories(force: true);
  }

  String? _nameFromGeoPlace(GeoPlace? place) {
    if (place == null) return null;
    final city = place.city?.trim().toLowerCase();
    final rawName = place.name?.trim();
    if (rawName != null &&
        rawName.isNotEmpty &&
        (city == null || rawName.toLowerCase() != city)) {
      return rawName;
    }
    final display = place.displayName?.trim();
    if (display == null || display.isEmpty) return rawName;
    final first = display.split(',').first.trim();
    return first.isNotEmpty ? first : rawName;
  }

  Future<void> _importFromGoogleMaps() async {
    final text = _mapsCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _importingMaps = true);
    try {
      final result = await _mapsImporter.importFromText(text);
      if (!mounted) return;
      setState(() => _importingMaps = false);
      _fillFromPlace(
        name: result.name,
        city: result.city,
        department: result.department,
        address: result.addressLine,
        lat: result.lat,
        lng: result.lng,
        staticMapUrl: result.staticMapUrl,
        googlePlaceId: result.googlePlaceId,
      );
      if (!mounted) return;
      // Enlace de Maps = el usuario ya eligió el lugar. Conservar coords.
      // No preguntar "¿punto exacto?": eso tiraba el pin y bloqueaba Público.
      if (!result.hasCoords && (result.name ?? '').trim().length >= 2) {
        await _tryGeocodeImportedName(result.name!.trim());
        if (!mounted) return;
      }
      final linked = await _softCheckDuplicateAfterLocation();
      if (linked || !mounted) return;
      final hasPin = _lat != null && _lng != null;
      AppToast.show(
        context,
        !hasPin
            ? (Env.hasGoogleMapsKey
                ? context.l10n.saveMapsNeedExactPin
                : context.l10n.saveMapsNeedGoogleKey)
            : !result.hasExactPin && result.hasCoords
                ? context.l10n.saveMapsApproxPin
                : (_cityCtrl.text.trim().isNotEmpty
                    ? context.l10n.saveLocationAppliedNamed(
                        _nameCtrl.text.trim(),
                        _cityCtrl.text.trim(),
                      )
                    : context.l10n.saveMapsNeedCity),
        error: !hasPin,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _importingMaps = false);
      AppToast.error(context, e, logContext: 'import_maps');
    }
  }

  Future<void> _pasteMapsAndImport() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    final text = data?.text?.trim() ?? '';
    if (text.isEmpty) {
      AppToast.show(context, context.l10n.clipboardEmpty, error: true);
      return;
    }
    _mapsCtrl.text = text;
    await _importFromGoogleMaps();
  }

  Future<void> _pasteSocialAndAdd() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    final text = data?.text?.trim() ?? '';
    if (text.isEmpty) {
      AppToast.show(context, context.l10n.clipboardEmpty, error: true);
      return;
    }
    _socialCtrl.text = text;
    await _addSocialLink(text);
    _socialCtrl.clear();
  }

  Future<void> _addSocialLink(String raw) async {
    final parsed = ShareParser.parse(raw);
    final url = parsed.url ?? raw.trim();
    if (url.isEmpty || !url.startsWith('http')) {
      AppToast.show(context, context.l10n.saveSocialInvalid, error: true);
      return;
    }
    if (_socialLinks.any((l) => l.url == url)) {
      AppToast.show(context, context.l10n.saveSocialDuplicate, error: true);
      return;
    }
    setState(() => _addingSocial = true);
    final draft = SocialLinkDraft(url: url, network: parsed.network);
    setState(() {
      _socialLinks.add(draft);
      if (!_isEditing && !GoogleMapsLinkImporter.looksLikeMapsUrl(url)) {
        _openExtras.add(_SaveExtra.name);
      }
    });
    try {
      final hint = await _socialExtractor.extract(url);
      if (!mounted) return;
      setState(() {
        draft
          ..title = hint.title
          ..description = hint.description
          ..imageUrl = hint.imageUrl
          ..network = draft.network ?? hint.network;
        if ((_nameCtrl.text.trim().isEmpty ||
                _nameCtrl.text.trim() == 'Sin nombre') &&
            hint.suggestedPlaceName != null) {
          _nameCtrl.text = hint.suggestedPlaceName!;
        }
        _addingSocial = false;
      });
      _openNameSectionIfNeeded(name: hint.suggestedPlaceName);
      _maybeSuggestCategories();
      unawaited(_tryFillLocationFromHint(hint));
    } catch (_) {
      if (!mounted) return;
      setState(() => _addingSocial = false);
      _maybeSuggestCategories();
    }
  }

  static final _venueCue = RegExp(
    r'restaurante|hotel|hostal|parque|museo|finca|termales|mirador|'
    r'cafeter[ií]a|caf[eé]|playa|plaza|iglesia|cascada|glamping|'
    r'bar |discoteca|piscina|tejo|mercado',
    caseSensitive: false,
  );

  /// Si el enlace de Maps trajo nombre pero no pin, geocodifica una vez.
  Future<void> _tryGeocodeImportedName(String name) async {
    if (_hasFormLocation) return;
    try {
      final hits = await _placeGeocoder.search('$name Colombia', limit: 1);
      if (!mounted || hits.isEmpty || _hasFormLocation) return;
      final place = hits.first;
      setState(() {
        _lat ??= place.lat;
        _lng ??= place.lng;
        if (_selectedDept == null && _selectedCity == null) {
          _applyGeoHints(department: place.department, city: place.city);
        }
        if (_addressCtrl.text.trim().isEmpty &&
            (place.addressLine?.isNotEmpty ?? false)) {
          _addressCtrl.text = place.addressLine!;
        }
      });
    } catch (_) {}
  }

  bool get _hasFormLocation => SavePolicies.hasLocation(
        city: _selectedCity?.name,
        addressLine: _addressCtrl.text,
        latitude: _lat,
        longitude: _lng,
      );

  Future<void> _tryFillLocationFromHint(SocialPlaceHint hint) async {
    final name = hint.suggestedPlaceName;
    if (name == null || _hasFormLocation) return;
    if (!_venueCue.hasMatch(name) && !_venueCue.hasMatch(hint.haystack)) {
      return;
    }
    try {
      final hits = await _placeGeocoder.search('$name Colombia', limit: 1);
      if (!mounted || hits.isEmpty || _hasFormLocation) return;
      final place = hits.first;
      setState(() {
        _lat ??= place.lat;
        _lng ??= place.lng;
        if (_selectedDept == null && _selectedCity == null) {
          _applyGeoHints(department: place.department, city: place.city);
        }
        if (_addressCtrl.text.trim().isEmpty &&
            (place.addressLine?.isNotEmpty ?? false)) {
          _addressCtrl.text = place.addressLine!;
        }
      });
      _maybeSuggestCategories();
    } catch (_) {}
  }

  String _parentName(Category c) {
    if (c.parentId == null) return '';
    final parent = _categories.where((p) => p.id == c.parentId);
    return parent.isEmpty ? '' : parent.first.nameEs;
  }

  String get _categoryHaystack => [
        _nameCtrl.text,
        _cityCtrl.text,
        _deptCtrl.text,
        _addressCtrl.text,
        _mapsCtrl.text,
        for (final l in _socialLinks) ...[
          l.title,
          l.description,
          l.network,
          l.url,
        ],
      ].whereType<String>().join(' ');

  /// Sugiere y marca categoría según nombre / Maps; si no hay match → Otros.
  /// Solo al crear. En editar se respetan las categorías ya guardadas.
  void _maybeSuggestCategories({bool force = false}) {
    if (_isEditing) return;
    if (_categories.isEmpty) return;
    if (!force && _categoriesUserTouched) return;

    final suggestion = CategorySuggester.suggest(
      categories: _categories,
      haystack: _categoryHaystack,
    );
    if (suggestion.categories.isEmpty) return;

    setState(() {
      _selectedCategoryIds
        ..clear()
        ..addAll(suggestion.categories.map((c) => c.id));
      _categoryWasAutoSuggested = true;
      if (force) _categoriesUserTouched = false;
    });
  }

  List<String> _resolvedCategoryIds() {
    if (_selectedCategoryIds.isNotEmpty) {
      return _selectedCategoryIds.toList();
    }
    final fallback = CategorySuggester.defaultCategory(_categories);
    if (fallback != null) return [fallback.id];
    final suggestion = CategorySuggester.suggest(
      categories: _categories,
      haystack: _categoryHaystack,
    );
    return suggestion.categories.map((c) => c.id).toList();
  }

  void _markCategoriesTouched() {
    _categoriesUserTouched = true;
    _categoryWasAutoSuggested = false;
  }

  List<Category> get _filteredCategories {
    final q = _categorySearchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final hits = _categories.where((c) {
      if (!c.isActive) return false;
      if (c.matchesQuery(q)) return true;
      final parent = _categories.where((p) => p.id == c.parentId);
      if (parent.isNotEmpty && parent.first.matchesQuery(q)) return true;
      final parentName = _parentName(c).toLowerCase();
      if (parentName.contains(q)) return true;
      return false;
    }).toList();
    hits.sort((a, b) {
      if (a.isRoot != b.isRoot) return a.isRoot ? 1 : -1;
      return a.nameEs.compareTo(b.nameEs);
    });
    return hits.take(16).toList();
  }

  Future<void> _openCategoryTree() async {
    if (_categories.isEmpty) {
      await _reloadCategories();
    }

    if (_categories.isEmpty) {
      if (!mounted) return;
      setState(() {
        _categoriesUnavailable = true;
        _openExtras.add(_SaveExtra.categories);
      });
      return;
    }

    if (!mounted) return;
    final result = await showCategoryPickerSheet(
      context: context,
      categories: List<Category>.from(_categories),
      selectedIds: Set<String>.from(_selectedCategoryIds),
    );
    if (result == null || !mounted) return;
    setState(() {
      _markCategoriesTouched();
      _selectedCategoryIds
        ..clear()
        ..addAll(result);
    });
  }

  List<Category> get _selectedCategories {
    return _categories
        .where((c) => _selectedCategoryIds.contains(c.id))
        .toList();
  }

  Future<void> _openMap() async {
    final place = await Navigator.of(context).push<GeoPlace>(
      MaterialPageRoute(
        builder: (_) => LocationPickerPage(
          initialLat: _lat,
          initialLng: _lng,
        ),
      ),
    );
    if (place == null || !mounted) return;
    _fillFromPlace(
      name: place.name ?? place.displayName,
      city: place.city,
      department: place.department,
      address: place.addressLine ?? place.displayName,
      lat: place.lat,
      lng: place.lng,
      googlePlaceId: place.placeId,
    );
    if (!mounted) return;
    setState(() => _useExactPin = true);
    if (!mounted) return;
    // Soft check: diálogo (no Toast). Si sigue editando, al Guardar se reitera.
    final linked = await _softCheckDuplicateAfterLocation();
    if (linked || !mounted) return;
    AppToast.show(context, context.l10n.saveLocationApplied);
  }

  /// Chequeo suave tras mapa/import. `true` = vinculó + reseña (ya salió).
  Future<bool> _softCheckDuplicateAfterLocation() async {
    if (!_isPhysical) return false;
    final lat = _lat;
    final lng = _lng;
    final city = _selectedCity?.name;
    if ((lat == null || lng == null) &&
        (city == null || city.trim().isEmpty) &&
        (_googlePlaceId == null || _googlePlaceId!.trim().isEmpty)) {
      return false;
    }
    final name = _nameCtrl.text.trim();
    try {
      final dupes = await widget.savesRepository.findPossibleDuplicates(
        name: name,
        city: city,
        latitude: lat,
        longitude: lng,
        excludeSiteId: _editSiteId,
        googlePlaceId: _googlePlaceId,
      );
      if (dupes.isEmpty || !mounted) return false;

      if (_isStaffSiteEdit) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text(
              context.l10n.sameSiteTitle,
              style: TextStyle(color: AppColors.foreground),
            ),
            content: Text(
              context.l10n.sameSiteStaffHint,
              style: TextStyle(color: AppColors.muted),
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.l10n.actionDone),
              ),
            ],
          ),
        );
        return false;
      }

      final chosen = await _askDuplicate(dupes, allowCreateAnyway: false);
      if (chosen == null || !mounted) return false;
      if (chosen.action == SameSiteAction.saveAnyway) return false;
      final siteId = chosen.siteId;
      if (siteId == null) return false;
      PossibleDuplicate match = dupes.first;
      for (final d in dupes) {
        if (d.siteId == siteId) {
          match = d;
          break;
        }
      }

      final ok = await _linkExistingAndOpenReview(
        existingSiteId: siteId,
        displayName: name == 'Sin nombre' ? match.siteName : name,
        reviewIsPublic: chosen.action == SameSiteAction.reviewPublic,
      );
      return ok;
    } catch (e) {
      if (mounted) {
        AppToast.error(context, e, logContext: 'dupe_soft_check');
      }
      return false;
    }
  }

  /// Vincular a sitio público existente y abrir reseña.
  /// `true` si vinculó OK; `false` si falló o canceló internamente.
  Future<bool> _linkExistingAndOpenReview({
    required String existingSiteId,
    required String displayName,
    required bool reviewIsPublic,
  }) async {
    setState(() => _saving = true);
    try {
      var categoryIds = _resolvedCategoryIds();
      if (categoryIds.isEmpty) {
        setState(() => _saving = false);
        if (!mounted) return false;
        AppToast.show(
          context,
          'No hay categorías en la base. Aplica el seed / reseed de categorías.',
          error: true,
        );
        return false;
      }
      if (_selectedCategoryIds.isEmpty) {
        setState(() {
          _selectedCategoryIds.addAll(categoryIds);
          _categoryWasAutoSuggested = true;
        });
        categoryIds = _resolvedCategoryIds();
      }

      final primaryLink =
          _socialLinks.isNotEmpty ? _socialLinks.first : null;
      final mapsUrl = _mapsCtrl.text.trim();
      final sourceUrl = primaryLink?.url ??
          (GoogleMapsLinkImporter.looksLikeMapsUrl(mapsUrl) ? mapsUrl : null);
      final sourceNetwork = primaryLink?.network ??
          (GoogleMapsLinkImporter.looksLikeMapsUrl(mapsUrl)
              ? 'google_maps'
              : null);
      final onlyDefault = categoryIds.every((id) {
        final cat = _categories.where((c) => c.id == id);
        if (cat.isEmpty) return false;
        final c = cat.first;
        return c.slug == CategorySuggester.defaultChildSlug ||
            c.slug == CategorySuggester.defaultParentSlug;
      });
      final categoryIsExplicit =
          _categoriesUserTouched && !onlyDefault;

      final input = SaveDraftInput(
        name: displayName,
        sourceUrl: sourceUrl,
        sourceNetwork: sourceNetwork,
        city: _selectedCity?.name,
        cityId: _selectedCity?.id,
        department: _selectedDept?.name,
        departmentId: _selectedDept?.id,
        addressLine: _addressCtrl.text,
        latitude: _lat,
        longitude: _lng,
        categoryIds: categoryIds,
        isPublic: true,
        isPhysicalPlace: _isPhysical,
        googlePlaceId: _googlePlaceId,
        useExactPin: _useExactPin,
        linkToExistingSiteId: existingSiteId,
        categoryIsExplicit: categoryIsExplicit,
      );

      final UserSave saved;
      final editSaveId = _editSaveId;
      if (editSaveId != null) {
        saved = await widget.savesRepository.linkSaveToExistingSite(
          saveId: editSaveId,
          existingSiteId: existingSiteId,
          input: input,
        );
      } else {
        saved = await widget.savesRepository.createSave(input);
      }

      if (!mounted) return false;
      ref.invalidate(mySavesProvider);
      ref.invalidate(homeNearbyProvider);
      final uid = ref.read(supabaseClientProvider).auth.currentUser?.id;
      if (uid != null) {
        unawaited(
          ref
              .read(entityCacheStoreProvider)
              .invalidate(CacheKeys.mySavesSummary(uid)),
        );
        unawaited(
          ref
              .read(entityCacheStoreProvider)
              .invalidate(CacheKeys.homeNearby(uid)),
        );
      }
      unawaited(
        invalidateSearchResultCaches(ref.read(entityCacheStoreProvider)),
      );
      unawaited(
        ref
            .read(entityCacheStoreProvider)
            .invalidate(CacheKeys.siteFicha(saved.siteId)),
      );
      ref.invalidate(siteFichaProvider(saved.siteId));

      setState(() => _saving = false);
      final seed = <File>[];
      for (final ph in _pendingPhotos) {
        try {
          final tmp = File(
            '${Directory.systemTemp.path}/chevere_seed_${_photoUuid.v4()}.${ph.ext}',
          );
          await tmp.writeAsBytes(ph.bytes, flush: true);
          seed.add(tmp);
        } catch (_) {}
      }
      await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => SiteReviewEditorPage(
            siteId: saved.siteId,
            siteName: displayName,
            seedPhotos: seed,
            siteIsPublic: true,
            initialIsPublic: reviewIsPublic,
          ),
        ),
      );
      if (!mounted) return true;
      Navigator.pop(context, saved);
      return true;
    } catch (e) {
      if (!mounted) return false;
      setState(() => _saving = false);
      AppToast.error(context, e, logContext: 'link_and_review');
      return false;
    }
  }

  Future<_PendingPhoto> _persistPickedImage(XFile picked) async {
    final bytes = await picked.readAsBytes();
    if (bytes.isEmpty) {
      throw Exception('empty image');
    }
    final rawExt = p.extension(picked.path).replaceFirst('.', '').toLowerCase();
    final ext = (rawExt == 'png' ||
            rawExt == 'webp' ||
            rawExt == 'heic' ||
            rawExt == 'jpg' ||
            rawExt == 'jpeg')
        ? (rawExt == 'jpeg' ? 'jpg' : rawExt)
        : 'jpg';
    return _PendingPhoto(bytes: bytes, ext: ext);
  }

  int get _photoSlotsLeft =>
      SavePolicies.maxPhotosPerSite -
      _existingPhotos.length -
      _pendingPhotos.length;

  Future<bool> _confirmPhotoTerms() async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.loginTerms),
        content: Text(context.l10n.photoTermsBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.actionAcceptContinue),
          ),
        ],
      ),
    );
    return accepted == true;
  }

  Future<void> _captureFromCamera() async {
    if (_saving || _cameraBusy) return;
    if (!await _confirmPhotoTerms() || !mounted) return;
    if (_photoSlotsLeft <= 0) {
      AppToast.show(
        context,
        context.l10n.savePhotoMaxReached(SavePolicies.maxPhotosPerSite),
        error: true,
      );
      return;
    }
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 92,
      maxWidth: 1920,
    );
    if (file == null || !mounted) return;
    try {
      final persisted = await _persistPickedImage(file);
      if (!mounted) return;
      await _applyCameraPhoto(persisted);
    } catch (e, st) {
      ClientDebugLog.reportAsync(
        context: 'save_camera_capture',
        error: e,
        stackTrace: st,
        client: ref.read(supabaseClientProvider),
      );
      if (!mounted) return;
      AppToast.show(context, context.l10n.savePhotoUploadPartialFail, error: true);
    }
  }

  Future<void> _applyCameraPhoto(_PendingPhoto photo) async {
    if (_saving || _cameraBusy) return;
    setState(() {
      _pendingPhotos.add(photo);
      _openExtras.add(_SaveExtra.photo);
    });

    if (_hasFormLocation || !mounted) return;

    setState(() => _cameraBusy = true);
    try {
      final fix =
          await ref.read(deviceLocationProvider).tryQuickFix();
      if (!mounted) return;
      if (fix == null) {
        AppToast.show(context, context.l10n.saveCameraNeedLocation, error: true);
        return;
      }

      setState(() {
        _lat = fix.lat;
        _lng = fix.lng;
        _useExactPin = true;
      });

      unawaited(_enrichLocationFromCoords(
        fix.lat,
        fix.lng,
        showToast: true,
        checkDuplicate: true,
      ));
    } finally {
      if (mounted) setState(() => _cameraBusy = false);
    }
  }

  Future<void> _enrichLocationFromCoords(
    double lat,
    double lng, {
    bool showToast = false,
    bool checkDuplicate = false,
  }) async {
    GeoPlace? place;
    try {
      place = await _placeGeocoder.reverse(lat: lat, lng: lng);
    } catch (_) {}

    if (!mounted) return;

    final suggestedName = _nameFromGeoPlace(place);
    _fillFromPlace(
      name: _nameCtrl.text.trim().isEmpty ? suggestedName : null,
      address: place?.addressLine ?? place?.displayName,
      city: place?.city,
      department: place?.department,
      lat: lat,
      lng: lng,
      googlePlaceId: place?.placeId,
    );
    if (!mounted) return;

    _openNameSectionIfNeeded(name: suggestedName);

    if (checkDuplicate) {
      final linked = await _softCheckDuplicateAfterLocation();
      if (linked || !mounted) return;
    }

    if (showToast && mounted) {
      final city = _cityCtrl.text.trim();
      final name = _nameCtrl.text.trim();
      AppToast.show(
        context,
        city.isNotEmpty && name.isNotEmpty
            ? context.l10n.saveLocationAppliedNamed(name, city)
            : context.l10n.saveLocationApplied,
      );
    }
  }

  Future<void> _ensureExistingPhotosLoaded() async {
    final siteId = _editSiteId;
    if (siteId == null || _existingPhotosLoaded || _loadingExistingPhotos) {
      return;
    }
    setState(() => _loadingExistingPhotos = true);
    try {
      final moderation = ref.read(moderationRepositoryProvider);
      final photos = await moderation.listSitePhotos(siteId);
      final urls = await moderation.signedPhotoUrlsParallel(
        photos.map((ph) => (id: ph.id, storagePath: ph.storagePath)),
      );
      if (!mounted) return;
      setState(() {
        _existingPhotos
          ..clear()
          ..addAll(photos);
        _existingPhotoUrls
          ..clear()
          ..addAll(urls);
        _existingPhotosLoaded = true;
        _loadingExistingPhotos = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingExistingPhotos = false;
        _existingPhotosLoaded = true;
      });
      AppToast.error(context, e, logContext: 'save_existing_photos');
    }
  }

  Future<void> _pickPhoto() async {
    if (!await _confirmPhotoTerms() || !mounted) return;

    if (_photoSlotsLeft <= 0) {
      AppToast.show(
        context,
        context.l10n.savePhotoMaxReached(SavePolicies.maxPhotosPerSite),
        error: true,
      );
      return;
    }

    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 92,
      maxWidth: 1920,
    );
    if (file == null || !mounted) return;
    try {
      final persisted = await _persistPickedImage(file);
      if (!mounted) return;
      setState(() => _pendingPhotos.add(persisted));
    } catch (e, st) {
      ClientDebugLog.reportAsync(
        context: 'save_pick_photo',
        error: e,
        stackTrace: st,
        client: ref.read(supabaseClientProvider),
      );
      if (!mounted) return;
      AppToast.show(context, context.l10n.savePhotoUploadPartialFail, error: true);
    }
  }

  Future<void> _submit() async {
    // Validaciones + anti-dupe ANTES del spinner, para que el diálogo se vea
    // igual de claro que el de «¡Lugar guardado!».
    final lat = _lat;
    final lng = _lng;
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      if (!mounted) return;
      AppToast.show(context, context.l10n.saveNameRequired, error: true);
      return;
    }
    final primaryLink =
        _socialLinks.isNotEmpty ? _socialLinks.first : null;
    final mapsUrl = _mapsCtrl.text.trim();
    final sourceUrl = primaryLink?.url ??
        (GoogleMapsLinkImporter.looksLikeMapsUrl(mapsUrl) ? mapsUrl : null);
    final sourceNetwork = primaryLink?.network ??
        (GoogleMapsLinkImporter.looksLikeMapsUrl(mapsUrl)
            ? 'google_maps'
            : null);

    final categoryIds = _resolvedCategoryIds();
    if (categoryIds.isEmpty) {
      if (!mounted) return;
      if (_categories.isEmpty) {
        setState(() {
          _openExtras.add(_SaveExtra.categories);
          _categoriesUnavailable = true;
        });
        unawaited(_reloadCategories());
        return;
      }
      AppToast.show(context, context.l10n.errorLoadRetry, error: true);
      return;
    }
    if (_selectedCategoryIds.isEmpty) {
      setState(() {
        _selectedCategoryIds.addAll(categoryIds);
        _categoryWasAutoSuggested = true;
      });
    }

    final onlyDefault = categoryIds.every((id) {
      final cat = _categories.where((c) => c.id == id);
      if (cat.isEmpty) return false;
      final c = cat.first;
      return c.slug == CategorySuggester.defaultChildSlug ||
          c.slug == CategorySuggester.defaultParentSlug;
    });
    final categoryIsExplicit =
        _categoriesUserTouched && !onlyDefault;

    final input = SaveDraftInput(
      name: name,
      sourceUrl: sourceUrl,
      sourceNetwork: sourceNetwork,
      city: _selectedCity?.name,
      cityId: _selectedCity?.id,
      department: _selectedDept?.name,
      departmentId: _selectedDept?.id,
      addressLine: _addressCtrl.text,
      latitude: lat,
      longitude: lng,
      categoryIds: categoryIds,
      isPublic: _isPublic && _hasFormLocation,
      isPhysicalPlace: _isPhysical,
      googlePlaceId: _googlePlaceId,
      useExactPin: _useExactPin,
      categoryIsExplicit: categoryIsExplicit,
      clearLocation: _hadStoredCoords && (lat == null || lng == null),
    );

    final editSaveId = _editSaveId;
    final editSiteId = _editSiteId;
    final wantPublic = input.isPublic;

    // Público → privado: validar asociaciones de otros / catálogo.
    if (editSiteId != null && _loadedIsPublic && !wantPublic) {
      try {
        final blockers =
            await widget.savesRepository.loadPrivacyBlockers(editSiteId);
        if (blockers.blocked) {
          if (!mounted) return;
          await _showCannotMakePrivate(blockers);
          return;
        }
      } catch (e) {
        if (!mounted) return;
        AppToast.error(context, e, logContext: 'privacy_blockers');
        return;
      }
    }

    // Anti-dupe: crear o editar hacia/como público.
    final shouldCheckDuplicates = _isPhysical &&
        ((lat != null && lng != null) ||
            (_selectedCity?.name.trim().isNotEmpty ?? false)) &&
        ((editSaveId == null && editSiteId == null) || wantPublic);

    String? linkToExisting;
    var pendingReviewIsPublic = false;
    if (shouldCheckDuplicates) {
      try {
        final dupes = await widget.savesRepository.findPossibleDuplicates(
          name: name,
          city: _selectedCity?.name,
          latitude: lat,
          longitude: lng,
          excludeSiteId: editSiteId,
          googlePlaceId: _googlePlaceId,
        );
        if (dupes.isNotEmpty && mounted) {
          final chosen = await _askDuplicate(
            dupes,
            allowCreateAnyway: true,
          );
          if (chosen == null) return; // seguir con el mío
          if (chosen.action != SameSiteAction.saveAnyway) {
            final siteId = chosen.siteId;
            if (siteId == null) return;
            linkToExisting = siteId;
            pendingReviewIsPublic =
                chosen.action == SameSiteAction.reviewPublic;
          }
        }
      } catch (e) {
        if (!mounted) return;
        AppToast.error(context, e, logContext: 'dupe_check');
        return;
      }
    }

    setState(() {
      _saving = true;
    });
    try {
      String resultSiteId;
      UserSave? saved;
      final linkedToExisting = linkToExisting != null;
      var status = widget.savesRepository.computeStatus(input);

      if (editSaveId != null &&
          editSiteId != null &&
          linkToExisting != null) {
        saved = await widget.savesRepository.linkSaveToExistingSite(
          saveId: editSaveId,
          existingSiteId: linkToExisting,
          input: input,
        );
        resultSiteId = saved.siteId;
        status = saved.status;
      } else if (editSaveId != null && editSiteId != null) {
        saved = await widget.savesRepository.updateSave(
          saveId: editSaveId,
          siteId: editSiteId,
          input: input,
        );
        resultSiteId = saved.siteId;
        status = saved.status;
      } else if (editSiteId != null) {
        // Staff/creador sin save: no se puede "vincular" a otro; solo editar.
        if (linkToExisting != null) {
          if (!mounted) return;
          setState(() => _saving = false);
          await showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.surface,
              title: Text(
                context.l10n.sameSiteTitle,
                style: TextStyle(color: AppColors.foreground),
              ),
              content: Text(
                context.l10n.sameSiteStaffHint,
                style: TextStyle(color: AppColors.muted),
              ),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.l10n.actionDone),
                ),
              ],
            ),
          );
          return;
        }
        await widget.savesRepository.updateSiteWithoutSave(
          siteId: editSiteId,
          input: input,
        );
        resultSiteId = editSiteId;
        status = widget.savesRepository.computeStatus(input);
      } else {
        saved = await widget.savesRepository.createSave(
          SaveDraftInput(
            name: name,
            sourceUrl: input.sourceUrl,
            sourceNetwork: input.sourceNetwork,
            city: input.city,
            cityId: input.cityId,
            department: input.department,
            departmentId: input.departmentId,
            addressLine: input.addressLine,
            latitude: lat,
            longitude: lng,
            categoryIds: input.categoryIds,
            isPublic: input.isPublic,
            isPhysicalPlace: _isPhysical,
            googlePlaceId: _googlePlaceId,
            useExactPin: _useExactPin,
            linkToExistingSiteId: linkToExisting,
            categoryIsExplicit: categoryIsExplicit,
          ),
        );
        resultSiteId = saved.siteId;
        status = saved.status;
      }

      if (_pendingPhotos.isEmpty &&
          _pendingMapImageUrl != null &&
          _pendingMapImageUrl!.isNotEmpty) {
        try {
          final res = await http.get(Uri.parse(_pendingMapImageUrl!));
          if (res.statusCode >= 200 &&
              res.statusCode < 300 &&
              res.bodyBytes.isNotEmpty) {
            _pendingPhotos.add(
              _PendingPhoto(bytes: res.bodyBytes, ext: 'jpg'),
            );
          }
        } catch (_) {}
      }

      if (_pendingPhotos.isNotEmpty && !linkedToExisting) {
        var photoFail = false;
        var knownCount = _existingPhotos.isNotEmpty
            ? _existingPhotos.length
            : await widget.savesRepository.countPhotos(resultSiteId);
        for (final photo in List<_PendingPhoto>.from(_pendingPhotos)) {
          try {
            await widget.savesRepository.uploadPhotoBytes(
              siteId: resultSiteId,
              bytes: photo.bytes,
              fileExtension: photo.ext,
              knownCount: knownCount,
            );
            knownCount += 1;
          } catch (e, st) {
            photoFail = true;
            ClientDebugLog.reportAsync(
              context: 'save_photo_upload',
              error: e,
              stackTrace: st,
              client: ref.read(supabaseClientProvider),
            );
          }
        }
        if (photoFail && mounted) {
          AppToast.show(
            context,
            context.l10n.savePhotoUploadPartialFail,
            error: true,
          );
        }
      }

      // Vincular = no mutar ficha del sitio público (solo contributor + reseña).
      if (!linkedToExisting) {
        try {
          final linksToSave = List<SocialLinkDraft>.from(_socialLinks);
          if (GoogleMapsLinkImporter.looksLikeMapsUrl(mapsUrl) &&
              linksToSave.every((l) => l.url != mapsUrl)) {
            linksToSave.add(
              SocialLinkDraft(url: mapsUrl, network: 'google_maps'),
            );
          }
          await widget.savesRepository.replaceSocialLinks(
            siteId: resultSiteId,
            links: linksToSave,
          );
        } catch (e, st) {
          ClientDebugLog.reportAsync(
            context: 'save_social_links',
            error: e,
            stackTrace: st,
            client: ref.read(supabaseClientProvider),
          );
        }
      }

      if (saved != null && !linkedToExisting) {
        try {
          if (saved.status == SiteStatus.complete) {
            await ref.read(draftReminderServiceProvider).cancelForSave(saved.id);
          } else {
            await ref.read(draftReminderServiceProvider).scheduleForSave(
              saveId: saved.id,
              title: saved.siteName,
              city: saved.city,
              department: saved.department,
              coverStoragePath: saved.coverStoragePath,
            );
          }
        } catch (e, st) {
          ClientDebugLog.reportAsync(
            context: 'save_draft_reminder',
            error: e,
            stackTrace: st,
            client: ref.read(supabaseClientProvider),
          );
        }
      }

      if (!mounted) return;
      if (!_isStaffSiteEdit) {
        ref.invalidate(mySavesProvider);
        final uid = ref.read(supabaseClientProvider).auth.currentUser?.id;
        if (uid != null) {
          unawaited(
            ref
                .read(entityCacheStoreProvider)
                .invalidate(CacheKeys.mySavesSummary(uid)),
          );
        }
      }
      unawaited(
        invalidateSearchResultCaches(ref.read(entityCacheStoreProvider)),
      );
      // Populares cerca no debe quedar con portada vieja / sitio propio duplicado.
      ref.invalidate(homeNearbyProvider);
      final uidNearby = ref.read(supabaseClientProvider).auth.currentUser?.id;
      if (uidNearby != null) {
        unawaited(
          ref
              .read(entityCacheStoreProvider)
              .invalidate(CacheKeys.homeNearby(uidNearby)),
        );
      }
      if (resultSiteId.isNotEmpty) {
        unawaited(
          ref
              .read(entityCacheStoreProvider)
              .invalidate(CacheKeys.siteFicha(resultSiteId)),
        );
        ref.invalidate(siteFichaProvider(resultSiteId));
      }
      final l10n = context.l10n;
      final isPublicResult = saved?.isPublic ??
          (input.isPhysicalPlace && input.isPublic && _hasFormLocation);
      if (linkedToExisting) {
        setState(() => _saving = false);
        final seed = <File>[];
        for (final ph in _pendingPhotos) {
          try {
            final tmp = File(
              '${Directory.systemTemp.path}/chevere_seed_${_photoUuid.v4()}.${ph.ext}',
            );
            await tmp.writeAsBytes(ph.bytes, flush: true);
            seed.add(tmp);
          } catch (_) {}
        }
        await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => SiteReviewEditorPage(
              siteId: resultSiteId,
              siteName: name,
              seedPhotos: seed,
              siteIsPublic: true,
              initialIsPublic: pendingReviewIsPublic,
            ),
          ),
        );
      } else {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text(
              _isEditing
                  ? l10n.saveSuccessTitleUpdate
                  : l10n.saveSuccessTitleCreate,
              style: TextStyle(color: AppColors.foreground),
            ),
            content: Text(
              [
                if (_isStaffSiteEdit)
                  l10n.saveSuccessStaffBody
                else if (status == SiteStatus.complete)
                  l10n.saveSuccessCompleteBody
                else if (_isPhysical && (lat == null || lng == null))
                  l10n.saveNeedsMapPoint
                else
                  l10n.saveStatusAfterSave(status.label(l10n)),
                if (!_isStaffSiteEdit && !isPublicResult)
                  l10n.saveSuccessPrivateSuffix,
              ].join(),
              style: TextStyle(color: AppColors.muted),
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.actionDone),
              ),
            ],
          ),
        );
      }
      if (!mounted) return;
      Navigator.pop(context, saved ?? resultSiteId);
    } catch (e, st) {
      if (!mounted) return;
      ClientDebugLog.reportAsync(
        context: 'save_place_submit',
        error: e,
        stackTrace: st,
        client: ref.read(supabaseClientProvider),
      );
      setState(() => _saving = false);
      AppToast.show(context, context.l10n.errorProblemToast, error: true);
    }
  }

  /// Acción elegida, o null = seguir con el mío (no guardar / no vincular).
  /// [allowCreateAnyway] solo en Guardar (no en soft-check de Maps/pegar).
  Future<SameSitePick?> _askDuplicate(
    List<PossibleDuplicate> matches, {
    required bool allowCreateAnyway,
  }) {
    if (matches.isEmpty) return Future<SameSitePick?>.value(null);
    return Navigator.of(context).push<SameSitePick>(
      MaterialPageRoute(
        builder: (_) => SameSitePickerPage(
          matches: matches,
          allowCreateAnyway: allowCreateAnyway,
        ),
      ),
    );
  }

  Future<void> _showCannotMakePrivate(SitePrivacyBlockers blockers) {
    final l10n = context.l10n;
    final reason = blockers.isCatalog
        ? l10n.privacyBlockCatalog
        : l10n.privacyBlockOthers;
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        key: WidgetKeys.privacyBlockDialog,
        backgroundColor: AppColors.surface,
        title: Text(
          l10n.privacyBlockTitle,
          style: TextStyle(color: AppColors.foreground),
        ),
        content: Text(
          reason,
          style: TextStyle(color: AppColors.muted),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.actionDone),
          ),
        ],
      ),
    );
  }

  Widget _infoTip(String message) {
    return Tooltip(
      message: message,
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 8),
      waitDuration: Duration.zero,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(Icons.info_outline, size: 20, color: AppColors.muted),
      ),
    );
  }

  Widget _sectionCard({
    Key? key,
    required String title,
    required String info,
    required List<Widget> children,
    bool required = false,
  }) {
    return Padding(
      key: key,
      padding: const EdgeInsets.only(bottom: 12),
      child: AppFormCard(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: AppSectionLabel(
                    text: title,
                    required: required,
                    bottom: 0,
                  ),
                ),
                _infoTip(info),
              ],
            ),
            SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  InputDecoration _dec(String label, {String? helper, String? hint}) {
    return InputDecoration(
      labelText: hint == null ? label : null,
      hintText: hint,
      filled: true,
      fillColor: AppColors.surfaceElevated,
      helperText: helper,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
    );
  }

  String _extraTitle(AppLocalizations l10n, _SaveExtra extra) {
    return switch (extra) {
      _SaveExtra.name => l10n.saveExtraNameVisibility,
      _SaveExtra.details => l10n.saveExtraDetails,
      _SaveExtra.links => l10n.saveLinksSection,
      _SaveExtra.categories => l10n.saveCategoriesSection,
      _SaveExtra.photo => l10n.saveExtraPhoto,
    };
  }

  Widget _addExtraChips(AppLocalizations l10n) {
    final hidden = _SaveExtra.values
        .where((e) => !_openExtras.contains(e))
        .toList();
    if (hidden.isEmpty) return SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionLabel(text: l10n.saveAddSection, bottom: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final extra in hidden)
                AppSelectChip(
                  key: switch (extra) {
                    _SaveExtra.name => WidgetKeys.saveExtraName,
                    _SaveExtra.details => WidgetKeys.saveExtraDetails,
                    _SaveExtra.links => WidgetKeys.saveExtraLinks,
                    _SaveExtra.categories => WidgetKeys.saveExtraCategories,
                    _SaveExtra.photo => WidgetKeys.saveExtraPhoto,
                  },
                  label: _extraTitle(l10n, extra),
                  selected: false,
                  icon: Icons.add,
                  onTap: () {
                    if (_saving) return;
                    setState(() => _openExtras.add(extra));
                    if (extra == _SaveExtra.photo) {
                      unawaited(_ensureExistingPhotosLoaded());
                    }
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mapPreview(AppLocalizations l10n) {
    final hasPin = _lat != null && _lng != null;
    return Material(
      color: AppColors.surfaceElevated,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        key: WidgetKeys.saveOpenMap,
        onTap: _saving ? null : _openMap,
        child: SizedBox(
          height: 112,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              SiteLookCover(
                imageUrl: _pendingMapImageUrl,
                categoryNames: [
                  for (final c in _selectedCategories) c.nameEs,
                ],
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    hasPin
                        ? l10n.saveLocationPointReady
                        : l10n.saveLocationPickMap,
                    key: hasPin ? WidgetKeys.saveHasPin : WidgetKeys.saveNoPin,
                    style: TextStyle(
                      color: AppColors.foreground,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _locationLinkField(AppLocalizations l10n) {
    return TextField(
      key: WidgetKeys.saveMapsField,
      controller: _mapsCtrl,
      decoration: _dec(
        l10n.saveMapsPasteLabel,
        hint: l10n.saveLocationSearchHint,
        helper: l10n.saveMapsPasteHelper,
      ).copyWith(
        suffixIcon: FieldActionIcon(
          icon: Icons.content_paste,
          tooltip: l10n.actionPaste,
          loading: _importingMaps,
          onPressed: (_saving || _importingMaps) ? null : _pasteMapsAndImport,
        ),
      ),
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) {
        if (!_saving && !_importingMaps) {
          _importFromGoogleMaps();
        }
      },
    );
  }

  Widget _locationCameraTab(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.saveCameraHint,
          style: TextStyle(color: AppColors.muted, fontSize: 13),
        ),
        SizedBox(height: 12),
        FilledButton.icon(
          key: WidgetKeys.saveCameraTake,
          onPressed: (_saving || _cameraBusy) ? null : _captureFromCamera,
          icon: Icon(Icons.photo_camera_outlined),
          label: Text(l10n.saveCameraTake),
        ),
        if (_cameraBusy) ...[
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 10),
              Text(
                l10n.saveCameraLocating,
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _exactPinSwitch(AppLocalizations l10n) {
    return SwitchListTile(
      key: WidgetKeys.saveExactPinSwitch,
      contentPadding: EdgeInsets.zero,
      title: Text(l10n.saveExactPinSwitch),
      subtitle: Text(
        _useExactPin
            ? l10n.saveExactPinMapsPin
            : l10n.saveExactPinMapsPlace,
      ),
      secondary: _infoTip(l10n.saveInfoExactPin),
      value: _useExactPin,
      onChanged: _saving
          ? null
          : (v) async {
              if (v && (_lat == null || _lng == null)) {
                await _openMap();
                if (!mounted) return;
                if (_lat == null || _lng == null) return;
              }
              setState(() => _useExactPin = v);
            },
    );
  }

  Widget _locationSection(AppLocalizations l10n) {
    if (_isEditing) {
      return _sectionCard(
        title: l10n.saveLocationSection,
        info: l10n.saveInfoLocation,
        children: [
          _locationLinkField(l10n),
          SizedBox(height: 10),
          _mapPreview(l10n),
          _exactPinSwitch(l10n),
        ],
      );
    }

    final tabs = _locationTabCtrl!;
    return _sectionCard(
      title: l10n.saveLocationSection,
      info: l10n.saveInfoLocation,
      children: [
        TabBar(
          controller: tabs,
          tabs: [
            Tab(
              key: WidgetKeys.saveLocationTabMap,
              text: l10n.saveLocationMap,
            ),
            Tab(
              key: WidgetKeys.saveLocationTabLink,
              text: l10n.saveLocationGoogleLink,
            ),
            Tab(
              key: WidgetKeys.saveLocationTabCamera,
              text: l10n.saveLocationCamera,
            ),
          ],
        ),
        SizedBox(height: 10),
        switch (tabs.index) {
          0 => _mapPreview(l10n),
          1 => _locationLinkField(l10n),
          _ => _locationCameraTab(l10n),
        },
        _exactPinSwitch(l10n),
      ],
    );
  }

  Widget _nameAndVisibilitySection(AppLocalizations l10n) {
    final canPublish = _isPhysical && _hasFormLocation;
    final isPublicOn = _isPublic && canPublish;
    final publicColor =
        isPublicOn ? AppColors.success : AppColors.purple;
    final publicSwitchTip = !canPublish
        ? (!_isPhysical
            ? l10n.savePublicNonPhysical
            : l10n.savePublicNeedLocation)
        : (isPublicOn ? l10n.savePublicVisible : l10n.saveMakePublic);

    return _sectionCard(
      title: l10n.saveNameSection,
      info: l10n.saveInfoName,
      required: true,
      children: [
        TextField(
          key: WidgetKeys.saveNameField,
          controller: _nameCtrl,
          decoration: _dec(
            l10n.savePlaceName,
            hint: l10n.savePlaceName,
          ),
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => setState(() {}),
          onEditingComplete: () {
            _maybeSuggestCategories();
            FocusScope.of(context).unfocus();
          },
          onSubmitted: (_) => _maybeSuggestCategories(),
        ),
        SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _visibilityToggle(
                icon: Icons.place_outlined,
                iconColor: AppColors.muted,
                label: l10n.savePhysicalLabel,
                info: l10n.saveInfoPhysical,
                switchKey: WidgetKeys.savePhysicalSwitch,
                value: _isPhysical,
                onChanged: (v) => setState(() {
                  _isPhysical = v;
                  if (!v) _isPublic = false;
                }),
              ),
            ),
            Container(
              width: 1,
              height: 32,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: AppColors.border,
            ),
            Expanded(
              child: Tooltip(
                message: publicSwitchTip,
                child: _visibilityToggle(
                  icon: isPublicOn ? Icons.public : Icons.lock_outline,
                  iconColor: publicColor,
                  label: l10n.savePublicSection,
                  info: l10n.saveInfoPublic,
                  switchKey: WidgetKeys.savePublicSwitch,
                  value: isPublicOn,
                  onChanged: canPublish
                      ? (v) => setState(() => _isPublic = v)
                      : null,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _visibilityToggle({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String info,
    required Key switchKey,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        SizedBox(width: 4),
        Flexible(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.foreground,
                    ),
                  ),
                ),
                _infoTip(info),
              ],
            ),
          ),
        ),
        Switch(
          key: switchKey,
          value: value,
          onChanged: onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }

  Widget _detailsSection(AppLocalizations l10n) {
    return _sectionCard(
      title: l10n.saveExtraDetails,
      info: l10n.saveInfoDetails,
      children: [
        GeoTypeaheadField<GeoDepartment>(
          controller: _deptCtrl,
          focusNode: _deptFocus,
          items: _geoCatalog?.activeDepartments ?? const [],
          labelOf: (d) => d.name,
          selected: _selectedDept,
          enabled: _geoCatalog != null,
          decoration: _dec(
            l10n.saveDepartment,
            helper: _geoCatalog == null ? l10n.saveGeoCatalogMissing : null,
          ),
          onSelected: (d) => setState(() {
            _setDepartment(d);
          }),
        ),
        SizedBox(height: 10),
        GeoTypeaheadField<GeoCity>(
          controller: _cityCtrl,
          focusNode: _cityFocus,
          items: _selectedDept == null
              ? const []
              : (_geoCatalog?.citiesIn(_selectedDept!.id) ?? const []),
          labelOf: (c) => c.name,
          selected: _selectedCity,
          enabled: _geoCatalog != null && _selectedDept != null,
          decoration: _dec(l10n.saveCity),
          onSelected: (c) => setState(() => _setCity(c)),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _addressCtrl,
          decoration: _dec(l10n.saveAddress),
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _linksSection(AppLocalizations l10n) {
    return _sectionCard(
      key: WidgetKeys.saveLinksSection,
      title: l10n.saveLinksSection,
      info: l10n.saveInfoLinks,
      children: [
        TextField(
          controller: _socialCtrl,
          decoration: _dec(l10n.saveSocialPaste).copyWith(
            suffixIcon: FieldActionIcon(
              icon: Icons.content_paste,
              tooltip: l10n.actionPaste,
              loading: _addingSocial,
              onPressed: (_saving || _addingSocial) ? null : _pasteSocialAndAdd,
            ),
          ),
          keyboardType: TextInputType.url,
          onSubmitted: (v) async {
            await _addSocialLink(v);
            _socialCtrl.clear();
          },
        ),
        if (_socialLinks.isNotEmpty) ...[
          SizedBox(height: 8),
          ..._socialLinks.map(
            (d) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SocialLinkPreviewCard(
                draft: d,
                loading: _addingSocial &&
                    d.title == null &&
                    d.imageUrl == null,
                onRemove: _saving
                    ? null
                    : () => setState(() => _socialLinks.remove(d)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _categoriesSection(AppLocalizations l10n) {
    return _sectionCard(
      title: l10n.saveCategoriesSection,
      info: l10n.saveInfoCategories,
      children: [
        if (_categoriesUnavailable || _categories.isEmpty)
          AppRetryCallout(
            onRetry: _reloadCategories,
            padding: const EdgeInsets.only(bottom: 8),
          ),
        if (_categoryWasAutoSuggested && _selectedCategories.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              _selectedCategories.any(
                    (c) =>
                        c.slug == CategorySuggester.defaultChildSlug ||
                        c.slug == CategorySuggester.defaultParentSlug,
                  )
                  ? l10n.saveCategoryFallbackOtros
                  : l10n.saveCategorySuggested,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        if (_selectedCategories.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _selectedCategories.map((c) {
              final parent = _parentName(c);
              final label =
                  parent.isEmpty ? c.nameEs : '$parent › ${c.nameEs}';
              return InputChip(
                label: Text(
                  c.ageRestricted ? '$label (+18)' : label,
                ),
                onDeleted: _saving
                    ? null
                    : () => setState(() {
                          _markCategoriesTouched();
                          _selectedCategoryIds.remove(c.id);
                        }),
              );
            }).toList(),
          ),
        SizedBox(height: 8),
        TextField(
          controller: _categorySearchCtrl,
          decoration: InputDecoration(
            hintText: l10n.saveCategoryHint,
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
            isDense: true,
            suffixIcon: IconButton(
              tooltip: l10n.saveCategoryTree,
              onPressed: _saving ? null : _openCategoryTree,
              icon: Icon(Icons.account_tree_outlined),
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
        if (_categorySearchCtrl.text.trim().isNotEmpty) ...[
          SizedBox(height: 4),
          ..._filteredCategories.map((c) {
            final parent = _parentName(c);
            final label =
                parent.isEmpty ? c.nameEs : '$parent › ${c.nameEs}';
            final selected = _selectedCategoryIds.contains(c.id);
            return CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                c.ageRestricted ? '$label (+18)' : label,
              ),
              value: selected,
              onChanged: (v) {
                setState(() {
                  _markCategoriesTouched();
                  if (v == true) {
                    _selectedCategoryIds.add(c.id);
                  } else {
                    _selectedCategoryIds.remove(c.id);
                  }
                });
              },
            );
          }),
          if (_filteredCategories.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(l10n.saveCategoryNone),
            ),
        ],
      ],
    );
  }

  Widget _photoThumb({
    required Widget child,
    required VoidCallback onRemove,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(width: 72, height: 72, child: child),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: Material(
            color: AppColors.surfaceElevated,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _saving ? null : onRemove,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.close, size: 16, color: AppColors.foreground),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _photoSection(AppLocalizations l10n) {
    if (_editSiteId != null && !_existingPhotosLoaded && !_loadingExistingPhotos) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_ensureExistingPhotosLoaded());
      });
    }
    final slotsLeft = SavePolicies.maxPhotosPerSite -
        _existingPhotos.length -
        _pendingPhotos.length;
    return _sectionCard(
      title: l10n.saveExtraPhoto,
      info: l10n.saveInfoPhoto,
      children: [
        if (_loadingExistingPhotos)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final ph in _existingPhotos)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: _existingPhotoUrls[ph.id] != null
                      ? AppNetworkImage(
                          url: _existingPhotoUrls[ph.id]!,
                          width: 72,
                          height: 72,
                          cacheKey: ph.id,
                        )
                      : ColoredBox(
                          color: AppColors.surfaceElevated,
                          child: Icon(
                            Icons.image_outlined,
                            color: AppColors.muted,
                          ),
                        ),
                ),
              ),
            for (var i = 0; i < _pendingPhotos.length; i++)
              _photoThumb(
                onRemove: () {
                  final idx = i;
                  setState(() => _pendingPhotos.removeAt(idx));
                },
                child: Image.memory(
                  _pendingPhotos[i].bytes,
                  fit: BoxFit.cover,
                  width: 72,
                  height: 72,
                  errorBuilder: (_, _, _) => ColoredBox(
                    color: AppColors.surfaceElevated,
                    child: Icon(Icons.broken_image_outlined, color: AppColors.muted),
                  ),
                ),
              ),
            if (slotsLeft > 0)
              OutlinedButton.icon(
                onPressed: _saving ? null : _pickPhoto,
                icon: Icon(Icons.add_photo_alternate_outlined),
                label: Text(l10n.saveAddPhoto),
              ),
          ],
        ),
      ],
    );
  }

  Widget _extraSection(AppLocalizations l10n, _SaveExtra extra) {
    return switch (extra) {
      _SaveExtra.name => _nameAndVisibilitySection(l10n),
      _SaveExtra.details => _detailsSection(l10n),
      _SaveExtra.links => _linksSection(l10n),
      _SaveExtra.categories => _categoriesSection(l10n),
      _SaveExtra.photo => _photoSection(l10n),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final nameOk = _nameCtrl.text.trim().isNotEmpty;
    return Scaffold(
      key: WidgetKeys.savePlacePage,
      appBar: AppBar(
        title: Text(
          _isEditing ? l10n.savePlaceEditTitle : l10n.savePlaceTitle,
        ),
      ),
      body: _loadingCats
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              children: [
                _locationSection(l10n),
                for (final extra in _SaveExtra.values)
                  if (_openExtras.contains(extra)) _extraSection(l10n, extra),
                _addExtraChips(l10n),
              ],
            ),
      bottomNavigationBar: _loadingCats
          ? null
          : Material(
              color: AppColors.surface,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilledButton(
                        key: WidgetKeys.saveSubmit,
                        onPressed: (_saving || !nameOk) ? null : _submit,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                        ),
                        child: _saving
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                _isEditing
                                    ? l10n.savePlaceSubmitEdit
                                    : l10n.savePlaceSubmit,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
