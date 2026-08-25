import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../core/cache/cache_ttl.dart';
import '../../../core/config/env.dart';
import '../../../core/di/providers.dart';
import '../../../core/testing/widget_keys.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_form_card.dart';
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

enum _SaveExtra { details, links, categories, photo, physical }

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

class _SavePlacePageState extends ConsumerState<SavePlacePage> {
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
  bool _submitFailed = false;
  bool _importingMaps = false;
  bool _addingSocial = false;
  /// true = pegar enlace Google Maps; false = mapa interactivo.
  final Set<_SaveExtra> _openExtras = {};
  File? _pendingPhoto;
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

  bool get _isEditing => _editSaveId != null || _editSiteId != null;
  bool get _isStaffSiteEdit =>
      _editSaveId == null && _editSiteId != null;

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
    final parsed = ShareParser.parse(widget.initialSharedText);
    if (parsed.url != null) {
      if (GoogleMapsLinkImporter.looksLikeMapsUrl(parsed.url)) {
        _mapsCtrl.text = parsed.url!;
      } else {
        _socialCtrl.text = parsed.url!;
      }
    }
    if (parsed.suggestedName != null) _nameCtrl.text = parsed.suggestedName!;
    if (widget.initialSharedText?.trim().isNotEmpty ?? false) {
      _openExtras.add(_SaveExtra.links);
    }
    _bootstrapForm();
  }

  Future<void> _bootstrapForm() async {
    try {
      final catsFuture = ref.read(categoriesProvider.future);
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
        _categories = cats.where((c) => c.isActive).toList();
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
      setState(() => _loadingCats = false);
      AppToast.error(context, e, logContext: 'save_place_bootstrap');
    }
  }

  @override
  void dispose() {
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
    });
    if (!_isEditing) _maybeSuggestCategories(force: true);
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
    setState(() => _socialLinks.add(draft));
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
    // Refetch por si el form quedó sin datos o el seed se aplicó después.
    if (_categories.isEmpty) {
      try {
        final cats = await ref.read(categoriesProvider.future);
        if (!mounted) return;
        setState(() {
          _categories = cats.where((c) => c.isActive).toList();
        });
      } catch (e) {
        if (!mounted) return;
        AppToast.error(context, e, logContext: 'categories');
        return;
      }
    }

    if (_categories.isEmpty) {
      // Reintento forzado si el seed se aplicó después del primer fetch cacheado.
      ref.invalidate(categoriesProvider);
      try {
        final cats = await ref.read(categoriesProvider.future);
        if (!mounted) return;
        setState(() {
          _categories = cats.where((c) => c.isActive).toList();
        });
      } catch (_) {}
    }

    if (_categories.isEmpty) {
      if (!mounted) return;
      AppToast.show(
        context,
        'No hay categorías. Aplica el seed SQL (migración 2 y 10) en Supabase.',
        error: true,
      );
      return;
    }

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
              style: const TextStyle(color: AppColors.foreground),
            ),
            content: Text(
              context.l10n.sameSiteStaffHint,
              style: const TextStyle(color: AppColors.muted),
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
      final uid = ref.read(supabaseClientProvider).auth.currentUser?.id;
      if (uid != null) {
        unawaited(
          ref
              .read(entityCacheStoreProvider)
              .invalidate(CacheKeys.mySavesSummary(uid)),
        );
      }
      unawaited(
        ref
            .read(entityCacheStoreProvider)
            .invalidate(CacheKeys.siteFicha(saved.siteId)),
      );
      ref.invalidate(siteFichaProvider(saved.siteId));

      setState(() => _saving = false);
      final seed = <File>[
        ?_pendingPhoto,
      ];
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

  Future<void> _pickPhoto() async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.loginTerms),
        content: const Text(
          'Al subir una foto confirmas que cumple los Términos de Uso de '
          'Chevere Plan (turismo, gastronomía y planes de ocio; sin contenido '
          'sexual, ilegal o de acoso).',
        ),
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
    if (accepted != true) return;

    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 92,
      maxWidth: 2560,
    );
    if (file == null) return;
    setState(() => _pendingPhoto = File(file.path));
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
      AppToast.show(
        context,
        'No hay categorías en la base. Aplica el seed / reseed de categorías.',
        error: true,
      );
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
      _submitFailed = false;
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
                style: const TextStyle(color: AppColors.foreground),
              ),
              content: Text(
                context.l10n.sameSiteStaffHint,
                style: const TextStyle(color: AppColors.muted),
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

      if (_pendingPhoto == null &&
          _pendingMapImageUrl != null &&
          _pendingMapImageUrl!.isNotEmpty) {
        try {
          final res = await http.get(Uri.parse(_pendingMapImageUrl!));
          if (res.statusCode >= 200 && res.statusCode < 300) {
            final tmp = File(
              '${Directory.systemTemp.path}/chevere_map_${DateTime.now().millisecondsSinceEpoch}.jpg',
            );
            await tmp.writeAsBytes(res.bodyBytes);
            _pendingPhoto = tmp;
          }
        } catch (_) {}
      }

      if (_pendingPhoto != null && !linkedToExisting) {
        try {
          await widget.savesRepository.uploadPhoto(
            siteId: resultSiteId,
            file: _pendingPhoto!,
          );
        } catch (e) {
          if (!mounted) return;
          AppToast.show(
            context,
            'Lugar guardado, pero la foto no se subió. Puedes añadirla después.',
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
        } catch (_) {
          // Tabla puede no existir aún si no aplicaron migración 12.
        }
      }

      if (saved != null && !linkedToExisting) {
        if (saved.status == SiteStatus.complete) {
          await ref.read(draftReminderServiceProvider).cancelForSave(saved.id);
        } else {
          await ref.read(draftReminderServiceProvider).scheduleForSave(
            saveId: saved.id,
            title: saved.siteName,
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
        final seed = <File>[
          ?_pendingPhoto,
        ];
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
              _isEditing ? '¡Actualizado!' : '¡Lugar guardado!',
              style: const TextStyle(color: AppColors.foreground),
            ),
            content: Text(
              [
                if (_isStaffSiteEdit)
                  'Cambios del sitio guardados.'
                else if (status == SiteStatus.complete)
                  'Quedó completo en tu lista.'
                else if (_isPhysical && (lat == null || lng == null))
                  l10n.saveNeedsMapPoint
                else
                  l10n.saveStatusAfterSave(status.label(l10n)),
                if (!_isStaffSiteEdit && !isPublicResult)
                  ' Privado por defecto.',
              ].join(),
              style: const TextStyle(color: AppColors.muted),
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
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _submitFailed = true;
      });
      AppToast.error(context, e, logContext: 'save_place_submit');
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
          style: const TextStyle(color: AppColors.foreground),
        ),
        content: Text(
          reason,
          style: const TextStyle(color: AppColors.muted),
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
            const SizedBox(height: 10),
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
        borderSide: const BorderSide(color: AppColors.border),
      ),
    );
  }

  String _extraTitle(AppLocalizations l10n, _SaveExtra extra) {
    return switch (extra) {
      _SaveExtra.details => l10n.saveExtraDetails,
      _SaveExtra.links => l10n.saveLinksSection,
      _SaveExtra.categories => l10n.saveCategoriesSection,
      _SaveExtra.photo => l10n.saveExtraPhoto,
      _SaveExtra.physical => l10n.saveExtraPhysical,
    };
  }

  Widget _addExtraChips(AppLocalizations l10n) {
    final hidden = _SaveExtra.values
        .where((e) => !_openExtras.contains(e))
        .toList();
    if (hidden.isEmpty) return const SizedBox.shrink();
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
                    _SaveExtra.details => WidgetKeys.saveExtraDetails,
                    _SaveExtra.links => WidgetKeys.saveExtraLinks,
                    _SaveExtra.categories => WidgetKeys.saveExtraCategories,
                    _SaveExtra.photo => WidgetKeys.saveExtraPhoto,
                    _SaveExtra.physical => WidgetKeys.saveExtraPhysical,
                  },
                  label: _extraTitle(l10n, extra),
                  selected: false,
                  icon: Icons.add,
                  onTap: () {
                    if (_saving) return;
                    setState(() => _openExtras.add(extra));
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _locationSection(AppLocalizations l10n) {
    final hasPin = _lat != null && _lng != null;
    return _sectionCard(
      title: l10n.saveLocationSection,
      info: l10n.saveInfoLocation,
      children: [
        TextField(
          key: WidgetKeys.saveMapsField,
          controller: _mapsCtrl,
          decoration: _dec(
            l10n.saveMapsPasteLabel,
            hint: l10n.saveLocationSearchHint,
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
        ),
        const SizedBox(height: 10),
        Material(
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
                        key: hasPin
                            ? WidgetKeys.saveHasPin
                            : WidgetKeys.saveNoPin,
                        style: const TextStyle(
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
        ),
        SwitchListTile(
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
        ),
      ],
    );
  }

  Widget _nameSection(AppLocalizations l10n) {
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
      ],
    );
  }

  Widget _publicSection(AppLocalizations l10n) {
    final canPublish = _isPhysical && _hasFormLocation;
    final isOn = _isPublic && canPublish;
    final iconColor = isOn ? AppColors.success : AppColors.purple;
    return _sectionCard(
      title: l10n.savePublicSection,
      info: l10n.saveInfoPublic,
      children: [
        Row(
          children: [
            Tooltip(
              message: !canPublish
                  ? (!_isPhysical
                      ? l10n.savePublicNonPhysical
                      : l10n.savePublicNeedLocation)
                  : (isOn ? l10n.savePublicVisible : l10n.saveMakePublic),
              child: Icon(
                isOn ? Icons.public : Icons.lock_outline,
                color: iconColor,
                size: 22,
              ),
            ),
            const Spacer(),
            Switch(
              key: WidgetKeys.savePublicSwitch,
              value: isOn,
              onChanged: canPublish
                  ? (v) => setState(() => _isPublic = v)
                  : null,
            ),
          ],
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
        const SizedBox(height: 10),
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
        const SizedBox(height: 10),
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
          const SizedBox(height: 8),
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
        const SizedBox(height: 8),
        TextField(
          controller: _categorySearchCtrl,
          decoration: InputDecoration(
            hintText: l10n.saveCategoryHint,
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(),
            isDense: true,
            suffixIcon: IconButton(
              tooltip: l10n.saveCategoryTree,
              onPressed: _saving ? null : _openCategoryTree,
              icon: const Icon(Icons.account_tree_outlined),
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
        if (_categorySearchCtrl.text.trim().isNotEmpty) ...[
          const SizedBox(height: 4),
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

  Widget _photoSection(AppLocalizations l10n) {
    return _sectionCard(
      title: l10n.saveExtraPhoto,
      info: l10n.saveInfoPhoto,
      children: [
        OutlinedButton.icon(
          onPressed: _saving ? null : _pickPhoto,
          icon: const Icon(Icons.photo_outlined),
          label: Text(
            _pendingPhoto == null ? l10n.saveAddPhoto : l10n.savePhotoReady,
          ),
        ),
      ],
    );
  }

  Widget _physicalSection(AppLocalizations l10n) {
    return _sectionCard(
      title: l10n.saveExtraPhysical,
      info: l10n.saveInfoPhysical,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.saveIsPhysical),
          value: _isPhysical,
          onChanged: (v) => setState(() {
            _isPhysical = v;
            if (!v) _isPublic = false;
          }),
        ),
      ],
    );
  }

  Widget _extraSection(AppLocalizations l10n, _SaveExtra extra) {
    return switch (extra) {
      _SaveExtra.details => _detailsSection(l10n),
      _SaveExtra.links => _linksSection(l10n),
      _SaveExtra.categories => _categoriesSection(l10n),
      _SaveExtra.photo => _photoSection(l10n),
      _SaveExtra.physical => _physicalSection(l10n),
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
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              children: [
                _locationSection(l10n),
                _nameSection(l10n),
                _publicSection(l10n),
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
                      if (_submitFailed)
                        AppRetryCallout(
                          onRetry: _submit,
                          padding: const EdgeInsets.only(bottom: 8),
                        ),
                      FilledButton(
                        key: WidgetKeys.saveSubmit,
                        onPressed: (_saving || !nameOk) ? null : _submit,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                        ),
                        child: _saving
                            ? const SizedBox(
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
