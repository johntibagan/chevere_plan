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
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/field_action_icon.dart';
import '../../admin/data/admin_models.dart';
import '../../geo/data/geo_models.dart';
import '../../geo/domain/geo_fuzzy.dart';
import '../../geo/presentation/geo_typeahead_field.dart';
import '../data/geo_place.dart';
import '../data/google_maps_link_importer.dart';
import '../data/google_places_client.dart';
import '../data/place_geocoder.dart';
import '../data/save_models.dart';
import '../data/saves_repository.dart';
import '../data/share_parser.dart';
import '../data/social_link_models.dart';
import '../data/social_place_extractor.dart';
import '../domain/category_suggester.dart';
import '../domain/save_policies.dart';
import 'category_picker_sheet.dart';
import 'location_picker_page.dart';
import 'site_status_l10n.dart';
import 'social_link_preview_card.dart';

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

  List<Category> _categories = [];
  final Set<String> _selectedCategoryIds = {};
  bool _isPublic = false;
  bool _isPhysical = true;
  bool _loadingCats = true;
  bool _saving = false;
  bool _importingMaps = false;
  bool _addingSocial = false;
  /// true = pegar enlace Google Maps; false = mapa interactivo.
  bool _useGoogleLink = false;
  bool _locationDetailsExpanded = false;
  int _locationPanelEpoch = 0;
  File? _pendingPhoto;
  String? _pendingMapImageUrl;
  String? _editSaveId;
  String? _editSiteId;
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
        _useGoogleLink = true;
      } else {
        _socialCtrl.text = parsed.url!;
      }
    }
    if (parsed.suggestedName != null) _nameCtrl.text = parsed.suggestedName!;
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
          _isPhysical = s.isPhysicalPlace;
          _lat = data.latitude;
          _lng = data.longitude;
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
          _isPhysical = data.isPhysicalPlace;
          _lat = data.latitude;
          _lng = data.longitude;
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
      if (staticMapUrl != null && staticMapUrl.isNotEmpty) {
        _pendingMapImageUrl = staticMapUrl;
      }
      _locationDetailsExpanded = true;
      _locationPanelEpoch++;
    });
    if (!_isEditing) _maybeSuggestCategories(force: true);
  }

  Future<void> _importFromGoogleMaps() async {
    final text = _mapsCtrl.text.trim();
    if (text.isEmpty) {
      AppToast.show(context, context.l10n.saveMapsNeedLink, error: true);
      return;
    }
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
      );
      if (!mounted) return;
      AppToast.show(
        context,
        !result.hasCoords
            ? (Env.hasGoogleMapsKey
                ? context.l10n.saveMapsNeedExactPin
                : context.l10n.saveMapsNeedGoogleKey)
            : !result.hasExactPin
                ? context.l10n.saveMapsApproxPin
                : (_cityCtrl.text.trim().isNotEmpty
                    ? context.l10n.saveLocationAppliedNamed(
                        _nameCtrl.text.trim(),
                        _cityCtrl.text.trim(),
                      )
                    : context.l10n.saveMapsNeedCity),
        error: !result.hasCoords,
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
      name: place.name,
      city: place.city,
      department: place.department,
      address: place.addressLine ?? place.displayName,
      lat: place.lat,
      lng: place.lng,
    );
    if (mounted) {
      AppToast.show(context, context.l10n.saveLocationApplied);
    }
  }

  String get _locationSummary {
    final name = _nameCtrl.text.trim();
    final parts = <String>[
      if (name.isNotEmpty) name else 'Sin nombre',
      if (_selectedDept != null) _selectedDept!.name,
      if (_selectedCity != null) _selectedCity!.name,
      if (_addressCtrl.text.trim().isNotEmpty) _addressCtrl.text.trim(),
      if (_lat != null && _lng != null) 'Punto en mapa',
    ];
    return parts.join(' · ');
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
      imageQuality: 85,
    );
    if (file == null) return;
    setState(() => _pendingPhoto = File(file.path));
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    try {
      final lat = _lat;
      final lng = _lng;
      final name = _nameCtrl.text.trim().isEmpty
          ? 'Sin nombre'
          : _nameCtrl.text.trim();
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
        setState(() => _saving = false);
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
        categoryIsExplicit: categoryIsExplicit,
      );

      final editSaveId = _editSaveId;
      final editSiteId = _editSiteId;

      String resultSiteId;
      UserSave? saved;
      var isPossibleDuplicate = false;
      var status = widget.savesRepository.computeStatus(input);

      if (editSaveId != null && editSiteId != null) {
        saved = await widget.savesRepository.updateSave(
          saveId: editSaveId,
          siteId: editSiteId,
          input: input,
        );
        resultSiteId = saved.siteId;
        isPossibleDuplicate = saved.isPossibleDuplicate;
        status = saved.status;
      } else if (editSiteId != null) {
        await widget.savesRepository.updateSiteWithoutSave(
          siteId: editSiteId,
          input: input,
        );
        resultSiteId = editSiteId;
        status = widget.savesRepository.computeStatus(input);
      } else {
        String? linkToExisting;
        final shouldCheckDuplicates = _isPhysical &&
            ((_isPublic) ||
                (lat != null && lng != null) ||
                _selectedCity != null);

        if (shouldCheckDuplicates) {
          final dupes = await widget.savesRepository.findPossibleDuplicates(
            name: name,
            city: _selectedCity?.name,
            latitude: lat,
            longitude: lng,
          );
          if (dupes.isNotEmpty && mounted) {
            final chosen = await _askDuplicate(dupes.first);
            if (chosen == null) {
              setState(() => _saving = false);
              return;
            }
            if (chosen) linkToExisting = dupes.first.siteId;
          }
        }

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
            linkToExistingSiteId: linkToExisting,
            categoryIsExplicit: categoryIsExplicit,
          ),
        );
        resultSiteId = saved.siteId;
        isPossibleDuplicate = saved.isPossibleDuplicate;
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

      if (_pendingPhoto != null) {
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

      if (saved != null) {
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
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(_isEditing ? '¡Actualizado!' : '¡Lugar guardado!'),
          content: Text(
            [
              if (_isStaffSiteEdit)
                'Cambios del sitio guardados.'
              else if (isPossibleDuplicate)
                'Quedó vinculado a un sitio público existente (posible duplicado).'
              else if (status == SiteStatus.complete)
                'Quedó completo en tu lista.'
              else if (_isPhysical && (lat == null || lng == null))
                l10n.saveNeedsMapPoint
              else
                l10n.saveStatusAfterSave(status.label(l10n)),
              if (!_isStaffSiteEdit && !isPublicResult)
                ' Privado por defecto.',
            ].join(),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.actionDone),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.pop(context, saved ?? resultSiteId);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppToast.error(context, e, logContext: 'save_place_submit');
    }
  }

  Future<bool?> _askDuplicate(PossibleDuplicate d) {
    final dist =
        d.distanceM == null ? '' : ' · ~${d.distanceM!.round()} m';
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.sameSiteTitle),
        content: Text(
          'Encontramos un sitio público parecido:\n\n'
          '«${d.siteName}»'
          '${d.city != null ? ' — ${d.city}' : ''}$dist\n\n'
          'No se fusiona solo: tú decides.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.sameSiteNew),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.sameSiteYes),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  InputDecoration _dec(String label, {bool required = false, String? helper}) {
    return InputDecoration(
      label: required
          ? Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: label),
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: AppColors.requiredMark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : Text(label),
      border: const OutlineInputBorder(),
      helperText: helper,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? l10n.savePlaceEditTitle : l10n.savePlaceTitle,
        ),
      ),
      body: _loadingCats
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                // 1) Ubicación primero
                _sectionCard(
                  title: l10n.saveLocationSection,
                  children: [
                    Text(
                      l10n.saveLocationDraftHint,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    SegmentedButton<bool>(
                      segments: [
                        ButtonSegment<bool>(
                          value: false,
                          label: Text(l10n.saveLocationMap),
                          icon: const Icon(Icons.map_outlined, size: 18),
                        ),
                        ButtonSegment<bool>(
                          value: true,
                          label: Text(l10n.saveLocationGoogleLink),
                          icon: const Icon(Icons.link, size: 18),
                        ),
                      ],
                      selected: {_useGoogleLink},
                      onSelectionChanged: _saving
                          ? null
                          : (s) => setState(() => _useGoogleLink = s.first),
                    ),
                    const SizedBox(height: 10),
                    if (!_useGoogleLink) ...[
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.touch_app_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(
                          _lat != null && _lng != null
                              ? l10n.saveLocationPointReady
                              : l10n.saveLocationPickMap,
                        ),
                        subtitle: Text(
                          _lat != null && _lng != null
                              ? '${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)}'
                              : l10n.saveLocationTapHint,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _saving ? null : _openMap,
                      ),
                      if (_lat != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: _saving
                                ? null
                                : () => setState(() {
                                      _lat = null;
                                      _lng = null;
                                    }),
                            child: Text(l10n.saveLocationClear),
                          ),
                        ),
                    ] else ...[
                      TextField(
                        controller: _mapsCtrl,
                        decoration: _dec(
                          l10n.saveMapsPasteLabel,
                          helper: l10n.saveMapsPasteHelper,
                        ).copyWith(
                          suffixIcon: FieldActionIcon(
                            icon: Icons.content_paste,
                            tooltip: l10n.actionPaste,
                            loading: _importingMaps,
                            onPressed: (_saving || _importingMaps)
                                ? null
                                : _pasteMapsAndImport,
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
                      if (_pendingMapImageUrl != null) ...[
                        const SizedBox(height: 8),
                        AppNetworkImage(
                          url: _pendingMapImageUrl!,
                          cacheKey: 'map:${_pendingMapImageUrl!}',
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ],
                    ],
                    Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        key: ValueKey('loc-$_locationPanelEpoch'),
                        initiallyExpanded: _locationDetailsExpanded,
                        maintainState: true,
                        tilePadding: EdgeInsets.zero,
                        childrenPadding: const EdgeInsets.only(bottom: 4),
                        onExpansionChanged: (v) =>
                            setState(() => _locationDetailsExpanded = v),
                        title: Text(
                          l10n.saveNameDetails,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          _locationSummary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.onImageMuted,
                          ),
                        ),
                        children: [
                          TextField(
                            controller: _nameCtrl,
                            decoration: _dec(
                              l10n.savePlaceName,
                              helper: l10n.savePlaceNameHelper,
                            ),
                            textCapitalization: TextCapitalization.words,
                            onChanged: (_) => setState(() {}),
                            onEditingComplete: () {
                              _maybeSuggestCategories();
                              FocusScope.of(context).unfocus();
                            },
                            onSubmitted: (_) => _maybeSuggestCategories(),
                          ),
                          const SizedBox(height: 10),
                          GeoTypeaheadField<GeoDepartment>(
                            controller: _deptCtrl,
                            focusNode: _deptFocus,
                            items: _geoCatalog?.activeDepartments ?? const [],
                            labelOf: (d) => d.name,
                            selected: _selectedDept,
                            enabled: _geoCatalog != null,
                            decoration: _dec(
                              l10n.saveDepartment,
                              helper: _geoCatalog == null
                                  ? l10n.saveGeoCatalogMissing
                                  : l10n.savePickFromList,
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
                                : (_geoCatalog?.citiesIn(_selectedDept!.id) ??
                                    const []),
                            labelOf: (c) => c.name,
                            selected: _selectedCity,
                            enabled:
                                _geoCatalog != null && _selectedDept != null,
                            decoration: _dec(
                              l10n.saveCity,
                              helper: _selectedDept == null
                                  ? l10n.savePickDeptFirst
                                  : l10n.savePickFromList,
                            ),
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
                      ),
                    ),
                  ],
                ),

                // 2) Enlaces
                _sectionCard(
                  title: l10n.saveLinksSection,
                  children: [
                    TextField(
                      controller: _socialCtrl,
                      decoration: _dec(l10n.saveSocialPaste).copyWith(
                        suffixIcon: FieldActionIcon(
                          icon: Icons.content_paste,
                          tooltip: l10n.actionPaste,
                          loading: _addingSocial,
                          onPressed: (_saving || _addingSocial)
                              ? null
                              : _pasteSocialAndAdd,
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
                                : () =>
                                    setState(() => _socialLinks.remove(d)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // 3) Categorías (sugeridas; default Otros si no hay match)
                _sectionCard(
                  title: l10n.saveCategoriesSection,
                  children: [
                    if (_categoryWasAutoSuggested &&
                        _selectedCategories.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          _selectedCategories.any(
                                (c) =>
                                    c.slug ==
                                        CategorySuggester.defaultChildSlug ||
                                    c.slug ==
                                        CategorySuggester.defaultParentSlug,
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
                          final label = parent.isEmpty
                              ? c.nameEs
                              : '$parent › ${c.nameEs}';
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
                        final label = parent.isEmpty
                            ? c.nameEs
                            : '$parent › ${c.nameEs}';
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
                    ] else
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.saveCategorySuggestHint,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _saving ? null : _openCategoryTree,
                              icon: const Icon(
                                Icons.account_tree_outlined,
                                size: 18,
                              ),
                              label: Text(l10n.saveCategoryTree),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                // 4) Opciones
                _sectionCard(
                  title: l10n.saveVisibilitySection,
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.saveIsPhysical),
                      subtitle: Text(l10n.saveIsPhysicalSubtitle),
                      value: _isPhysical,
                      onChanged: (v) => setState(() {
                        _isPhysical = v;
                        if (!v) _isPublic = false;
                      }),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.saveMakePublic),
                      subtitle: Text(
                        !_isPhysical
                            ? l10n.savePublicNonPhysical
                            : !_hasFormLocation
                                ? l10n.savePublicNeedLocation
                                : l10n.savePublicVisible,
                      ),
                      value: _isPublic,
                      onChanged: (_isPhysical && _hasFormLocation)
                          ? (v) => setState(() => _isPublic = v)
                          : null,
                    ),
                    OutlinedButton.icon(
                      onPressed: _saving ? null : _pickPhoto,
                      icon: const Icon(Icons.photo_outlined),
                      label: Text(
                        _pendingPhoto == null
                            ? l10n.saveAddPhoto
                            : l10n.savePhotoReady,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _isEditing
                              ? l10n.savePlaceSubmitEdit
                              : l10n.savePlaceSubmit,
                        ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.saveDraftFooter,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
    );
  }
}
